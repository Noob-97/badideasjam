extends RigidBody3D
class_name RBBox

@onready var PlayerNode: Player = get_node("/root/Node3D/Player")
var maintain_local_pos = false

func _ready() -> void:
	PlayerNode.ChangedGravity.connect(change_gravity)
	
func change_gravity():
	gravity_scale = - gravity_scale

func _physics_process(delta: float) -> void:
	if maintain_local_pos:
		position = Vector3.ZERO
