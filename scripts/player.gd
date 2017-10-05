extends KinematicBody2D

var StateMachine = preload("res://scripts/StateMachine.gd")
onready var sm = StateMachine.new(self)

const GRAVITY = 300.0
var BASE_MOVE_SPEED = 140

var velocity = Vector2()
var MOVE_SPEED = BASE_MOVE_SPEED

onready var anim_node = get_node("AnimationPlayer")

func _ready():
	sm.add("idle", "_on_idle_state")
	sm.add("attack", "_on_attack_state")
	sm.add("defend", "_on_defend_state")
	sm.add("move", "_on_move_state")

	sm.initial("idle")

	set_fixed_process(true)


func _fixed_process(delta):
	# Gravity
	velocity.y += GRAVITY * delta
	var motion = velocity * delta

	if is_colliding():
        var n = get_collision_normal()
        motion = n.slide(motion)
        velocity = n.slide(velocity)

	move(motion)

	sm.execute_next()


##=================================
## States
##=================================
## Idle
func _on_idle_state():
	MOVE_SPEED = BASE_MOVE_SPEED
	velocity.x = 0

	# Change to attack - when Z is pressed
	if Input.is_action_pressed("Z"):
		sm.change_to("attack")
		return

	# Change to defend - when X is pressed
	if Input.is_action_pressed("X"):
		sm.change_to("defend")
		return

	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
		sm.change_to("move")
		return

	if not anim_node.get_current_animation() == "idle":
		anim_node.play("idle")


## Attack
func _on_attack_state():
	if not anim_node.get_current_animation() == "attack":
		anim_node.play("attack")

	if not anim_node.is_playing():
		sm.change_to("idle")


## Defend
func _on_defend_state():
	MOVE_SPEED = 100
	if not anim_node.get_current_animation() == "defend":
		anim_node.play("defend")

	# Change to attack - when Z is pressed
	if Input.is_action_pressed("Z"):
		sm.change_to("attack")

	# Change to defend - when X is RELEASED
	if not Input.is_action_pressed("X"):
		sm.change_to("idle")


## Move
func _on_move_state():
	if Input.is_action_pressed("ui_right"):
		velocity.x = MOVE_SPEED

	elif Input.is_action_pressed("ui_left"):
		velocity.x = -MOVE_SPEED

	if not Input.is_action_pressed("ui_right") and not Input.is_action_pressed("ui_left"):
		sm.change_to("idle")