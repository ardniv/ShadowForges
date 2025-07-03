extends CanvasLayer

@onready var name_label = $Panel/TextContainer/NameLabel
@onready var dialog_text = $Panel/TextContainer/DialogText
@onready var portrait = $Panel/Portrait

var dialogs = [
	{"name": "Mysterious Guide", "text": "Welcome, brave soul, to this perilous world."},
	{"name": "Mysterious Guide", "text": "Your journey begins at the edge of fate."},
	{"name": "Mysterious Guide", "text": "Use 'A' to move LEFT and 'D' to move RIGHT."},
	{"name": "Mysterious Guide", "text": "Use 'LEFT CLICK' to ATACK the enemy."},
	{"name": "Mysterious Guide", "text": "Use 'E' to INTERACT."},
	{"name": "Mysterious Guide", "text": "Press E or click to continue your adventure."}
]
var current_dialog_index = 0

func _ready() -> void:
	visible = false
	set_process_input(false)
	if not name_label or not dialog_text or not portrait:
		print("Error: Dialog nodes not found")
	else:
		portrait.texture = load("res://character_portrait.png")
		print("Dialog ready, waiting for show_dialog()")

func _input(event: InputEvent) -> void:
	if visible and (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event.is_action_pressed("interact")):
		advance_dialog()
		print("Dialog advanced: click or E pressed")

func show_dialog() -> void:
	if not is_inside_tree():
		print("Error: Dialog not in scene tree")
		return
	if current_dialog_index < dialogs.size():
		name_label.text = dialogs[current_dialog_index]["name"]
		dialog_text.text = "[center]" + dialogs[current_dialog_index]["text"] + "[/center]"
		visible = true
		set_process_input(true)
		get_tree().paused = true
		print("Dialog shown: index", current_dialog_index)
	else:
		hide_dialog()
		print("Dialog completed")

func advance_dialog() -> void:
	current_dialog_index += 1
	if current_dialog_index < dialogs.size():
		name_label.text = dialogs[current_dialog_index]["name"]
		dialog_text.text = "[center]" + dialogs[current_dialog_index]["text"] + "[/center]"
		print("Dialog advanced to index:", current_dialog_index)
	else:
		hide_dialog()
		print("Dialog completed")

func hide_dialog() -> void:
	if not is_inside_tree():
		print("Error: Dialog not in scene tree")
		return
	visible = false
	set_process_input(false)
	get_tree().paused = false
	queue_free()
	#queue_free() not needed since we're reusing dialog and not instantiating it each time
	#Instead, we'll just hide it
	#queue_free()
	#emit_signal("dialog_finished")
	#player.dialog_finished()
	#dialog_finished.emit()
	
	#emit_signal("dialog_finished")
	
	#dialog_finished.emit()
	
	#player.dialog_finished()
	
	#print("Dialog hidden")
