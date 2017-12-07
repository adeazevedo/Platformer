
extends "res://scripts/traits/Trait.gd"

export (NodePath) var anim_path
export (String) var animation_name

onready var anim_node = get_node(anim_path)

var is_attacking = false
var attack_finished = false

func _ready():
	anim_node.connect("finished", self, "attack_end")

func _execute(args = {}):
	if not is_attacking:
		anim_node.play(animation_name)
		is_attacking = true
		return ERR_BUSY

	if attack_finished:
		is_attacking = false
		attack_finished = false
		return OK

func attack_end():
	attack_finished = true