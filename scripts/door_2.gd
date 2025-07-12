extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var collision = get_node_or_null("CollisionShape2D")
	if collision:
		print("Door2 collision: Position:", global_position, "Shape Extents:", collision.shape.extents)
	else:
		print("Error: Door2 missing CollisionShape2D")

func _on_body_entered(body: Node) -> void:
	if body.name == "Char":
		trigger_to_be_continued()
		print("Char entered Door2 at:", global_position)
	else:
		print("Non-Char body entered Door2:", body.name)

func trigger_to_be_continued() -> void:
	var to_be_continued_scene = preload("res://scenes/to_be_continued.tscn")
	var to_be_continued = to_be_continued_scene.instantiate()
	if get_parent() and is_inside_tree():
		get_parent().add_child(to_be_continued)
		if to_be_continued.is_inside_tree():
			print("ToBeContinued UI triggered at Door2 position:", global_position)
		else:
			print("Error: ToBeContinued UI not in scene tree")
	else:
		print("Error: Cannot show ToBeContinued UI, Door2 not in scene tree")
