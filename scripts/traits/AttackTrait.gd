
extends "res://scripts/traits/Trait.gd"

export (NodePath) var anim_path
export (String) var animation_name
export (float) var anim_speed = 1

onready var anim_node = get_node(anim_path)

var animation_started = false
var animation_finished = false
var is_attacking = false

func _ready():
	anim_node.connect("finished", self, "attack_end")

func _execute(args = {}):
	if !animation_started:
		animation_started = true
		anim_node.set_speed(1/anim_speed)
		anim_node.play(animation_name)

		return ERR_BUSY

	if animation_finished:
		animation_started = false
		animation_finished = false
		return OK

	return ERR_BUSY

func interrupt():
	is_attacking = false
	animation_finished = true
	animation_started = false


func attack_end():
	animation_finished = true

func set_attack(c):
	is_attacking = c