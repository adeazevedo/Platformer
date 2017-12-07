extends "res://addons/com.brandonlamb.bt/root.gd"

func tick(actor, ctx):
	if actor.has_method("defend"):
		return actor.defend()

	return OK