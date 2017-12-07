
extends "res://scripts/traits/Trait.gd"

var can_attack = true
var is_attacking = false

export (float) var attack_speed = 0.75

func _execute (body):
	body.move_speed_mod = 1.0 / 2.0
	var anim = body.anim_node

	if can_attack:
		can_attack = false
		is_attacking = true

		anim.set_speed(1/attack_speed)
		anim.play("attack")

		anim.connect("finished", self, "on_finished", [body], CONNECT_ONESHOT)


func on_finished(body):
	can_attack = true
	is_attacking = false

	body.move_speed_mod = 1.0
	body.get_node("AttackCollision").deactivate()

	body.next_state = "idle"


func interrupt(body):
	can_attack = true
	is_attacking = false

	body.move_speed_mod = 1.0
	body.get_node("AttackCollision").deactivate()

func stop_timer():
	pass#attack_timer.call_deferred("stop")
