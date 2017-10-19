# Base implementation for defend collision entities
extends "res://scripts/CollisionArea.gd"

func _ready():
	connect("body_enter", self, "_on_collision_body_enter")

func _on_collision_body_enter( enemy ):
	if enemy.is_in_group( _enemy_group ):

		# if my defense fails against a enemy breaking guard
		if enemy.is_breaking_guard:
			# I get stagger
			_parent.stagger()