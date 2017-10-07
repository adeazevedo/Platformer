extends Node

var right_key = 0
var left_key = 0
var attack_key = 0
var defend_key = 0
var dash_key = 0

func _ready():
	set_process_input(true)


func _input(delta):
	right_key = Input.is_action_pressed("ui_right")
	left_key = Input.is_action_pressed("ui_left")
	attack_key = Input.is_action_pressed("attack_key")
	defend_key = Input.is_action_pressed("defend_key")
	dash_key = Input.is_action_pressed("ui_select")

func right_key_pressed():
	return right_key

func left_key_pressed():
	return left_key

func attack_key_pressed():
	return attack_key

func defend_key_pressed():
	return defend_key

func dash_key_pressed():
	return dash_key