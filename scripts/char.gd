extends CharacterBody2D

const SPEED = 300.0
const DASH_SPEED = 600.0
const JUMP_VELOCITY = -400.0
const DASH_DURATION = 0.2
const ATTACK_DURATION = 0.3

@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_hitbox = $AttackHitbox/CollisionShape2D

var is_dashing = false
var dash_timer = 0.0
var is_attacking = false
var attack_timer = 0.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("dash") and not is_dashing and not is_attacking:
		is_dashing = true
		dash_timer = DASH_DURATION

	if Input.is_action_just_pressed("attack") and not is_attacking and not is_dashing:
		is_attacking = true
		attack_timer = ATTACK_DURATION
		attack_hitbox.disabled = false
		var facing_direction = -1 if animated_sprite.flip_h else 1
		attack_hitbox.position.x = abs(attack_hitbox.position.x) * facing_direction
		print("Attack started, hitbox enabled") # Debug

	var direction := Input.get_axis("move_left", "move_right")
	
	if is_dashing:
		if direction != 0:
			velocity.x = direction * DASH_SPEED
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
	else:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0.0:
			is_attacking = false
			attack_hitbox.disabled = true
			print("Attack ended, hitbox disabled") # Debug

	move_and_slide()

	if direction:
		animated_sprite.flip_h = direction < 0

	if is_attacking:
		animated_sprite.play("attack")
	elif not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
	elif is_dashing:
		animated_sprite.play("dash")
	elif direction != 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
