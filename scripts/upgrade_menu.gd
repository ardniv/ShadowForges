extends CanvasLayer

signal menu_closed

@onready var souls_label = $Panel/VBoxContainer/SoulsLabel
@onready var attack_button = $Panel/VBoxContainer/AttackButton
@onready var dash_button = $Panel/VBoxContainer/DashButton
@onready var health_button = $Panel/VBoxContainer/HealthButton
@onready var close_button = $Panel/VBoxContainer/CloseButton

const UPGRADE_COST = 10

var player = null

func _ready() -> void:
	if player:
		update_souls_label()
		attack_button.pressed.connect(_on_attack_button_pressed)
		dash_button.pressed.connect(_on_dash_button_pressed)
		health_button.pressed.connect(_on_health_button_pressed)
		close_button.pressed.connect(_on_close_button_pressed)
		close_button.grab_focus()

func set_player(p: Node) -> void:
	player = p
	if is_inside_tree():
		update_souls_label()

func update_souls_label() -> void:
	if player and souls_label:
		souls_label.text = "Souls: %d" % player.get_souls()

func _on_attack_button_pressed() -> void:
	if player and player.get_souls() >= UPGRADE_COST:
		player.upgrade_stat("attack")
		player.add_souls(-UPGRADE_COST)
		update_souls_label()

func _on_dash_button_pressed() -> void:
	if player and player.get_souls() >= UPGRADE_COST:
		player.upgrade_stat("dash_stamina")
		player.add_souls(-UPGRADE_COST)
		update_souls_label()

func _on_health_button_pressed() -> void:
	if player and player.get_souls() >= UPGRADE_COST:
		player.upgrade_stat("health")
		player.add_souls(-UPGRADE_COST)
		update_souls_label()

func _on_close_button_pressed() -> void:
	emit_signal("menu_closed")
	queue_free()
