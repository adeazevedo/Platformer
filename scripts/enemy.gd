extends KinematicBody2D
var StateMachine = preload("res://scripts/StateMachine.gd")
onready var sm = StateMachine.new(self)

const GRAVITY = 300
var velocity = Vector2()

onready var anim_node = get_node("AnimationPlayer")

func _ready():
	add_to_group("enemy")

	sm.add("idle", "_on_idle_state")
	sm.add("attack", "_on_attack_state")
	sm.add("defend", "_on_defend_state")
	sm.add("dash", "_on_dash_state")

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


func _on_idle_state():
	if !anim_node.is_playing():
		anim_node.play("idle")


func _on_attack_state():
	pass


func _on_defend_state():
	pass


func _on_dash_state():
	pass