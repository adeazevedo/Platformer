extends KinematicBody2D
var StateMachine = preload("res://scripts/StateMachine.gd")
onready var sm = StateMachine.new(self)

const GRAVITY = 300.0
const BASE_MOVE_SPEED = 140

var velocity = Vector2()

var hp = 10

var can_attack = true
var can_dash = true

var is_attacking = false
var is_breaking_guard = false
var is_defending = false
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
	sm.add("stagger", "_on_stagger_state")

	sm.initial("idle")

	attack_timer.connect("timeout", self, "_on_attack_end")
	dash_timer.connect("timeout", self, "_on_dash_end")
	stagger_timer.connect("timeout" ,self, "_on_stagger_end")
	dash_cooldown.connect("timeout", self, "_on_dash_cooldown_end")

	get_node("AttackCollision").set_enable_monitoring(false)
	get_node("AttackCollision").hide()
	get_node("DefendCollision").set_enable_monitoring(false)
	get_node("DefendCollision").hide()
	get_node("DashCollision").set_enable_monitoring(false)
	get_node("DashCollision").hide()

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
	get_node("DefendCollision").deactivate()
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

	# Dash / Brake guard - when Space pressed
	if can_dash and Controls.dash_key_pressed():
		sm.change_to("dash")
		return

	# Change to defend - when X is pressed
	if Controls.defend_key_pressed():
		sm.change_to("defend")
		return

	if not anim_node.get_current_animation() == "idle":
		anim_node.play("idle")


## Attack
func _on_attack_state():
	velocity.x = velocity.x / 2

	if can_attack:
		can_attack = false
		is_attacking = true

		anim_node.play("attack")
		attack_timer.start()

func _on_attack_end():
	can_attack = true
	is_attacking = false
	get_node("AttackCollision").set_enable_monitoring(false)
	get_node("AttackCollision").hide()
	sm.change_to("idle")


## Defend
func _on_defend_state():
	velocity.x = velocity.x / 4
	is_defending = true

	get_node("DefendCollision").activate()

	if not anim_node.get_current_animation() == "defend":
		anim_node.play("defend")

	# Change to attack - when Z is pressed
	if Controls.attack_key_pressed():
		is_defending = false
		get_node("DefendCollision").deactivate()

		sm.change_to("attack")

	# Change to defend - when X is RELEASED
	if not Controls.defend_key_pressed():
		is_defending = false
		get_node("DefendCollision").deactivate()

		sm.change_to("idle")


func _on_dash_state():
	if can_dash:
		can_dash = false
		is_breaking_guard = true

		get_node("DashCollision").activate()

		anim_node.play("dash")
		velocity.x = get_scale().x * BASE_MOVE_SPEED * 3

		dash_timer.start()

func _on_dash_end():
	is_breaking_guard = false

	anim_node.stop()
	velocity.x = 0

	get_node("DashCollision").deactivate()

	dash_cooldown.start()

	sm.change_to("idle")

func _on_dash_cooldown_end():
	can_dash = true


func _on_stagger_state():
	velocity.x = velocity.x / 4

	if !is_stagger:
		is_stagger = true
		anim_node.play("stagger")
		stagger_timer.start()

func _on_stagger_end():
	is_stagger = false

	sm.change_to("idle")

## Move
func read_inputs():
	var direction = get_direction()

	# Horizonatal flip
	if !is_defending and !is_attacking and !is_breaking_guard:
		if direction.x != 0:
			set_scale(Vector2(direction.x, 1))

	if !is_breaking_guard:
		velocity.x = BASE_MOVE_SPEED * direction.x


func interrupt_attack():
	is_attacking = false
	get_node("AttackCollision").deactivate()


func get_direction():
	var h = Controls.right_key_pressed() + (-Controls.left_key_pressed())

	return Vector2(h, 0)
