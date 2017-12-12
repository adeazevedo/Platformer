
extends "res://scripts/traits/Trait.gd"

export (float) var stagger_time = 0.5

var duration = Timer.new()

var is_staggering = false

func _ready():
	duration.set_wait_time(stagger_time)
	duration.set_one_shot(true)

	add_child(duration)


func _execute (body):
	body.move_speed_mod = 0.25

	if !is_staggering:
		is_staggering = true
		body.anim_node.play("stagger")

		body.get_node("PlayerAttackTrait").interrupt(body)

		duration.connect("timeout", self, "on_stagger_end", [body], CONNECT_ONESHOT)
		duration.start()

func on_stagger_end (body):
	is_staggering = false
	body.move_speed_mod = 1.0

	body.next_state = "idle"