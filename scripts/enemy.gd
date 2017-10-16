extends KinematicBody2D
var StateMachine = preload("res://scripts/StateMachine.gd")
onready var sm = StateMachine.new(self)

const GRAVITY = 300
var velocity = Vector2()

var is_attacking = false
var is_breaking_guard = false
var is_defending = false
var is_staggering = false

onready var anim_node = get_node("AnimationPlayer")

func _ready():
	add_to_group("enemy")

	sm.add("idle", "_on_idle_state")
	sm.add("attack", "_on_attack_state")
	sm.add("defend", "_on_defend_state")
	sm.add("break_guard", "_on_break_guard_state")
	sm.add("stagger", "_on_stagger_state")

	sm.initial("defend")

	get_node("BreakGuardTimer").connect("timeout", self, "_on_break_guard_end")
	get_node("StaggerTimer").connect("timeout", self, "_on_stagger_end")
	get_node("DefendTimer").connect("timeout", self, "_on_defend_end")

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

func apply_damage (value):
	print("Damage received: ", value)

	# Change to hit state
	sm.change_to("hit")


func _on_idle_state():
	if !anim_node.is_playing():
		anim_node.play("idle")


func _on_attack_state():
	is_attacking = true


func _on_defend_state():
	if !is_defending:
		is_defending = true
		anim_node.play("defend")

		get_node("DefendTimer").start()

func _on_defend_end():
	is_defending = true
	#sm.change_to("idle")


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
	print()
	sm.change_to("stagger")


# When in sight range
func _on_Sight_body_enter( body ):
	if body.is_in_group("player"):
		print("Player is in Sight")
