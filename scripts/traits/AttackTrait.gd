
extends "res://scripts/traits/Trait.gd"

export (NodePath) var anim_path
export (String) var animation_name
export (float) var anim_speed = 1
export (float) var attack_cooldown = 0.7

onready var anim_node = get_node(anim_path)

var animation_finished = false

var can_attack = true
var is_attacking = false

var cooldown_timer = Timer.new()

func _ready():
	anim_node.connect("finished", self, "attack_end")

	cooldown_timer.set_wait_time(attack_cooldown)
	cooldown_timer.set_one_shot(true)
	add_child(cooldown_timer)

func _execute(args = {}):
	if can_attack:
		print("attack start")
		can_attack = false
		anim_node.set_speed(1/anim_speed)
		anim_node.play(animation_name)

		return ERR_BUSY

	if animation_finished:
		animation_finished = false
		cooldown_timer.set_wait_time(attack_cooldown)
		if !cooldown_timer.is_connected("timeout", self, "cooldown_end"):
			cooldown_timer.connect("timeout", self, "cooldown_end", [], CONNECT_ONESHOT)
		cooldown_timer.start()

		return OK

	return ERR_BUSY

func interrupt():
	is_attacking = false
	animation_finished = true

	if cooldown_timer.is_connected("timeout", self, "cooldown_end"):
		cooldown_timer.disconnect("timeout", self, "cooldown_end")

func cooldown_end():
	can_attack = true

func attack_end():
	animation_finished = true

func set_attack(c):
	is_attacking = c