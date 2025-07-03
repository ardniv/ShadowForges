extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if monitoring and monitorable:
		var shape = $CollisionShape2D.shape if $CollisionShape2D else null
		var extents = shape.extents if shape is RectangleShape2D else Vector2.ZERO
		print("Kill zone initialized, Monitoring:", monitoring, "Monitorable:", monitorable, "Position:", global_position, "Shape Extents:", extents)
	else:
		print("Error: Kill zone misconfigured, Monitoring:", monitoring, "Monitorable:", monitorable)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") or body.name == "Char":
		print("Player detected in kill zone, Name:", body.name, "Position:", body.global_position, "In group 'player':", body.is_in_group("player"))
		if body.has_method("take_damage"):
			body.take_damage(1000) # Large damage to ensure death
			print("take_damage(1000) called on player")
		else:
			print("Error: Player lacks take_damage method")
	else:
		print("Non-player body entered kill zone, Name:", body.name)
