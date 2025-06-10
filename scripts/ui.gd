extends CanvasLayer

@onready var health_bar = $HUD/Bars/HealthBar
@onready var stamina_bar = $HUD/Bars/StaminaBar
@onready var souls_label = $HUD/Bars/SoulsLabel

func _ready() -> void:
	if not health_bar:
		print("ERROR: HealthBar node not found at $HUD/Bars/HealthBar")
	if not stamina_bar:
		print("ERROR: StaminaBar node not found at $HUD/Bars/StaminaBar")
	if not souls_label:
		print("ERROR: SoulsLabel node not found at $HUD/Bars/SoulsLabel")

func set_health(value: float, max_value: float) -> void:
	if health_bar:
		health_bar.value = (value / max_value) * 100

func set_stamina(value: float, max_value: float) -> void:
	if stamina_bar:
		stamina_bar.value = (value / max_value) * 100

func set_souls(value: int) -> void:
	if souls_label:
		souls_label.text = "Souls: %d" % value
	else:
		print("ERROR: Cannot set souls, SoulsLabel missing")
