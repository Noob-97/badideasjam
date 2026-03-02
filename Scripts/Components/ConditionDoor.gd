extends Node3D

@export var Conditions: Array[bool]
@export var Triggers: Array[ActivationButton]
@export var AnimationController: AnimationPlayer
var opened := false

func _ready() -> void:
	for i in Triggers.size():
		Triggers[i].ConditionUpdated.connect(UpdateCondition.bind(i))

func UpdateCondition(value, index):
	Conditions[index] = value
	CHECK_CONDITIONS()

func CHECK_CONDITIONS():
	if Conditions.find(false) == -1 and not opened:
		AnimationController.play("opening", -1, 1, false)
		opened = true
	elif Conditions.find(false) != -1 and opened:
		AnimationController.play("opening", -1, -1, true)
		opened = false
