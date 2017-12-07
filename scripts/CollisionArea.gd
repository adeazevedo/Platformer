extends Area2D

# Activates and deactivate monitoring ans visibility of collision areas
func activate():
	self.call_deferred("set_enable_monitoring", true)
	self.show()


func deactivate():
	self.call_deferred("set_enable_monitoring", false)
	self.hide()
