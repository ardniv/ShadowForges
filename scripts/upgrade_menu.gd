extends CanvasLayer

@onready var souls_label = $Panel/Menu/SoulsLabel
@onready var health_button = $Panel/Menu/HealthButton
@onready var stamina_button = $Panel/Menu/StaminaButton
@onready var attack_button = $Panel/Menu/AttackButton

var player = null

func _ready() -> void:
	hide()

func open(player_ref: Node2D) -> void:
	player = player_ref
	update_souls()
	show()
	get_tree().paused = true
	print("Upgrade menu opened")

func update_souls() -> void:
	if player:
		souls_label.text = "Souls: %d" % player.souls

func _on_health_button_pressed() -> void:
	if player and player.souls >= 10:
		player.souls -= 10
		player.max_health += 1
		player.health = player.max_health
		player.update_ui()
		update_souls()
		print("Health upgraded, max_health:", player.max_health)

func _on_stamina_button_pressed() -> void:
	if player and player.souls >= 10:
		player.souls -= 10
		player.max_stamina += 20
		player.stamina = player.max_stamina
		player.update_ui()
		update_souls()
		print("Stamina upgraded, max_stamina:", player.max_stamina)

func _on_attack_button_pressed() -> void:
	if player and player.souls >= 10:
		player.souls -= 10
		player.attack_damage += 1
		player.update_ui()
		update_souls()
		print("Attack upgraded, attack_damage:", player.attack_damage)

func _on_save_button_pressed() -> void:
	if player:
		player.save_game()
		print("Game saved")

func _on_close_button_pressed() -> void:
	hide()
	get_tree().paused = false
	if player:
		player.close_upgrade_menu()
		print("Upgrade menu closed")
