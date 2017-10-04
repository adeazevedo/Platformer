extends KinematicBody2D

var StateMachine = preload("res://scripts/StateMachine.gd")
onready var sm = StateMachine.new(self)

onready var anim_node = get_node("AnimationPlayer")

func _ready():
	sm.add("idle", "_on_idle_state")
	sm.add("attack", "_on_attack_state")
	sm.add("defend", "_on_defend_state")

	sm.initial("idle")

	set_fixed_process(true)

##=================================
## States
##=================================
## Idle
func _on_idle_state():
	# Change to attack - when Z is pressed
	if Input.is_action_pressed("Z"):
		sm.change_to("attack")
		return

	# Change to defend - when X is pressed
	elif Input.is_action_pressed("X"):
		sm.change_to("defend")
		return

	if not anim_node.get_current_animation() == "idle":
		anim_node.play("idle")


## Attack
func _on_attack_state():
	if not anim_node.get_current_animation() == "attack":
		anim_node.play("attack")

	if not anim_node.is_playing():
		sm.change_to("idle")


## Defend
func _on_defend_state():
	if not anim_node.get_current_animation() == "defend":
		anim_node.play("defend")

	# Change to attack - when Z is pressed
	if Input.is_action_pressed("Z"):
		sm.change_to("attack")

	# Change to defend - when X is realesed
	if not Input.is_action_pressed("X"):
		sm.change_to("idle")


func _fixed_process(delta):
	sm.execute_next()

