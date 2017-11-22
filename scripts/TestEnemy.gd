
extends KinematicBody2D

onready var sight = get_node('sight')
onready var ai = get_node('AggressiveBehaviorTree')

onready var gravity_effect = get_node("GravityEffect")

enum FACE {RIGHT = 1, LEFT = -1}

var face = LEFT

var entities_inside_sight = []
var target_list = []
var target

export (int) var MAX_ATTACK_RANGE = 50
export (int) var WALK_SPEED = 2

var velocity = Vector2()


signal target_changed(target)

# Funcs ################################################
func _ready():
	set_fixed_process(true)


func _fixed_process(delta):
	velocity = accept(gravity_effect)

	var motion = velocity * delta

	if is_colliding():
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)

	.move(motion)

	if target == null and !target_list.empty():
		var new_target = target_list.front()
		change_target(new_target)

	var r = ai.tick(self, {})


func accept (trait, args = self):
	return trait.execute(args)


func face_flip (face):
	if face == RIGHT or face == LEFT:
		self.face = face
		set_scale(Vector2(-face, 1))


func is_inside_sight (body):
	return entities_inside_sight.find(body)


func change_target (t):
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


func move(direction):
	var velocity = direction * WALK_SPEED
	face_flip(direction.x)
	.move(velocity)

func attack():
	return get_node("AttackTrait").execute()