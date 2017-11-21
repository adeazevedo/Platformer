extends "res://addons/com.brandonlamb.bt/root.gd"

func tick(actor, ctx):
	var closing = -sign(actor.get_pos().x - actor.target.get_pos().x)
	actor.move(Vector2(closing, 0))
	return OK