extends "res://addons/com.brandonlamb.bt/root.gd"

func tick(actor, ctx):
	if actor.is_inside_sight(actor.target):
		return OK

	return FAILED