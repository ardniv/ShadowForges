extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

var health = 5
var is_dead = false

func _ready() -> void:
	animated_sprite.play("idle")

func _on_hitbox_area_entered(area: Area2D) -> void:
	print("Area entered:", area.name, ", Parent:", area.get_parent().name) # Debug
	if area.name == "AttackHitbox" and not is_dead:
		health -= 1
		print("Enemy hit, health:", health) # Debug
		if health <= 0:
			is_dead = true
			animated_sprite.play("death")
		else:
			animated_sprite.play("hurt")

func _on_hitbox_area_exited(area: Area2D) -> void:
	print("Area exited:", area.name, ", Parent:", area.get_parent().name) # Debug
	if area.name == "AttackHitbox" and not is_dead:
		animated_sprite.play("idle")

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "hurt" and not is_dead:
		animated_sprite.play("idle")
	if animated_sprite.animation == "death":
		queue_free()
