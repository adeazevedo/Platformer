
extends "res://scripts/traits/Trait.gd"

export (bool) var disable = false
export (float) var GRAVITY = 400.0

func _execute (body):
	if disable: return body.velocity

	var velocity = body.velocity
	velocity.y += GRAVITY * body.get_fixed_process_delta_time()
	#velocity.y = lerp(velocity.y, GRAVITY, body.get_fixed_process_delta_time())

	return velocity
