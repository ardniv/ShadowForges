extends CanvasLayer

@onready var start_button = $MenuContainer/StartButton
@onready var load_button = $MenuContainer/LoadButton
@onready var exit_button = $MenuContainer/ExitButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	var save_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).path_join("MyPlatformer").path_join("savegame.save")
	load_button.disabled = not FileAccess.file_exists(save_path)
	start_button.grab_focus()

func _on_start_button_pressed() -> void:
	var game_scene = preload("res://scenes/game.tscn")
	var game_instance = game_scene.instantiate()
	get_tree().root.add_child(game_instance)
	var player = game_instance.get_node_or_null("Char")
	if player:
		player.is_new_game = true
		player.reset_stats()
	get_tree().current_scene = game_instance
	queue_free()

func _on_load_button_pressed() -> void:
	var game_scene = preload("res://scenes/game.tscn")
	var game_instance = game_scene.instantiate()
	get_tree().root.add_child(game_instance)
	var player = game_instance.get_node_or_null("Char")
	if player:
		player.is_new_game = false
		player.load_game()
	get_tree().current_scene = game_instance
	queue_free()

func _on_exit_button_pressed() -> void:
	get_tree().quit()
