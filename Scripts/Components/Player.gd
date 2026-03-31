extends CharacterBody3D
class_name Player
@export var GravityRetainEnabled : bool
@export var SwitchGravityWhileGrabbingEnabled: bool
@export var ThrowForceMax: float
@export_group("Configuration")
@export var char_component: CharacterComponent
@export var head: Node3D
@export var GrabSpot : Node3D
@export var camera: Camera3D
@export var above: RayCast3D
@export var below: RayCast3D
@export var GrabRay: RayCast3D
@export var GrabWallCheck: RayCast3D
@export var player_mesh: MeshInstance3D
@export var throwbar: ProgressBar
var current_grabbed_obj: RBBox
var prev_rotation: Vector3
var prev_mouse_move: float
var jump_buffer: bool = false
var buffer_time: float = 0.1
var prev_delta: float
var rotate: bool = false
var grabbing: bool = false
var lerp_progress = 0.0
var lerp_step = 0.01
var throw = 0.0
var throw_step = 0.5
var spins = 0
var title_dir = false
var title_time = 1500
var title_count = 0

signal ChangedGravity
func grabbed_obj_collision():
	if current_grabbed_obj:
		if GrabWallCheck.get_collider():
			current_grabbed_obj.maintain_local_pos = false
			var new_pos = GrabWallCheck.get_collision_point() + (GrabWallCheck.get_collision_normal() * current_grabbed_obj.scale / 2)
			current_grabbed_obj.position = GrabSpot.to_local(new_pos)
			print(current_grabbed_obj.position)
		else:
			current_grabbed_obj.maintain_local_pos = true
func _input(event):
	if event.is_action_pressed("unlock_mouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action("ui_cancel"):
		get_tree().quit()
	if event.is_action("fullscreen"):
		var mode := DisplayServer.window_get_mode()
		var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_window else DisplayServer.WINDOW_MODE_WINDOWED)
func _unhandled_input(event):
	if (event is InputEventMouseMotion):
		var MouseVector = event.relative
		#prev_mouse_move = -MouseVector.x * Settings.SENSITIVITY / 1000
		if char_component.gravity_mode:
			prev_mouse_move = MouseVector.x * Settings.SENSITIVITY / 1000
			head.get_parent().rotate_y(MouseVector.x * Settings.SENSITIVITY / 1000)
			head.rotate_x(MouseVector.y * Settings.SENSITIVITY / 1000)
		else:
			prev_mouse_move = -MouseVector.x * Settings.SENSITIVITY / 1000
			head.get_parent().rotate_y(-MouseVector.x * Settings.SENSITIVITY / 1000)
			head.rotate_x(-MouseVector.y * Settings.SENSITIVITY / 1000)
		prev_rotation = head.get_parent_node_3d().rotation
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-75), deg_to_rad(75))
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			throw += throw_step
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			throw -= throw_step
		throw = clamp(throw, 0, ThrowForceMax)
		throwbar.value = throw
		#print(throw)
func _physics_process(delta: float) -> void:
	var checking_for_collision
	if char_component.gravity_mode:
		checking_for_collision = above.is_colliding()
	else:
		checking_for_collision = below.is_colliding()
	grabbed_obj_collision()
	prev_delta = delta
	var input_dir
	if char_component.gravity_mode:
		input_dir = Input.get_vector("right", "left", "forward", "backward")
	else:
		input_dir = Input.get_vector("left", "right", "forward", "backward")
	if get_tree().current_scene.name == "TITLE":
		if title_dir:
			input_dir = Vector2(0.1, 0)
		else:
			input_dir = Vector2(-0.1, 0)
		title_count += 1
		if title_count == title_time:
			title_dir = not title_dir
			title_count = 0
	char_component.move_into_direction(input_dir, delta)
	rotation.y = prev_rotation.y
	if Input.is_action_just_pressed("jump"):
		jump_buffer = true
		char_component.jump(delta)
		await get_tree().create_timer(buffer_time).timeout
		jump_buffer = false
	if Input.is_action_just_pressed("change_gravity") and checking_for_collision:
		if SwitchGravityWhileGrabbingEnabled:
			ChangedGravity.emit()
		else:
			if not grabbing:
				ChangedGravity.emit()
		
		var condition : Array[bool]
		if GravityRetainEnabled:
			condition.append(not Input.is_action_pressed("retain_gravity"))
		if not SwitchGravityWhileGrabbingEnabled:
			condition.append(not grabbing)
		
		if condition.find(false) == -1:
			spins += 1
			char_component.gravity = -char_component.gravity
			char_component.jump_power = -char_component.jump_power
			char_component.gravity_mode= not char_component.gravity_mode
			if (char_component.gravity_mode):
				up_direction = Vector3.DOWN
			else:
				up_direction = Vector3.UP
			rotate = true
	
	if rotate:
		var init_deg = player_mesh.rotation_degrees
		var deg = 180.0 * spins

		## LERP METHOD
		lerp_progress += lerp_step
		var progress = lerp(init_deg.z, deg, lerp_progress)
		player_mesh.rotation_degrees.z = progress
		head.rotation_degrees.z = progress
		if progress == 180.0 * spins:
			player_mesh.rotation_degrees.z = deg
			head.rotation_degrees.z = deg
			lerp_progress = 0.0
			rotate = false
			
	if Input.is_action_just_pressed("grab"):
		if grabbing:
			GrabSpot.get_child(0).maintain_local_pos = false
			if GrabSpot.get_child(0).Throwable:
				throwbar.hide()
				GrabSpot.get_child(0).linear_velocity = -basis.z * throw
				GrabSpot.get_child(0).linear_velocity.y += -head.basis.z.y * throw * 3.5
				print(-basis.z * throw) # FORWARD VECTOR times THROW FORCE
			GrabSpot.get_child(0).reparent(get_node("/root/Node3D"))
			current_grabbed_obj = null
			grabbing = false
		elif not grabbing and GrabRay.is_colliding():
			if GrabRay.get_collider() is RBBox:
				if GrabRay.get_collider().Throwable:
					throwbar.show()
				# Set local gravity after grabbing
				current_grabbed_obj = GrabRay.get_collider()
				if char_component.gravity_mode:
					current_grabbed_obj.gravity_scale = - abs(current_grabbed_obj.gravity_scale)
				else:
					current_grabbed_obj.gravity_scale = abs(current_grabbed_obj.gravity_scale)
				current_grabbed_obj.UPDATE_COLORS()
				
				current_grabbed_obj.maintain_local_pos = true
				current_grabbed_obj.reparent(GrabSpot)
				grabbing = true
				
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _process(_delta):
	head.get_parent_node_3d().position = position + Vector3(0, 0.5, 0)
func _on_touched_ground() -> void:
	if jump_buffer:
		char_component.jump(prev_delta)
		jump_buffer = false
func dying_behaviour() -> void:
	print("Player Died. Restarting current scene.")
	get_tree().call_deferred("reload_current_scene")
func _ready() -> void:
	if get_tree().current_scene.name == "TITLE":
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	char_component.touched_ground.connect(_on_touched_ground)
	char_component.died.connect(dying_behaviour)
	throwbar.max_value = ThrowForceMax
	get_node("/root/MusicController")._ready()
func goto_first_level():
	get_tree().change_scene_to_file("res://Prototype2Levels/LEVEL0.tscn")
func quit():
	get_tree().quit()
	
	
	
