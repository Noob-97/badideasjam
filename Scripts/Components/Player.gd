extends CharacterBody3D
class_name Player
@export_group("Configuration")
@export var char_component: CharacterComponent
@export var head: Node3D
@export var camera: Camera3D
@export var above: RayCast3D
@export var player_mesh: MeshInstance3D
var prev_rotation: Vector3
var prev_mouse_move: float
var jump_buffer: bool = false
var buffer_time: float = 0.1
var prev_delta: float
var rotate: bool = false

func _input(event):
	if event.is_action_pressed("unlock_mouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action("ui_cancel"):
		get_tree().quit()
func _unhandled_input(event):
	if (event is InputEventMouseMotion):
		var MouseVector = event.relative
		prev_mouse_move = -MouseVector.x * Settings.SENSITIVITY / 1000
		head.get_parent().rotate_y(-MouseVector.x * Settings.SENSITIVITY / 1000)
		head.rotate_x(-MouseVector.y * Settings.SENSITIVITY / 1000)
		prev_rotation = head.get_parent_node_3d().rotation
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-75), deg_to_rad(75))
func _physics_process(delta: float) -> void:
	prev_delta = delta 
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	head.get_parent_node_3d().position = position + Vector3(0, 0.5, 0)
	char_component.move_into_direction(input_dir, delta)
	rotation.y = prev_rotation.y
	if Input.is_action_just_pressed("jump"):
		jump_buffer = true
		char_component.jump(delta)
		await get_tree().create_timer(buffer_time).timeout
		jump_buffer = false
	if Input.is_action_just_pressed("change_gravity"):
		char_component.gravity = -char_component.gravity
		char_component.jump_power = -char_component.jump_power
		char_component.gravity_mode= not char_component.gravity_mode
		if (char_component.gravity_mode):
			up_direction = Vector3.DOWN
		else:
			up_direction = Vector3.UP
		rotate = true
		
	if rotate and above.is_colliding():
		#var tween = get_tree().create_twewen()
		var deg = 0
		if char_component.gravity_mode: 
			deg = 180
			
		#tween.tween_property(player_mesh, "rotation_degrees", Vector3(rotation_degrees.x, rotation_degrees.y, deg), 0.5)
		rotate = false

func _on_touched_ground() -> void:
	if jump_buffer:
		char_component.jump(prev_delta)
		jump_buffer = false
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	char_component.touched_ground.connect(_on_touched_ground)
	
