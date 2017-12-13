
extends "res://scripts/EnemyEntity.gd"

onready var sight = get_node('sight')

onready var gravity_effect = get_node("GravityEffect")

var entities_inside_sight = []
var target_list = []
var target

onready var ai = get_node("GruntAI")

signal target_changed(target)

# Funcs ################################################
func _ready():
	face = LEFT

	get_node("AttackCollision").deactivate()

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

	ai.tick(self, {})

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
	entities_inside_sight.append(body)

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


func idle():
	get_node("anim").play("idle")


var is_staggering = false
func is_staggering():
	return is_staggering

func stagger():
	if !is_staggering:
		is_staggering = true

		get_node("AttackTrait").interrupt()
		get_node("AttackCollision").deactivate()

		get_node("anim").play("stagger")

		get_node("StaggerTime").connect("timeout", self, "stagger_timeout", [], CONNECT_ONESHOT)
		get_node("StaggerTime").start()

func stagger_timeout():
	is_staggering = false
	get_node("anim").play("idle")


func can_attack():
	return get_node("AttackTrait").can_attack

func is_attacking():
	return get_node("AttackTrait").is_attacking

func attack():
	return get_node("AttackTrait").execute()

func _on_AttackCollision_body_enter( body ):
	body.combat_process(self)
