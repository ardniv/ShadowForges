extends CanvasLayer

@onready var timer = $Timer

func _ready() -> void:
	var t = Timer.new()
	t.name = "Timer"
	t.wait_time = 3.0
	t.one_shot = true
	t.timeout.connect(_on_timer_timeout)
	add_child(t)
	t.start()

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
