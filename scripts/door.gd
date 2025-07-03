extends Area2D

@export var teleport_position: Vector2 = Vector2(9030, -98)

var player_inside: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") or body.name == "Char":
		player_inside = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") or body.name == "Char":
		player_inside = false

func _input(event: InputEvent) -> void:
	if player_inside and event.is_action_pressed("interact") and event is InputEventKey:
		var player = get_tree().get_nodes_in_group("player")[0] if get_tree().get_nodes_in_group("player") else null
		if player:
			player.global_position = teleport_position
			player.velocity = Vector2.ZERO
