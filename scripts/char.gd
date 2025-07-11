extends CharacterBody2D

const SPEED = 300.0
const DASH_SPEED = 600.0
const JUMP_VELOCITY = -400.0
const DASH_DURATION = 0.2
const ATTACK_DURATION = 0.5
const INVULNERABILITY_DURATION = 1.0
const MAX_STAMINA = 100.0
const STAMINA_REGEN_RATE = 50.0
const BASE_ATTACK_DAMAGE = 1.0
const BASE_DASH_STAMINA_COST = 50.0
const BASE_MAX_HEALTH = 3
const NEW_GAME_SPAWN_POSITION = Vector2(150, -95)
const STAGE_2_SPAWN_POSITION = Vector2(1000, -95)

@onready var attack_sound_player := $AttackSound     # tangkap node audio

@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_hitbox = $AttackHitbox/CollisionShape2D
@onready var ui = get_node_or_null("/root/Game/UI")

var health = BASE_MAX_HEALTH
var max_health = BASE_MAX_HEALTH
var stamina = MAX_STAMINA
var souls = 0
var attack_damage = BASE_ATTACK_DAMAGE
var dash_stamina_cost = BASE_DASH_STAMINA_COST
var is_dashing = false
var dash_timer = 0.0
var is_attacking = false
var attack_timer = 0.0
var is_invulnerable = false
var invulnerability_timer = 0.0
var is_hurt = false
var is_dead = false
var is_at_bonfire = false
var current_bonfire = null
var is_new_game = true
var has_triggered_dialog = false
var has_triggered_door_dialog = false
var current_stage = "stage_1"
var pause_menu = null
var death_menu = null
var dialog = null
var door_dialog = null
var nearby_door = null

func _ready() -> void:
	add_to_group("player")
	if ui:
		ui.set_health(health, max_health)
		ui.set_stamina(stamina, MAX_STAMINA)
		ui.set_souls(souls)
	else:
		print("Error: UI node not found at /root/Game/UI")
	print("is_new_game:", is_new_game, "Player in group 'player':", is_in_group("player"))
	var save_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).path_join("MyPlatformer/savegame.save")
	if FileAccess.file_exists(save_path) and not is_new_game:
		load_game()
	else:
		is_new_game = true
		reset_stats()
	if animated_sprite.sprite_frames:
		print("Available animations:", animated_sprite.sprite_frames.get_animation_names())
	else:
		print("Error: AnimatedSprite2D has no SpriteFrames")
	call_deferred("_setup_menus")

func _setup_menus() -> void:
	if not is_inside_tree():
		print("Error: Char not in scene tree, retrying menu setup")
		call_deferred("_setup_menus")
		return
	var pause_menu_scene = preload("res://scenes/pause_menu.tscn")
	pause_menu = pause_menu_scene.instantiate()
	if get_parent():
		get_parent().add_child.call_deferred(pause_menu)
		pause_menu.hide()
		print("Pause menu added")
	else:
		print("Error: Char has no parent for pause menu")
	var death_menu_scene = preload("res://scenes/game_over.tscn")
	death_menu = death_menu_scene.instantiate()
	if get_parent():
		get_parent().add_child.call_deferred(death_menu)
		death_menu.hide()
		if death_menu.has_method("show_menu"):
			print("Death menu added")
		else:
			print("Error: Death menu missing show_menu method")
	else:
		print("Error: Char has no parent for death menu")

func trigger_dialog() -> void:
	if not is_new_game or has_triggered_dialog or is_dead:
		print("Dialog skipped: not new game or already triggered or dead")
		return
	has_triggered_dialog = true
	var dialog_scene = preload("res://scenes/dialog.tscn")
	dialog = dialog_scene.instantiate()
	if get_parent() and is_inside_tree():
		get_parent().add_child(dialog)
		if dialog.is_inside_tree():
			dialog.show_dialog()
			print("Dialog triggered at position:", global_position)
		else:
			dialog.call_deferred("show_dialog")
			print("Dialog deferred at position:", global_position)
	else:
		print("Error: Cannot show dialog, Char not in scene tree")

