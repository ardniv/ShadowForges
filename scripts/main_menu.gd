extends CanvasLayer

@onready var start_button = $MenuContainer/StartButton
@onready var load_button = $MenuContainer/LoadButton
@onready var exit_button = $MenuContainer/ExitButton
@onready var description_button = $DescriptionButton

var popup_instance = null

func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	if description_button:
		description_button.pressed.connect(_on_description_pressed)
	else:
		print("Error: DescriptionButton not found in main menu")
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

func _on_description_pressed() -> void:
	if not popup_instance:
		var popup_scene = preload("res://scenes/popup_description.tscn")
		popup_instance = popup_scene.instantiate()
		add_child(popup_instance)
		# Connect the close button to hide the pop-up
		popup_instance.get_node("Panel/CloseButton").pressed.connect(_on_popup_close)
		# Optional: Add click-outside-to-close
		popup_instance.get_node("Panel").gui_input.connect(_on_panel_input)

func _on_popup_close() -> void:
	if popup_instance:
		popup_instance.queue_free()
		popup_instance = null

func _on_panel_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not popup_instance.get_node("Panel").get_global_rect().has_point(event.position):
			_on_popup_close()
