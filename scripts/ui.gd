extends CanvasLayer

@onready var health_bar = $HUD/Bars/HealthBar
@onready var stamina_bar = $HUD/Bars/StaminaBar
@onready var souls_label = $HUD/Bars/SoulsLabel

func set_health(value: float, max_value: float) -> void:
	if health_bar:
		health_bar.value = (value / max_value) * 100

func set_stamina(value: float, max_value: float) -> void:
	if stamina_bar:
		stamina_bar.value = (value / max_value) * 100

func set_souls(value: int) -> void:
	if souls_label:
		souls_label.text = "Souls: %d" % value
