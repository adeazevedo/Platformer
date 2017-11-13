
extends KinematicBody2D

onready var sight = get_node('sight')
onready var ai = get_node('BehaviorTree')

var entities_inside_sight = []
var target_list = []
var target

var MAX_ATTACK_RANGE = 50

signal target_changed(target)

func _ready():
	set_fixed_process(true)


func _fixed_process(delta):
	if target == null and !target_list.empty():
		var new_target = target_list.front()
		change_target(new_target)

	#var r = ai.processTree(self)
	var r = ai.tick(self, [])


func is_inside_sight (body):
	return entities_inside_sight.find(body)


func change_target(t):
	target = t
	emit_signal("target_changed", t)


func _on_sight_body_enter( body ):
	entities_inside_sight.append(weakref(body))

	if body.is_in_group('player'):
		target_list.append(body)


func _on_sight_body_exit( body ):
	var eis_index = entities_inside_sight.find(body)
	if eis_index != -1: entities_inside_sight.remove(eis_index)

	var index = target_list.find(body)

	if index >= 0:
		var erased = target_list[index]
		target_list.remove(index)

		if target == erased:
			change_target(null)