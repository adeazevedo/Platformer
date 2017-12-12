extends "res://addons/com.brandonlamb.bt/root.gd"

func tick(actor, ctx):
	return OK if actor.is_staggering() else FAILED