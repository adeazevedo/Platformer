extends "res://addons/com.brandonlamb.bt/root.gd"

func tick(actor, ctx):
	if actor.target == null:
		return FAILED

	return OK