func trigger_door_dialog() -> void:
	if not is_new_game or has_triggered_door_dialog or is_dead:
		print("Door dialog skipped: not new game or already triggered or dead")
		return
	has_triggered_door_dialog = true
	#var door_dialog_scene = preload("res://scenes/dialog_door.tscn")
	#door_dialog = door_dialog_scene.instantiate()
	#if get_parent() and is_inside_tree():
		#get_parent().add_child(door_dialog)
		#if door_dialog.is_inside_tree():
			#door_dialog.show_dialog()
			#print("Door dialog triggered at position:", global_position)
		#else:
			#door_dialog.call_deferred("show_dialog")
			#print("Door dialog deferred at position:", global_position)
	#else:
		#print("Error: Cannot show door dialog, Char not in scene tree")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and event is InputEventKey and health > 0 and not is_dead:
		if pause_menu and pause_menu.is_inside_tree():
			if pause_menu.visible:
				pause_menu.hide_menu()
			else:
				pause_menu.show_menu()
		else:
			print("Error: Pause menu not ready or not in scene tree")
	if event.is_action_pressed("interact") and event is InputEventKey and health > 0 and not is_dead:
		print("Interact key (E) pressed at position:", global_position)
		if nearby_door and nearby_door.is_inside_tree():
			var target_position = nearby_door.get_target_position()
			if target_position:
				global_position = target_position
				current_stage = "stage_2" if target_position == STAGE_2_SPAWN_POSITION else "stage_1"
				print("Teleported to:", global_position, "Stage:", current_stage)
			else:
				print("Error: Door has no valid target position")
		if is_at_bonfire and current_bonfire and current_bonfire.is_inside_tree():
			var menu_scene = preload("res://scenes/upgrade_menu.tscn")
			var upgrade_menu = menu_scene.instantiate()
			if get_parent():
				get_parent().add_child.call_deferred(upgrade_menu)
				upgrade_menu.call_deferred("set_player", self)
				upgrade_menu.menu_closed.connect(_on_upgrade_menu_closed)
				get_tree().paused = true
				print("Upgrade menu opened at bonfire:", current_bonfire.global_position)
			else:
				print("Error: Cannot add upgrade menu, no parent node")

func _on_upgrade_menu_closed() -> void:
	save_game()
	get_tree().paused = false
	print("Upgrade menu closed, game saved")

func _physics_process(delta: float) -> void:
	if is_invulnerable:
		invulnerability_timer -= delta
		if invulnerability_timer <= 0.0:
			is_invulnerable = false
			animated_sprite.modulate.a = 1.0

	if is_dead or health <= 0:
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

	if Input.is_action_just_pressed("dash") and not is_dashing and not is_attacking and stamina >= dash_stamina_cost:
		is_dashing = true
		dash_timer = DASH_DURATION
		stamina -= dash_stamina_cost
		if ui:
			ui.set_stamina(stamina, MAX_STAMINA)

	if Input.is_action_just_pressed("attack") and not is_attacking and not is_dashing:
		is_attacking = true
		attack_timer = ATTACK_DURATION
		attack_hitbox.disabled = false
		var facing_direction = -1 if animated_sprite.flip_h else 1
		attack_hitbox.position.x = abs(attack_hitbox.position.x) * facing_direction
		attack_sound_player.play()
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

	if is_dead or health <= 0:
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

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("door"):
		nearby_door = area
		print("Entered door area at:", area.global_position)
	if area.is_in_group("door_dialog_trigger"):
		trigger_door_dialog()
		print("Entered door dialog trigger at:", area.global_position)

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("door"):
		nearby_door = null
		print("Exited door area at:", area.global_position)

func take_damage(amount: int) -> void:
	if not is_invulnerable and health > 0 and not is_dead:
		health -= amount
		if ui:
			ui.set_health(health, max_health)
		if health <= 0:
			is_dead = true
			animated_sprite.play("death")
			set_physics_process(false)
		else:
			is_hurt = true
			animated_sprite.play("hurt")
			is_invulnerable = true
			invulnerability_timer = INVULNERABILITY_DURATION
			animated_sprite.modulate.a = 0.5

func add_souls(amount: int) -> void:
	souls += amount
	if ui:
		ui.set_souls(souls)

func get_souls() -> int:
	return souls

func upgrade_stat(stat: String) -> void:
	match stat:
		"attack":
			attack_damage += 0.5
		"dash_stamina":
			dash_stamina_cost = max(dash_stamina_cost - 5.0, 10.0)
		"health":
			max_health += 1
			health += 1
			if ui:
				ui.set_health(health, max_health)
	is_new_game = false
	print("Stat upgraded, is_new_game set to false, stat:", stat, "attack_damage:", attack_damage, "dash_stamina_cost:", dash_stamina_cost, "max_health:", max_health)

func get_stat_value(stat: String) -> float:
	match stat:
		"attack":
			return attack_damage
		"dash_stamina":
			return dash_stamina_cost
		"health":
			return max_health
	return 0.0

