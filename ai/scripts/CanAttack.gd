
extends "res://addons/com.brandonlamb.bt/root.gd"

func tick(actor, ctx):
	if actor.has_method("can_attack"):
		return OK if actor.can_attack() else FAILED

	else:
		return OK