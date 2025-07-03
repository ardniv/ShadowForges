extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_hitbox = $AttackHitbox
@onready var attack_hitbox_shape = $AttackHitbox/CollisionShape2D
@onready var detection_area = $DetectionArea

const SPEED = 100.0
const DETECTION_RANGE = 200.0
const ATTACK_RANGE = 80.0
const ATTACK_COOLDOWN = 1.5
const RETURN_THRESHOLD = 5.0
const SOULS_REWARD = 10

var health = 3
var is_dead = false
var is_following = false
var is_attacking = false
var attack_cooldown = 0.0
var player = null
var initial_position = Vector2.ZERO
var is_returning = false

func _ready() -> void:
	animated_sprite.play("idle")
	attack_hitbox_shape.disabled = true
	initial_position = global_position
	if detection_area:
		var shape_node = detection_area.get_node_or_null("CollisionShape2D")
		if shape_node and shape_node.shape is CircleShape2D:
			shape_node.shape.radius = DETECTION_RANGE

func _physics_process(delta: float) -> void:
	if is_dead or animated_sprite.animation == "hurt":
		velocity.x = 0
		return

	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			attack_hitbox_shape.disabled = true
			animated_sprite.play("idle")
		velocity.x = 0
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_following and player and not is_attacking:
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player > ATTACK_RANGE:
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * SPEED
			animated_sprite.flip_h = direction.x < 0
			attack_hitbox_shape.position.x = (30 if not animated_sprite.flip_h else -30)
			animated_sprite.play("run")
			is_returning = false
		else:
			velocity.x = 0
			if attack_cooldown <= 0.0:
				start_attack()
			else:
				attack_cooldown -= delta
	elif not is_following and not is_attacking:
		var distance_to_initial = global_position.distance_to(initial_position)
		if distance_to_initial > RETURN_THRESHOLD:
			var direction = (initial_position - global_position).normalized()
			velocity.x = direction.x * SPEED
			animated_sprite.flip_h = direction.x < 0
			attack_hitbox_shape.position.x = (30 if not animated_sprite.flip_h else -30)
			animated_sprite.play("run")
			is_returning = true
		else:
			velocity.x = 0
			is_returning = false
			animated_sprite.play("idle")

	move_and_slide()

func start_attack() -> void:
	if attack_hitbox_shape and animated_sprite.sprite_frames.has_animation("attack"):
		is_attacking = true
		attack_cooldown = ATTACK_COOLDOWN
		attack_hitbox_shape.disabled = false
		animated_sprite.play("attack")
		attack_hitbox_shape.position.x = (30 if not animated_sprite.flip_h else -30)

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Char" and body.collision_layer & (1 << (2-1)):
		player = body
		is_following = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.name == "Char":
		player = null
		is_following = false

func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Char" and is_attacking:
		body.take_damage(1)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "AttackHitbox" and not is_dead:
		if area.get_parent().get_parent().has_method("get_stat_value"):
			var damage = area.get_parent().get_parent().get_stat_value("attack")
			health -= damage
		else:
			health -= 1
		if health <= 0:
			is_dead = true
			animated_sprite.play("death")
			if player:
				player.add_souls(SOULS_REWARD)
		else:
			if animated_sprite.sprite_frames.has_animation("hurt"):
				animated_sprite.play("hurt")
			else:
				animated_sprite.play("idle")

func _on_hitbox_area_exited(area: Area2D) -> void:
	if area.name == "AttackHitbox" and not is_dead and animated_sprite.animation != "hurt" and animated_sprite.animation != "death":
		animated_sprite.play("idle")

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "hurt" and not is_dead:
		animated_sprite.play("idle")
	if animated_sprite.animation == "attack":
		is_attacking = false
		attack_hitbox_shape.disabled = true
		animated_sprite.play("idle")
		attack_cooldown = max(attack_cooldown, 0.5)
	if animated_sprite.animation == "death":
		queue_free()
