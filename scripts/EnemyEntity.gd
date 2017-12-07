
extends "res://scripts/EntityBody.gd"

export (int) var MAX_ATTACK_RANGE = 50
export (int) var WALK_SPEED = 2

export(String, "Aggressive", "Defensive") var ai_type

onready var ai = AILoader.instance(ai_type)


func _ready():
	add_to_group("enemy")
	_enemy_group = "player"
	add_child(ai)
