extends Node

var blocked = false

func is_pressed(key):
	if blocked: return 0

	return Input.is_action_pressed(key)


func is_right_key_pressed():
	return is_pressed("ui_right")

func is_left_key_pressed():
	return is_pressed("ui_left")

func is_attack_key_pressed():
	return is_pressed("attack_key")

func is_defend_key_pressed():
	return is_pressed("defend_key")

func is_break_key_pressed():
	return is_pressed("break_key")

func is_jump_key_pressed():
	return is_pressed("jump_key")