extends CanvasLayer

@onready var try_again_button = $MenuContainer/TryAgainButton
@onready var main_menu_button = $MenuContainer/MainMenuButton
@onready var menu_container = $MenuContainer

var player = null

func _ready() -> void:
	visible = false
	set_process_input(false)
	if not menu_container:
		print("Error: MenuContainer not found")
	if try_again_button:
		try_again_button.pressed.connect(_on_try_again_button_pressed, CONNECT_ONE_SHOT)
		try_again_button.mouse_filter = Control.MOUSE_FILTER_STOP
		try_again_button.focus_mode = Control.FOCUS_ALL
	else:
		print("Error: TryAgainButton not found")
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_button_pressed, CONNECT_ONE_SHOT)
		main_menu_button.mouse_filter = Control.MOUSE_FILTER_STOP
		main_menu_button.focus_mode = Control.FOCUS_ALL
	else:
		print("Error: MainMenuButton not found")
	print("Death menu ready")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and visible:
		var global_pos = event.position
		print("Mouse clicked at global:", global_pos)
		if menu_container:
			for button in [try_again_button, main_menu_button]:
				if button and button.get_global_rect().has_point(global_pos):
					print("Click inside button:", button.name)

func show_menu(p: Node) -> void:
	if not is_inside_tree():
		print("Error: Death menu not in scene tree")
		return
	player = p
	if not player:
		print("Error: Player reference is null")
		return
	get_tree().paused = true
	visible = true
	set_process_input(true)
	if try_again_button:
		try_again_button.grab_focus()
	else:
		print("Error: TryAgainButton not found")
	# Reconnect signals to ensure they’re active
	if try_again_button and not try_again_button.pressed.is_connected(_on_try_again_button_pressed):
		try_again_button.pressed.connect(_on_try_again_button_pressed, CONNECT_ONE_SHOT)
	if main_menu_button and not main_menu_button.pressed.is_connected(_on_main_menu_button_pressed):
		main_menu_button.pressed.connect(_on_main_menu_button_pressed, CONNECT_ONE_SHOT)
	print("Death menu shown")

func hide_menu() -> void:
	if not is_inside_tree():
		print("Error: Death menu not in scene tree")
		return
	get_tree().paused = false
	visible = false
	set_process_input(false)
	player = null
	print("Death menu hidden")

func _on_try_again_button_pressed() -> void:
	if not player:
		print("Error: Player reference is null in Try Again")
		return
	if player.is_new_game:
		player.reset_stats()
		print("Try Again: Reset stats for new game")
	else:
		player.load_game()
		print("Try Again: Loaded save game")
	hide_menu()
	print("Try Again button pressed")

func _on_main_menu_button_pressed() -> void:
	if not is_inside_tree():
		print("Error: Death menu not in scene tree")
		return
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	print("Main Menu button pressed")
