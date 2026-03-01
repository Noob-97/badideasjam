extends Node
class_name CharacterComponent
enum States {
	IDLE,
	WALKING,
	FALLING,
	JUMPING,
	FLYING,
}
@export var character_body: Player
@export var state: States
@export_group("Character Stats")
@export var speed: float = 5
@export var jump_power: float = 4
@export var jump_cooldown: float = 0.005
@export var health: float = 100
@export var max_health: float = 100
@export var gravity: float = 9.8
@export var fly_enabled: bool = false
var gravity_mode: bool = false
var jump_debounce: bool
var gravity_disabled: bool = false
var prev_state: States = States.IDLE
@export_group("Configuration")
@export var stair_below_rc: RayCast3D
@export var stair_ahead_rc: RayCast3D
const MAX_STEP_HEIGHT = 0.2
var _snapped_to_stairs_last_frame := false
var _last_frame_was_on_floor = -INF
signal took_damage
signal died
signal touched_ground
func is_surface_too_steep(normal : Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > character_body.floor_max_angle
func _snap_down_to_stairs_check() -> void:
	var did_snap := false
	stair_below_rc.force_raycast_update()
	var floor_below : bool = stair_below_rc.is_colliding() and not is_surface_too_steep(stair_below_rc.get_collision_normal())
	var was_on_floor_last_frame = Engine.get_physics_frames() == _last_frame_was_on_floor 
	if not character_body.is_on_floor() and character_body.velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = KinematicCollision3D.new()
		if character_body.test_move(character_body.global_transform, Vector3(0,-MAX_STEP_HEIGHT * 2,0), body_test_result):
			var translate_y = body_test_result.get_travel().y
			character_body.position.y += translate_y
			character_body.apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap
func _snap_up_stairs_check(delta) -> bool:
	if not character_body.is_on_floor() and not _snapped_to_stairs_last_frame: return false
	if character_body.velocity.y > 0 or (character_body.velocity * Vector3(1,0,1)).length() == 0: return false
	var expected_move_motion = character_body.velocity * Vector3(1,0,1) * delta
	var step_pos_with_clearance = character_body.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	var down_check_result = KinematicCollision3D.new()
	if (character_body.test_move(step_pos_with_clearance, Vector3(0,-MAX_STEP_HEIGHT*2,0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - character_body.global_position).y
		if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_position() - character_body.global_position).y > MAX_STEP_HEIGHT: return false
		stair_ahead_rc.global_position = down_check_result.get_position() + Vector3(0,MAX_STEP_HEIGHT,0) + expected_move_motion.normalized() * 0.1
		stair_ahead_rc.force_raycast_update()
		if stair_ahead_rc.is_colliding() and not is_surface_too_steep(stair_ahead_rc.get_collision_normal()):
			character_body.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			character_body.apply_floor_snap()
			_snapped_to_stairs_last_frame = true
			return true
	return false

#-----------------------------------------------------------------------------#
#               |                                              |              #
#               |                                              |              #
#               |                                              |              #
#-----------------------------------------------------------------------------#
func move_into_direction(input_dir, delta):
	var direction = (character_body.transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	character_body.velocity.x = lerp(character_body.velocity.x, direction.x * speed, delta * 12.0)
	character_body.velocity.z = lerp(character_body.velocity.z, direction.z * speed, delta * 12.0)
func jump(delta):
	if character_body.is_on_floor() and not jump_debounce:
		jump_debounce = true
		character_body.velocity.y = jump_power * delta * 100
		await get_tree().create_timer(jump_cooldown).timeout
		jump_debounce = false
func damage(dmg):
	health -= dmg
	if health <= 0:
		health = 0
		died.emit()
	if health > max_health:
		health = max_health
	took_damage.emit(dmg)
func _physics_process(delta: float) -> void:
	if (not character_body.is_on_floor() and not fly_enabled and not gravity_disabled):
		character_body.velocity.y -= gravity * delta * 2
	var vel = character_body.velocity
	if fly_enabled:
		state = States.FLYING
	elif  vel.y > 0:
		state = States.FALLING
	elif  vel.y < 0:
		state = States.JUMPING
	elif vel.x != 0:
		state = States.WALKING
	else:
		state = States.IDLE
	if prev_state == States.JUMPING or prev_state == States.FALLING:
		if state == States.IDLE or state == States.WALKING:
			touched_ground.emit()
	prev_state = state
	if not _snap_up_stairs_check(delta):
		character_body.move_and_slide()
		_snap_down_to_stairs_check()
