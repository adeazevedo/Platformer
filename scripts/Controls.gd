extends Node

var blocked = false

var action = {
	ui_right = false,
	ui_left = false,
	attack_key = false,
	defend_key = false,
	break_key = false,
	jump_key = false,
}

func _ready():
	set_process_input(true)

func _input(event):
	if blocked: return 0

	for act in action.keys():
		if event.is_action_released(act):
			action[act] = false
			return

		if event.is_action(act):
			action[act] = event


func is_pressed(a):
	if action.has(a) and typeof(action[a]) != TYPE_BOOL:
		return action[a].is_pressed()

	return false

func is_echo(a):
	if action.has(a) and typeof(action[a]) != TYPE_BOOL:
		return action[a].is_echo()

	return false

func is_pressed_once(act):
	return is_pressed(act) and !is_echo(act)

func is_holding(act):
	return is_pressed(act) or is_echo(act)


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