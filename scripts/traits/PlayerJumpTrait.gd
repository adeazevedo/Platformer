
extends "res://scripts/traits/Trait.gd"

export (float) var JUMP_FORCE = 240.0

var is_jumping = false

func _execute (body):
	var velocity = body.velocity

	velocity.y = -JUMP_FORCE

	return velocity