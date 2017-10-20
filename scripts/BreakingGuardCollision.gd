# Base implementation for breaking guard collision entities
extends "res://scripts/CollisionArea.gd"

func _ready():
	connect("body_enter", self, "_on_collision_body_enter")

func _on_collision_body_enter( enemy ):
	if enemy.is_in_group(_enemy_group):

		# if enemy is defending, he stagger
		if enemy.is_defending:
			enemy.stagger()
