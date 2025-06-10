extends CharacterBody2D

const SPEED = 300.0
const DASH_SPEED = 600.0
const JUMP_VELOCITY = -400.0
const DASH_DURATION = 0.2
const ATTACK_DURATION = 0.5
const INVULNERABILITY_DURATION = 1.0
const MAX_STAMINA = 100.0
const DASH_STAMINA_COST = 50.0
const STAMINA_REGEN_RATE = 50.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_hitbox = $AttackHitbox/CollisionShape2D
@onready var ui = get_node("/root/Game/UI")

var health = 3
var max_health = 3
var stamina = MAX_STAMINA
var souls = 0
var is_dashing = false
var dash_timer = 0.0
var is_attacking = false
var attack_timer = 0.0
var is_invulnerable = false
var invulnerability_timer = 0.0
var is_hurt = false
var is_at_bonfire = false
var current_bonfire = null

func _ready() -> void:
	if not animated_sprite:
		print("ERROR: AnimatedSprite2D node not found")
	if not animated_sprite.sprite_frames.has_animation("hurt"):
		print("ERROR: 'hurt' animation missing")
	if not animated_sprite.sprite_frames.has_animation("death"):
		print("ERROR: 'death' animation missing")
	if ui:
		print("UI found at /root/Game/UI, setting initial values")
		ui.set_health(health, max_health)
		ui.set_stamina(stamina, MAX_STAMINA)
		ui.set_souls(souls)
	else:
		print("ERROR: UI node not found at /root/Game/UI")
	# Defer load_game to ensure scene tree is ready
	call_deferred("load_game")

func _physics_process(delta: float) -> void:
	if is_invulnerable:
		invulnerability_timer -= delta
		if invulnerability_timer <= 0.0:
			is_invulnerable = false
			animated_sprite.modulate.a = 1.0

	if health <= 0:
		velocity.x = 0
		return

	if is_hurt or is_attacking:
		velocity.x = 0
		return

	if not is_dashing and stamina < MAX_STAMINA:
		stamina = min(stamina + STAMINA_REGEN_RATE * delta, MAX_STAMINA)
		if ui:
			ui.set_stamina(stamina, MAX_STAMINA)

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("dash") and not is_dashing and not is_attacking and stamina >= DASH_STAMINA_COST:
		is_dashing = true
		dash_timer = DASH_DURATION
		stamina -= DASH_STAMINA_COST
		if ui:
			ui.set_stamina(stamina, MAX_STAMINA)

	if Input.is_action_just_pressed("attack") and not is_attacking and not is_dashing:
		is_attacking = true
		attack_timer = ATTACK_DURATION
		attack_hitbox.disabled = false
		var facing_direction = -1 if animated_sprite.flip_h else 1
		attack_hitbox.position.x = abs(attack_hitbox.position.x) * facing_direction
		animated_sprite.play("attack")

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

	move_and_slide()

	if direction:
		animated_sprite.flip_h = direction < 0

	if health <= 0:
		return
	elif is_attacking:
		animated_sprite.play("attack")
	elif is_hurt:
		animated_sprite.play("hurt")
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

func take_damage(amount: int) -> void:
	if not is_invulnerable and health > 0:
		health -= amount
		if ui:
			ui.set_health(health, max_health)
		if health <= 0:
			animated_sprite.play("death")
			set_physics_process(false)
			print("Player died")
		else:
			is_hurt = true
			animated_sprite.play("hurt")
			is_invulnerable = true
			invulnerability_timer = INVULNERABILITY_DURATION
			animated_sprite.modulate.a = 0.5
			print("Player took damage, health:", health)

func add_souls(amount: int) -> void:
	souls += amount
	if ui:
		ui.set_souls(souls)
		print("UI updated with souls:", souls)
	else:
		print("ERROR: UI not found during add_souls")
	print("Souls gained:", amount, "Total souls:", souls)

func save_game() -> void:
	health = max_health
	stamina = MAX_STAMINA
	if ui:
		ui.set_health(health, max_health)
		ui.set_stamina(stamina, MAX_STAMINA)
		ui.set_souls(souls)
		print("UI updated during save: souls =", souls)
	else:
		print("ERROR: UI not found during save")
	var save_data = {
		"health": health,
		"max_health": max_health,
		"stamina": stamina,
		"souls": souls,
		"position": [global_position.x, global_position.y]
	}
	var dir = DirAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS))
	var subfolder = "MyPlatformer"
	var save_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).path_join(subfolder).path_join("savegame.save")
	if not dir.dir_exists(subfolder):
		dir.make_dir(subfolder)
		print("Created directory:", OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).path_join(subfolder))
	print("Saving to path:", save_path)
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Game saved at position:", global_position, "health:", health, "stamina:", stamina, "souls:", souls)
	else:
		print("ERROR: Failed to save game, error:", FileAccess.get_open_error())

func load_game() -> void:
	var save_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).path_join("MyPlatformer").path_join("savegame.save")
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		if file:
			var json = JSON.new()
			var error = json.parse(file.get_as_text())
			file.close()
			if error == OK:
				var data = json.data
				print("Loaded data:", data)
				health = data.get("health", 3)
				max_health = data.get("max_health", 3)
				stamina = data.get("stamina", MAX_STAMINA)
				souls = data.get("souls", 0)
				var pos = data.get("position", [340, -47])
				global_position = Vector2(pos[0], pos[1])
				if ui:
					ui.set_health(health, max_health)
					ui.set_stamina(stamina, MAX_STAMINA)
					ui.set_souls(souls)
					print("UI updated after load: souls =", souls)
				else:
					print("ERROR: UI not available during load")
				print("Game loaded, health:", health, "position:", global_position, "souls:", souls)
			else:
				print("ERROR: JSON parse error:", json.get_error_message())
		else:
			print("ERROR: Failed to load game, error:", FileAccess.get_open_error())
	else:
		print("No save file found at:", save_path)
		global_position = Vector2(340, -47)
		if ui:
			ui.set_souls(souls)
			print("UI updated for no save: souls =", souls)

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "hurt" and health > 0:
		is_hurt = false
		animated_sprite.play("idle")
	if animated_sprite.animation == "attack":
		is_attacking = false
		attack_hitbox.disabled = true
	if animated_sprite.animation == "death":
		print("Player removed after death animation")
		#queue_free()
