extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var interaction_area = $InteractionArea

var player_nearby = false
var player = null

func _ready() -> void:
	animated_sprite.play("idle")
	print("Bonfire animation playing: idle")

func _process(_delta: float) -> void:
	if player_nearby and Input.is_action_just_pressed("interact"):
		if player:
			player.save_game()
			print("Bonfire interacted, game saved")

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.name == "Char":
		player_nearby = true
		player = body
		print("Player near bonfire")

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.name == "Char":
		player_nearby = false
		player = null
		print("Player left bonfire")
