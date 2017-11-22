extends "res://addons/com.brandonlamb.bt/root.gd"

func tick(actor, ctx):
	if actor.has_method("attack"):
		return actor.attack()

	return OK