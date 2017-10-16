extends KinematicBody2D
var StateMachine = preload("res://scripts/StateMachine.gd")
onready var sm = StateMachine.new(self)

const GRAVITY = 300
var velocity = Vector2()

var is_attacking = false
var is_breaking = false
var is_defending = false
var is_hit = false

onready var anim_node = get_node("AnimationPlayer")

func _ready():
	add_to_group("enemy")

	sm.add("idle", "_on_idle_state")
	sm.add("attack", "_on_attack_state")
	sm.add("defend", "_on_defend_state")
	sm.add("break_guard", "_on_break_guard_state")
	sm.add("hit", "_on_hit_state")

	sm.initial("idle")

	get_node("HitTimer").connect("timeout", self, "_on_hit_end")

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
	is_defending = true


func _on_break_guard_state():
	is_breaking = true


func _on_hit_state():
	if !is_hit:
		anim_node.play("hit")
		is_hit = true
		get_node("HitTimer").start()

func _on_hit_end():
	is_hit = false
	sm.change_to("idle")


# When in sight range
func _on_Sight_body_enter( body ):
	if body.is_in_group("player"):
		print("Player is in Sight")
