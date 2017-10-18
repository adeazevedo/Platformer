# Base implementation for breaking guard collision entities

extends Area2D

export(String) var _enemy_group
export(NodePath) var _parent_path

onready var _parent = get_node(_parent_path)

func _ready():
	connect("body_enter", self, "_on_collision_body_enter")

func _on_collision_body_enter( enemy ):
	if enemy.is_in_group(_enemy_group):

		# if my break guard ation fails and be hit by an attack
		if enemy.is_attacking:
			# I get stagger
			_parent.stagger()
