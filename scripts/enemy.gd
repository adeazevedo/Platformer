extends KinematicBody2D

var state = {
	idle			= funcref(self, "_on_idle_state"),
	chase		= funcref(self, "_on_chase_state"),
	prepare		= funcref(self, "_on_prepare_state"),
	attack		= funcref(self, "_on_attack_state"),
	defend		= funcref(self, "_on_defend_state"),
	break_guard	= funcref(self, "_on_break_guard_state"),
	stagger		= funcref(self, "_on_stagger_state"),
}
var next_state = "idle"

const GRAVITY = 300
var velocity = Vector2()
var move_speed = 60

var enemies_in_sight = []
var target

var hp = 3
var ATTACK_RANGE = 45

var is_preparing = false
var is_chasing = false
var is_attacking = false
var is_breaking_guard = false
var is_defending = false
var is_staggering = false

onready var anim_node = get_node("AnimationPlayer")


func _ready():
	add_to_group("enemy")

	set_fixed_process(true)


func _fixed_process(delta):
	state[next_state].call_func()

	velocity.y += GRAVITY * delta
	var motion = velocity * delta

	if is_colliding():
        var n = get_collision_normal()
        motion = n.slide(motion)
        velocity = n.slide(velocity)

	move(motion)

func calc_atk():
	return 1

func apply_dmg (value):
	print("Damage received: ", value)
	hp -= value
	# Change to hit state
	next_state = "stagger"

	if hp <= 0:
		die()

func die():
	queue_free()


func search_next_state():
	var state = null

	target = enemies_in_sight.front() if !enemies_in_sight.empty() else null

	if target != null:
		if get_pos().distance_to(target.get_pos()) > ATTACK_RANGE:
			state = "chase"
		else:
			state = "prepare"

	else:
		state = "idle"

	return state

func _on_idle_state():
	velocity.x = 0

	if anim_node.get_current_animation() != "idle":
		anim_node.play("idle")

	var state = search_next_state()

	next_state = state


func _on_chase_state():
	if !target:
		next_state = "idle"
		return

	var my_pos = get_pos()
	var target_pos = target.get_pos()

	var distance = my_pos.distance_to(target_pos)

	if distance > ATTACK_RANGE:
		var direction = target_pos - my_pos
		velocity.x = direction.x * move_speed * get_process_delta_time()

	else:
		next_state = "prepare"


func _on_prepare_state():
	if !is_preparing:
		is_preparing = true

		get_node("PrepareTimer").start()


func _on_prepare_end():
	velocity.x = 0
	is_preparing = false

	if target:
		var state
		if target.is_attacking(): state = "defend"
		elif target.is_defending(): state = "break_guard"
		else: state = "attack"

		next_state = state
		return

	sm.change_to("idle")


func _on_attack_state():
	if !is_attacking:
		is_attacking = true
		velocity.x = 0
		anim_node.play("attack")

		get_node("AttackTimer").start()

func _on_attack_end():
	is_attacking = false
	next_state = "idle"


func _on_defend_state():
	if !is_defending:
		is_defending = true
		anim_node.play("defend")

		get_node("DefendTimer").start()

func _on_defend_end():
	is_defending = false
	next_state = "idle"


func _on_break_guard_state():
	if !is_breaking_guard:
		is_breaking_guard = true
		anim_node.play("break_guard")

		get_node("BreakGuardTimer").start()

func _on_break_guard_end():
	is_breaking_guard = false

	next_state = "idle"


func _on_stagger_state():
	if !is_staggering:
		is_staggering = true
		anim_node.play("stagger")
		get_node("StaggerTimer").start()

func _on_stagger_end():
	is_staggering = false
	next_state = "idle"


func stagger():
	is_attacking = false
	is_defending = false
	is_breaking_guard = false

	get_node("AttackCollision").deactivate()
	#get_node("DefendCollision").deactivate()
	get_node("BreakCollision").deactivate()

	get_node("AttackTimer").call_deferred("stop")

	next_state = "stagger"


# When in sight range
func _on_Sight_body_enter( body ):
	if body.is_in_group("player"):
		if !enemies_in_sight.has(body):
			enemies_in_sight.append(body)

		target = body if target == null else body
		next_state = "chase"


func _on_Sight_body_exit( body ):
	if body.is_in_group("player"):
		var i = enemies_in_sight.find(body)
		if i >= 0:
			target = null if target == body else target
			enemies_in_sight.remove(i)