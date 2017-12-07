
extends "res://scripts/traits/Trait.gd"

export (float) var JUMP_FORCE = 300.0

var can_jump = true
var is_jumping = false

func _execute (body):
	if can_jump:
		can_jump = false
		is_jumping = true

		body.velocity.y = body.velocity.y - JUMP_FORCE

		body.next_state = "idle"