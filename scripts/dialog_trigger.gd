extends Area2D

@onready var dialog_scene = preload("res://scenes/dialog.tscn")
var dialog_instance = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var collision = get_node_or_null("CollisionShape2D")
	if collision:
		print("DialogTrigger collision: Position:", global_position, "Shape Extents:", collision.shape.extents)
	else:
		print("Error: DialogTrigger missing CollisionShape2D")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("trigger_dialog"):
		print("Player entered DialogTrigger at:", global_position)
		body.trigger_dialog()
	else:
		print("Non-player body entered DialogTrigger:", body)
