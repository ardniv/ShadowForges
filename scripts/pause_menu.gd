extends CanvasLayer

@onready var resume_button = $MenuContainer/ResumeButton
@onready var main_menu_button = $MenuContainer/MainMenuButton
@onready var quit_button = $MenuContainer/QuitButton
@onready var menu_container = $MenuContainer

func _ready() -> void:
	visible = false
	set_process_input(false)
	if not menu_container:
		print("Error: MenuContainer not found")
	print("Pause menu ready")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and visible:
		if not menu_container:
			print("Error: MenuContainer is null")
			return
		var global_pos = event.position
		print("Mouse clicked at global:", global_pos)
		for button in [resume_button, main_menu_button, quit_button]:
			if button and button.get_global_rect().has_point(global_pos):
				print("Click inside button:", button.name)

func show_menu() -> void:
	if not is_inside_tree():
		print("Error: Pause menu not in scene tree")
		return
	resume_button.pressed.connect(_on_resume_button_pressed, CONNECT_ONE_SHOT)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed, CONNECT_ONE_SHOT)
	quit_button.pressed.connect(_on_quit_button_pressed, CONNECT_ONE_SHOT)
	resume_button.mouse_filter = Control.MOUSE_FILTER_STOP
	main_menu_button.mouse_filter = Control.MOUSE_FILTER_STOP
	quit_button.mouse_filter = Control.MOUSE_FILTER_STOP
	resume_button.focus_mode = Control.FOCUS_ALL
	main_menu_button.focus_mode = Control.FOCUS_ALL
	quit_button.focus_mode = Control.FOCUS_ALL
	get_tree().paused = true
	visible = true
	set_process_input(true)
	if resume_button:
		resume_button.grab_focus()
	else:
		print("Error: ResumeButton not found")
	print("Pause menu shown")

func hide_menu() -> void:
	if not is_inside_tree():
		print("Error: Pause menu not in scene tree")
		return
	get_tree().paused = false
	visible = false
	set_process_input(false)
	print("Pause menu hidden")

func _on_resume_button_pressed() -> void:
	hide_menu()
	print("Resume button pressed")

func _on_main_menu_button_pressed() -> void:
	if not is_inside_tree():
		print("Error: Pause menu not in scene tree")
		return
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	print("Main Menu button pressed")

func _on_quit_button_pressed() -> void:
	if not is_inside_tree():
		print("Error: Pause menu not in scene tree")
		return
	get_tree().quit()
	print("Quit button pressed")
