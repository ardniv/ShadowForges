extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var interaction_area = $InteractionArea

var player_nearby = false
var player = null
var upgrade_menu = null

func _ready() -> void:
	if interaction_area:
		var collision_shape = interaction_area.get_node_or_null("CollisionShape2D")
		if collision_shape and collision_shape.disabled:
			collision_shape.disabled = false
	if animated_sprite:
		animated_sprite.play("idle")

func _physics_process(_delta: float) -> void:
	if player_nearby and Input.is_action_just_pressed("interact") and not upgrade_menu:
		if player:
			var menu_scene = preload("res://scenes/upgrade_menu.tscn")
			upgrade_menu = menu_scene.instantiate()
			upgrade_menu.set_player(player)
			get_tree().root.add_child(upgrade_menu)
			upgrade_menu.menu_closed.connect(_on_menu_closed)

func _on_menu_closed() -> void:
	if player:
		player.save_game()
	upgrade_menu = null

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Char":
		player_nearby = true
		player = body

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Char":
		player_nearby = false
		player = null
