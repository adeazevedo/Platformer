extends Node

var blocked = false

var right_key = 0
var left_key = 0
var attack_key = 0
var defend_key = 0
var break_key = 0
var jump_key = 0

func _ready():
	set_process_input(true)

func _input(event):
	if blocked: return

	right_key = Input.is_action_pressed("ui_right")
	left_key = Input.is_action_pressed("ui_left")
	attack_key = event.is_action_pressed("attack_key")
	defend_key = Input.is_action_pressed("defend_key")
	break_key = event.is_action_pressed("break_key")
	jump_key = event.is_action_pressed("jump_key")

func right_key_pressed():
	return right_key

func left_key_pressed():
	return left_key

func attack_key_pressed():
	return attack_key

func defend_key_pressed():
	return defend_key

func break_key_pressed():
	return break_key

func jump_key_pressed():
	return jump_key