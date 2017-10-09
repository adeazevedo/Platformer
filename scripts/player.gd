extends KinematicBody2D

var StateMachine = preload("res://scripts/StateMachine.gd")
onready var sm = StateMachine.new(self)

const GRAVITY = 300.0
const BASE_MOVE_SPEED = 140

var face = 1
var velocity = Vector2()

var can_attack = true
var can_dash = true

onready var anim_node = get_node("AnimationPlayer")
onready var attack_timer = get_node("AttackTimer")
onready var dash_timer = get_node("DashTimer")
onready var dash_cooldown = get_node("DashCooldown")

func _ready():
	sm.add("idle", "_on_idle_state")
	sm.add("attack", "_on_attack_state")
	sm.add("defend", "_on_defend_state")
	sm.add("dash", "_on_dash_state")

	sm.initial("idle")

	attack_timer.connect("timeout", self, "_on_attack_end")
	dash_timer.connect("timeout", self, "_on_dash_end")
	dash_cooldown.connect("timeout", self, "_on_dash_cooldown_end")

	set_fixed_process(true)


func _fixed_process(delta):
	read_inputs()
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
	if Controls.dash_key_pressed() and can_dash:
		sm.change_to("dash")
		return

	if not anim_node.get_current_animation() == "idle":
		anim_node.play("idle")


## Attack
func _on_attack_state():
	velocity.x = velocity.x / 2

	if not anim_node.get_current_animation() == "attack":
		anim_node.play("attack")

	if not anim_node.is_playing():
		sm.change_to("idle")

func _on_attack_end():
	pass

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
	if can_dash:
		can_dash = false
		anim_node.play("dash")
		velocity.x = face * 500

		dash_timer.start()


func _on_dash_end():
	anim_node.stop()
	velocity.x = 0
	sm.change_to("idle")

	dash_cooldown.start()

func _on_dash_cooldown_end():
	can_dash = true

## Move
func read_inputs():
	var direction = get_direction()

	# Horizonatal flip
	if sm.get_current() != "defend":
		if direction.x > 0:
			get_node("Sprite").set_flip_h(false)
			face = 1
		elif direction.x < 0:
			get_node("Sprite").set_flip_h(true)
			face = -1

	if sm.get_current() != "dash":
		velocity.x = BASE_MOVE_SPEED * direction.x

func get_direction():
	var x = Controls.right_key_pressed() + (-Controls.left_key_pressed())

	return Vector2(x, 0)