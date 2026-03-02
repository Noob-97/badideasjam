extends Area3D

@export var DamagePerHit := 100.0

func _ready() -> void:
	body_entered.connect(DamagePlayer)

func DamagePlayer(body):
	if body is Player:
		body.char_component.damage(DamagePerHit)
