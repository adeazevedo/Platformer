
extends "res://scripts/traits/Trait.gd"

export (float) var GRAVITY = 400.0

func _execute(body):
	var velocity = body.velocity
	velocity.y += GRAVITY * body.get_fixed_process_delta_time()

	return velocity
