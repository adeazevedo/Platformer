extends KinematicBody2D

var StateMachine = preload("res://scripts/StateMachine.gd")
onready var sm = StateMachine.new(self)

onready var anim_node = get_node("AnimationPlayer")

func _ready():
	sm.add("idle", "_on_idle_state")
	sm.add("attack", "_on_attack_state")

	sm.initial("idle")

	set_fixed_process(true)

##=================================
## States
##=================================
## Idle
func _on_idle_state():
	if not anim_node.get_current_animation() == "idle":
		anim_node.play("idle")

	if Input.is_action_pressed("ui_accept"):
		sm.change_to("attack")

## Attack
func _on_attack_state():
	if not anim_node.get_current_animation() == "attack":
		anim_node.play("attack")

	if not anim_node.is_playing():
		sm.change_to("idle")


func _fixed_process(delta):
	sm.execute_next()

