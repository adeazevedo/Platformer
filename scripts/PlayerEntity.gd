
extends "res://scripts/EntityBody.gd"

export (float) var MAX_MOVE_SPEED = 200.0
export (float) var ACCELERATION = 500.0
export (float) var DECELERATION = 1000.0



func _ready():
	add_to_group("player")
	_enemy_group = "enemy"

func apply_dmg( value ):
	HP -= value


