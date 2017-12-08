
extends "res://scripts/traits/Trait.gd"

export (float) var JUMP_FORCE = 300.0

var can_jump = true
var is_jumping = false

func _execute (body):
	var velocity = body.velocity

	velocity.y -= JUMP_FORCE

	return velocity