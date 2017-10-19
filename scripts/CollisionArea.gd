extends Area2D

export(String) var _enemy_group
export(NodePath) var _parent_path

onready var _parent = get_node(_parent_path)

# Activates and deactivate monitoring ans visibility of collision areas
func activate():
	self.call_deferred("set_enable_monitoring", true)
	self.show()


func deactivate():
	self.call_deferred("set_enable_monitoring", false)
	self.hide()
