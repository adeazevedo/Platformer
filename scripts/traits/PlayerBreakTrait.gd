
extends "res://scripts/traits/Trait.gd"

export (float) var break_duration = 0.4
export (float) var cooldown_duration = 1

var duration = Timer.new()
var cooldown = Timer.new()

var can_break_guard = true
var is_breaking_guard = false

func _ready():
	init_timer(duration, break_duration)
	init_timer(cooldown, cooldown_duration)


func _execute (body):
	if can_break_guard:
		can_break_guard = false
		is_breaking_guard = true

		body.get_node("DashCollision").activate()

		body.anim_node.play("dash")
		body.move_speed_mod = 3.0

		duration.connect("timeout", self, "on_duration_end", [body], CONNECT_ONESHOT)
		duration.start()


func on_duration_end(body):
	body.move_speed_mod = 1.0
	is_breaking_guard = false

	body.get_node("DashCollision").deactivate()

	body.anim_node.stop()

	cooldown.connect("timeout", self, "on_cooldown_end", [body], CONNECT_ONESHOT)
	cooldown.start()

	body.next_state = "idle"


func on_cooldown_end(body):
	can_break_guard = true


func init_timer(timer, duration):
	timer.set_wait_time(duration)
	timer.set_one_shot(true)

	add_child(timer)
