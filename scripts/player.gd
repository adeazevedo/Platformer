extends KinematicBody2D

var StateMachine = preload("res://scripts/StateMachine.gd")
onready var sm = StateMachine.new(self)

const GRAVITY = 300.0
var BASE_MOVE_SPEED = 140

var velocity = Vector2()
var MOVE_SPEED = BASE_MOVE_SPEED

var DASH_TIME = 0.4		# segundo
var dash_count = 0

onready var anim_node = get_node("AnimationPlayer")

func _ready():
	sm.add("idle", "_on_idle_state")
	sm.add("attack", "_on_attack_state")
	sm.add("defend", "_on_defend_state")
	sm.add("dash", "_on_dash_state")

	sm.initial("idle")

	set_fixed_process(true)


func _fixed_process(delta):
	read_move_inputs()
	sm.execute_next()

	# Gravity
	velocity.y += GRAVITY * delta
	var motion = velocity * delta

	if is_colliding():
        var n = get_collision_normal()
        motion = n.slide(motion)
        velocity = n.slide(velocity)

	move(motion)


##=================================
## States
##=================================
## Idle
func _on_idle_state():
	# Change to attack - when Z is pressed
	if Controls.attack_key_pressed():
		sm.change_to("attack")
		return

	# Change to defend - when X is pressed
	if Controls.defend_key_pressed():
		sm.change_to("defend")
		return

	# Dash / Brake guard - when Space pressed
	if Controls.dash_key_pressed():
		sm.change_to("dash")
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
	velocity.x = velocity.x / 4

	if not anim_node.get_current_animation() == "defend":
		anim_node.play("defend")

	# Change to attack - when Z is pressed
	if Controls.attack_key_pressed():
		sm.change_to("attack")

	# Change to defend - when X is RELEASED
	if not Controls.defend_key_pressed():
		sm.change_to("idle")


func _on_dash_state():
	if dash_count == 0:
		anim_node.play("dash")
		velocity.x = 500

	dash_count += get_fixed_process_delta_time()

	if dash_count >= DASH_TIME:
		anim_node.stop()
		dash_count = 0
		velocity.x = 0

		sm.change_to("idle")

## Move
func read_move_inputs():
	var direction = get_direction()
	velocity.x = MOVE_SPEED * direction.x

func get_direction():
	var x = Controls.right_key_pressed() + (-Controls.left_key_pressed())

	return Vector2(x, 0)