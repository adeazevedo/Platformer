# Base implementation for attack collision entities
extends "res://scripts/CollisionArea.gd"

func _ready():
	connect("body_enter", self, "_on_collision_body_enter")

func _on_collision_body_enter( enemy ):
	if enemy.is_in_group( _enemy_group ):

		# if my attack fails encounter a defending enemy
		if enemy.is_defending:
			# I get stagger
			_parent.stagger()

		# Else, calc normal dmg
		else:
			var dmg = _parent.calc_atk() if _parent.has_method("calc_atk") else 1
			enemy.apply_dmg(dmg)