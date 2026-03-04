extends RigidBody3D
class_name RBBox

@onready var PlayerNode: Player = get_node("/root/Node3D/Player")
@export var Throwable := false
@export var mesh: MeshInstance3D
@export var orange: StandardMaterial3D
@export var blue: StandardMaterial3D
var maintain_local_pos = false

func _ready() -> void:
	PlayerNode.ChangedGravity.connect(change_gravity)
	UPDATE_COLORS()
	
func change_gravity():
	gravity_scale = - gravity_scale
	UPDATE_COLORS()

func UPDATE_COLORS():
	if gravity_scale == 1.0:
		mesh.mesh.surface_set_material(0, orange)
	if gravity_scale == -1.0:
		mesh.mesh.surface_set_material(0, blue)

func _physics_process(delta: float) -> void:
	if maintain_local_pos:
		position = Vector3.ZERO
