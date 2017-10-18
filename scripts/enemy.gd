extends KinematicBody2D
var StateMachine = preload("res://scripts/StateMachine.gd")
onready var sm = StateMachine.new(self)

const GRAVITY = 300
var velocity = Vector2()
var move_speed = 80

var enemies_in_sight = []
var target

var hp = 10
var ATTACK_RANGE = 100

var is_chasing = false
var is_attacking = false
var is_breaking_guard = false
var is_defending = false
var is_staggering = false

onready var anim_node = get_node("AnimationPlayer")


func _ready():
	add_to_group("enemy")

	sm.add("idle", "_on_idle_state")
	sm.add("chase", "_on_chase_state")
	sm.add("attack", "_on_attack_state")
	sm.add("defend", "_on_defend_state")
	sm.add("break_guard", "_on_break_guard_state")
	sm.add("stagger", "_on_stagger_state")

	sm.initial("idle")

	set_fixed_process(true)


func _fixed_process(delta):
	sm.execute_next()

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
	sm.change_to("stagger")

func search_next_state():
	var state = null

	target = enemies_in_sight.front() if enemies_in_sight.size() > 0 else null

	if target != null:
		if get_pos().distance_to(target.get_pos()) > 75:
			state = "chase"
		else:
			state = "attack"

	else:
		state = "idle"

	return state

func _on_idle_state():
	velocity.x = 0

	if anim_node.get_current_animation() != "idle":
		anim_node.play("idle")

	var state = search_next_state()

	sm.change_to(state)


func _on_chase_state():
	if !target:
		sm.change_to("idle")
		return

	var my_pos = get_pos()
	var target_pos = target.get_pos()

	var distance = my_pos.distance_to(target_pos)

	if distance > ATTACK_RANGE:
		var direction = target_pos - my_pos
		velocity.x = direction.x * move_speed * get_process_delta_time()

	else:
		sm.change_to("attack")



func _on_attack_state():
	if !is_attacking:
		is_attacking = true
		anim_node.play("attack")
		get_node("AttackTimer").start()

func _on_attack_end():
	is_attacking = false
	sm.change_to("idle")


func _on_defend_state():
	if !is_defending:
		is_defending = true
		anim_node.play("defend")

		get_node("DefendTimer").start()

func _on_defend_end():
	is_defending = true
	sm.change_to("idle")


func _on_break_guard_state():
	if !is_breaking_guard:
		is_breaking_guard = true
		anim_node.play("break_guard")

		get_node("BreakGuardTimer").start()

func _on_break_guard_end():
	is_breaking_guard = false

	sm.change_to("idle")


func _on_stagger_state():
	if !is_staggering:
		is_staggering = true
		anim_node.play("stagger")
		get_node("StaggerTimer").start()

func _on_stagger_end():
	is_staggering = false
	sm.change_to("idle")


func stagger():
	is_attacking = false
	is_defending = false
	is_breaking_guard = false
	sm.change_to("stagger")


# When in sight range
func _on_Sight_body_enter( body ):
	if body.is_in_group("player"):
		if !enemies_in_sight.has(body):
			enemies_in_sight.append(body)

		target = body if target == null else body
		sm.change_to("chase")


func _on_Sight_body_exit( body ):
	if body.is_in_group("player"):
		var i = enemies_in_sight.find(body)
		if i >= 0:
			target = null if target == body else target
			enemies_in_sight.remove(i)
