
extends "res://addons/com.brandonlamb.bt/root.gd"

func tick(actor, ctx):
	var distance = actor.get_pos().distance_to( actor.target.get_pos() )
	if distance <= actor.MAX_ATTACK_RANGE:
		return OK

	return FAILED