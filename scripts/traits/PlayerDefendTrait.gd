
extends "res://scripts/traits/Trait.gd"

var is_defending = false

func _execute (body):
	body.move_speed_mod = 1.0 / 4.0
	is_defending = true

	#if not body.anim_node.get_current_animation() == "defend":
	body.anim_node.play("defend")

	# Change to attack - when Z is pressed
	if Controls.is_attack_key_pressed():
		is_defending = false

		body.next_state = "attack"

	# Change to idle - when X is RELEASED
	if not Controls.is_defend_key_pressed():
		is_defending = false
		body.move_speed_mod = 1.0

		body.next_state = "idle"

func on_finished(body):
	pass

func interrupt():
	pass