extends Area3D
class_name ActivationButton

signal ConditionUpdated(value)
@export var condition : bool
@export var Negation: bool

func _ready() -> void:
	body_entered.connect(CHECK_BODIES)
	body_exited.connect(CHECK_BODIES)

func CHECK_BODIES(body):
	var bodies = get_overlapping_bodies()
	var found := Negation
	for i in bodies:
		if i is RBBox or i is Player:
			found = not Negation
	condition = found
	ConditionUpdated.emit(condition)
