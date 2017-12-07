extends "res://addons/com.brandonlamb.bt/root.gd"

func _tick(actor, ctx):
	if actor.target.is_staggered():
		return OK

	return FAILED