func reset_stats() -> void:
	health = BASE_MAX_HEALTH
	max_health = BASE_MAX_HEALTH
	stamina = MAX_STAMINA
	souls = 0
	attack_damage = BASE_ATTACK_DAMAGE
	dash_stamina_cost = BASE_DASH_STAMINA_COST
	global_position = NEW_GAME_SPAWN_POSITION
	is_dead = false
	has_triggered_dialog = false
	has_triggered_door_dialog = false
	current_stage = "stage_1"
	if ui:
		ui.set_health(health, max_health)
		ui.set_stamina(stamina, MAX_STAMINA)
		ui.set_souls(souls)
	set_physics_process(true)
	animated_sprite.play("idle")
	is_invulnerable = false
	is_hurt = false
	is_attacking = false
	attack_hitbox.disabled = true
	animated_sprite.modulate.a = 1.0
	print("Stats reset, has_triggered_dialog:", has_triggered_dialog, "has_triggered_door_dialog:", has_triggered_door_dialog, "current_stage:", current_stage)

func save_game() -> void:
	health = max_health
	stamina = MAX_STAMINA
	if ui:
		ui.set_health(health, max_health)
		ui.set_stamina(stamina, MAX_STAMINA)
		ui.set_souls(souls)
	var save_data = {
		"health": health,
		"max_health": max_health,
		"stamina": stamina,
		"souls": souls,
		"position": [global_position.x, global_position.y],
		"attack_damage": attack_damage,
		"dash_stamina_cost": dash_stamina_cost,
		"current_scene": get_tree().current_scene.scene_file_path if get_tree().current_scene else "res://scenes/game.tscn",
		"has_triggered_dialog": has_triggered_dialog,
		"has_triggered_door_dialog": has_triggered_door_dialog,
		"current_stage": current_stage
	}
	var dir = DirAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS))
	var subfolder = "MyPlatformer"
	var save_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).path_join(subfolder).path_join("savegame.save")
	if not dir.dir_exists(subfolder):
		dir.make_dir(subfolder)
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		is_new_game = false
		print("Game saved to:", save_path, "current_scene:", save_data.current_scene, "souls:", souls, "has_triggered_dialog:", has_triggered_dialog, "has_triggered_door_dialog:", has_triggered_door_dialog, "current_stage:", current_stage)
	else:
		print("Error: Failed to save game")

func load_game() -> void:
	var save_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).path_join("MyPlatformer/savegame.save")
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		if file:
			var json = JSON.new()
			var error = json.parse(file.get_as_text())
			file.close()
			if error == OK:
				var data = json.data
				health = data.get("health", BASE_MAX_HEALTH)
				max_health = data.get("max_health", BASE_MAX_HEALTH)
				stamina = data.get("stamina", MAX_STAMINA)
				souls = data.get("souls", 0)
				attack_damage = data.get("attack_damage", BASE_ATTACK_DAMAGE)
				dash_stamina_cost = data.get("dash_stamina_cost", BASE_DASH_STAMINA_COST)
				has_triggered_dialog = data.get("has_triggered_dialog", false)
				has_triggered_door_dialog = data.get("has_triggered_door_dialog", false)
				current_stage = data.get("current_stage", "stage_1")
				var pos = data.get("position", [NEW_GAME_SPAWN_POSITION.x, NEW_GAME_SPAWN_POSITION.y])
				global_position = Vector2(pos[0], pos[1])
				if ui:
					ui.set_health(health, max_health)
					ui.set_stamina(stamina, MAX_STAMINA)
					ui.set_souls(souls)
				set_physics_process(true)
				animated_sprite.play("idle")
				is_invulnerable = false
				is_hurt = false
				is_attacking = false
				is_dead = false
				attack_hitbox.disabled = true
				animated_sprite.modulate.a = 1.0
				is_new_game = false
				print("Game loaded from:", save_path, "position:", global_position, "souls:", souls, "has_triggered_dialog:", has_triggered_dialog, "has_triggered_door_dialog:", has_triggered_door_dialog, "current_stage:", current_stage)
			else:
				print("Error: Failed to parse save file")
				reset_stats()
		else:
			print("Error: Failed to open save file")
			reset_stats()
	else:
		print("No save file found, treating as new game")
		reset_stats()

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "hurt" and health > 0:
		is_hurt = false
		animated_sprite.play("idle")
		print("Hurt animation finished")
	if animated_sprite.animation == "attack":
		is_attacking = false
		attack_hitbox.disabled = true
		animated_sprite.play("idle")
		print("Attack animation finished")
	if animated_sprite.animation == "death" and is_dead:
		if death_menu and death_menu.is_inside_tree() and death_menu.has_method("show_menu"):
			death_menu.show_menu(self)
			get_tree().paused = true
			print("Death menu shown, game paused")
		else:
			print("Error: Death menu not ready or missing show_menu method")
