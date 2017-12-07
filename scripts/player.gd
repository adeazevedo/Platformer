
extends "res://scripts/PlayerEntity.gd"

var state = {
	idle			= funcref(self, "_on_idle_state"),
	attack		= funcref(self, "_on_attack_state"),
	defend		= funcref(self, "_on_defend_state"),
	break_guard	= funcref(self, "_on_break_state"),
	jump			= funcref(self, "_on_jump_state"),
	stagger		= funcref(self, "_on_stagger_state"),
}
var next_state = "idle"

var move_speed_mod = 1.0

var is_stagger = false

onready var anim_node = get_node("AnimationPlayer")


func _ready():
	get_node("AttackCollision").deactivate()
	get_node("DashCollision").deactivate()

	set_fixed_process(true)


func _fixed_process(delta):
	read_inputs()
	state[next_state].call_func()

	# Gravity
	velocity = accept( get_node("GravityEffect") )

	var motion = velocity * delta

	if is_colliding():
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)

		get_node("PlayerJumpTrait").can_jump = true
		get_node("PlayerJumpTrait").is_jumping = false

	move(motion)


func accept (trait, args = self):
	return trait.execute(args)


func calc_atk():
	return 1

func stagger():
	get_node("PlayerAttackTrait").is_attacking = false
	get_node("PlayerDefendTrait").is_defending = false
	get_node("PlayerBreakTrait").is_breaking_guard = false

	get_node("AttackCollision").deactivate()
	get_node("DashCollision").deactivate()

	get_node("PlayerAttackTrait").stop_timer()

	next_state = "stagger"

##=================================
## States
##=================================
## Idle
func _on_idle_state():
	# Change to attack - when Z is pressed
	if can_attack() and Controls.is_attack_key_pressed():
		next_state = "attack"

	# Dash / Break guard - when Space pressed
	elif can_break_guard() and Controls.is_break_key_pressed():
		next_state = "break_guard"

	# Change to defend - when X is pressed
	elif Controls.is_defend_key_pressed():
		next_state = "defend"

	elif can_jump() && Controls.is_jump_key_pressed():
		next_state = "jump"

	if not anim_node.get_current_animation() == "idle":
		anim_node.play("idle")

## Attack
func is_attacking():
	return get_node("PlayerAttackTrait").is_attacking

func can_attack():
	return get_node("PlayerAttackTrait").can_attack

func _on_attack_state():
	accept( get_node("PlayerAttackTrait") )


## Defend
func is_defending():
	return get_node("PlayerDefendTrait").is_defending

func _on_defend_state():
	accept( get_node("PlayerDefendTrait") )


## Break State / Dash
func can_break_guard():
	return get_node("PlayerBreakTrait").can_break_guard

func is_breaking_guard():
	return get_node("PlayerBreakTrait").is_breaking_guard

	## Break on this character manifest as a dash
func _on_break_state():
	accept( get_node("PlayerBreakTrait") )


## Jump
func can_jump():
	return get_node("PlayerJumpTrait").can_jump

func is_jumping():
	return get_node("PlayerJumpTrait").is_jumping

func _on_jump_state():
	accept( get_node("PlayerJumpTrait") )


## Stagger
func _on_stagger_state():
	move_speed_mod = 1.0 / 4.0

	if !is_stagger:
		is_stagger = true
		anim_node.play("stagger")

func _on_stagger_end():
	is_stagger = false
	#can_attack = true
	move_speed_mod = 1.0

	next_state = "idle"

## Move
var last_direction = 1
func read_inputs():
	var direction = get_direction()
	var speed = abs(velocity.x)

	if direction != 0:
		if speed == 0 or last_direction == direction:
			speed += ACCELERATION * get_fixed_process_delta_time()

			last_direction = direction
			if !is_defending() and !is_attacking() and !is_breaking_guard():
				face = direction
				set_scale(Vector2(last_direction, 1))

	if direction == 0 or (direction != 0 and direction != last_direction):
		speed -= DECELERATION * get_fixed_process_delta_time()

	if is_breaking_guard():
		speed = MAX_MOVE_SPEED * move_speed_mod

	speed = clamp(speed, 0, MAX_MOVE_SPEED * move_speed_mod)

	velocity.x = last_direction * speed


func get_direction():
	return Controls.is_right_key_pressed() + (-Controls.is_left_key_pressed())


func _on_AttackCollision_body_enter( body ):
	body.combat_process(self)
