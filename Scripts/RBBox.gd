extends RigidBody3D
class_name RBBox

@onready var PlayerNode: Player = get_node("/root/Node3D/Player")
@export var InverseGravity := false
@export var Throwable := false
@export_range(0, 3, 0.2) var Weight := 1.0
@export var mesh: MeshInstance3D
var maintain_local_pos = false

func _ready() -> void:
	PlayerNode.ChangedGravity.connect(change_gravity)
	gravity_scale = Weight
	UPDATE_COLORS()
	if InverseGravity:
		change_gravity()
	
func change_gravity():
	gravity_scale = - gravity_scale
	UPDATE_COLORS()

func UPDATE_COLORS():
	var positive_color = Color(1.158, 0.665, 0.0, 1.0)
	var negative_color = Color(0.0, 0.86, 1.245, 1.0)
	var result_color = Color.WHITE
	var color_apply = abs(gravity_scale)
	var grayness = 1 - color_apply
	positive_color = positive_color * color_apply
	negative_color = negative_color * color_apply
	result_color = result_color * grayness
	if gravity_scale > 0:
		result_color = Color((result_color.r + positive_color.r) / 2, (result_color.g + positive_color.g) / 2, (result_color.b + positive_color.b) / 2, 1)
	if gravity_scale < 0:
		result_color = Color((result_color.r + negative_color.r) / 2, (result_color.g + negative_color.g) / 2, (result_color.b + negative_color.b) / 2, 1)
	var mat = StandardMaterial3D.new()
	
	if Throwable:
		if gravity_scale > 0:
			result_color = Color(0.921, 0.37, 0.642, 1.0)
		if gravity_scale < 0:
			result_color = Color(0.286, 0.69, 0.469, 1.0)
	mat.albedo_color = result_color
	mesh.mesh.surface_set_material(0, mat)

func _physics_process(delta: float) -> void:
	if maintain_local_pos:
		position = Vector3.ZERO
