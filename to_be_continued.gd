extends CanvasLayer

@onready var main_menu_button = $Panel/VBoxContainer/MainMenuButton

func _ready() -> void:
	if not main_menu_button:
		print("Error: MainMenuButton not found")
	else:
		main_menu_button.pressed.connect(_on_main_menu_button_pressed)
		get_tree().paused = true
		visible = true
		print("ToBeContinued UI shown, game paused")

func _on_main_menu_button_pressed() -> void:
	print("Main Menu Button Pressed")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	print("Returning to main menu")
