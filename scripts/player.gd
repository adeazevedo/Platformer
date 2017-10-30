extends KinematicBody2D
var StateMachine = preload("res://scripts/StateMachine.gd")
onready var sm = StateMachine.new(self)

const GRAVITY = 400.0
const MAX_MOVE_SPEED = 200.0
const JUMP_FORCE = 200.0
const ACCELERATION = 500.0
const DECELERATION = 1000.0

var move_speed_mod = 1.0
var acceleration_mod = 1.0
var face = 1

var velocity = Vector2()

var hp = 10

var can_attack = true
var can_dash = true
var can_jump = true

var is_attacking = false
var is_breaking_guard = false
var is_defending = false
var is_jumping = false
var is_stagger = false

onready var anim_node = get_node("AnimationPlayer")
onready var attack_timer = get_node("AttackTimer")
onready var dash_timer = get_node("DashTimer")
onready var stagger_timer = get_node("StaggerTimer")
onready var dash_cooldown = get_node("DashCooldown")


func _ready():
	add_to_group("player")

	sm.add("idle", "_on_idle_state")
	sm.add("attack", "_on_attack_state")
	sm.add("defend", "_on_defend_state")
	sm.add("dash", "_on_dash_state")
	sm.add("jump", "_on_jump_state")
	sm.add("stagger", "_on_stagger_state")

	sm.initial("idle")

	attack_timer.connect("timeout", self, "_on_attack_end")
	dash_timer.connect("timeout", self, "_on_dash_end")
	stagger_timer.connect("timeout" ,self, "_on_stagger_end")
	dash_cooldown.connect("timeout", self, "_on_dash_cooldown_end")

	get_node("AttackCollision").deactivate()
	get_node("DashCollision").deactivate()

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

		get_node("Label").set_text(str(velocity))

		can_jump = true
		is_jumping = false

	move(motion)


func calc_atk():
	return 1

func apply_dmg( value ):
	print("Jogador recebeu ", value, " dano")
	hp -= value
	sm.change_to("stagger")

func stagger():
	is_attacking = false
	is_defending = false
	is_breaking_guard = false

	get_node("AttackCollision").deactivate()
	get_node("DashCollision").deactivate()

	attack_timer.call_deferred("stop")

	sm.change_to("stagger")

##=================================
## States
##=================================
## Idle
func _on_idle_state():
	# Change to attack - when Z is pressed
	if can_attack and Controls.attack_key_pressed():
		sm.change_to("attack")
		return

	# Dash / Break guard - when Space pressed
	if can_dash and Controls.break_key_pressed():
		sm.change_to("dash")
		return

	# Change to defend - when X is pressed
	if Controls.defend_key_pressed():
		sm.change_to("defend")
		return

	if can_jump && Controls.jump_key_pressed():
		sm.change_to("jump")
		return

	if not anim_node.get_current_animation() == "idle":
		anim_node.play("idle")


## Attack
func _on_attack_state():
	move_speed_mod = 1.0 / 2.0

	if can_attack:
		can_attack = false
		is_attacking = true

		anim_node.play("attack")
		attack_timer.start()

func _on_attack_end():
	can_attack = true
	is_attacking = false
	move_speed_mod = 1
	get_node("AttackCollision").deactivate()
	sm.change_to("idle")


## Defend
func _on_defend_state():
	move_speed_mod = 1.0 / 4.0
	is_defending = true

	if not anim_node.get_current_animation() == "defend":
		anim_node.play("defend")

	# Change to attack - when Z is pressed
	if Controls.attack_key_pressed():
		is_defending = false

		sm.change_to("attack")

	# Change to defend - when X is RELEASED
	if not Controls.defend_key_pressed():
		is_defending = false
		move_speed_mod = 1.0
		sm.change_to("idle")


func _on_dash_state():
	if can_dash:
		can_dash = false
		is_breaking_guard = true

		get_node("DashCollision").activate()

		anim_node.play("dash")
		acceleration_mod = 10.0
		move_speed_mod = 3.0

		dash_timer.start()

func _on_dash_end():
	move_speed_mod = 1.0
	acceleration_mod = 1.0
	is_breaking_guard = false

	anim_node.stop()

	get_node("DashCollision").deactivate()

	dash_cooldown.start()

	sm.change_to("idle")

func _on_dash_cooldown_end():
	can_dash = true


func _on_jump_state():
	velocity.y = velocity.y - JUMP_FORCE

	if can_jump:
		can_jump = false
		is_jumping = true

		sm.change_to("idle")


func _on_stagger_state():
	move_speed_mod = 3.0 / 4.0

	if !is_stagger:
		is_stagger = true
		anim_node.play("stagger")
		stagger_timer.start()

func _on_stagger_end():
	is_stagger = false
	can_attack = true
	move_speed_mod = 1.0
	sm.change_to("idle")


## Move
func read_inputs():
	var direction = get_direction()
	var speed = abs(velocity.x)

	# Horizonatal flip
	if direction != 0:
		speed += ACCELERATION * acceleration_mod * get_process_delta_time()

		if !is_defending and !is_attacking and !is_breaking_guard:
			face = direction

	else:
		speed -= DECELERATION * acceleration_mod * get_process_delta_time()

	# if dashing then force movement
	if is_breaking_guard:
		speed = MAX_MOVE_SPEED * move_speed_mod

	set_scale(Vector2(face, 1))
	speed = clamp(speed, 0, MAX_MOVE_SPEED * move_speed_mod)

	velocity.x = face * speed

func get_direction():
	return Controls.right_key_pressed() + (-Controls.left_key_pressed())
