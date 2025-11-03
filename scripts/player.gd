extends CharacterBody3D
class_name Player

static var INSTANCE: Player

@export var head: Node3D
@export var collision: CollisionShape3D
@export var camera: Camera3D
@export var ray_stair_below: RayCast3D
@export var ray_stair_front: RayCast3D
@export var hand_point: Node3D
@export var flash_spot_light: SpotLight3D

@export var mouse_sensitivity: float = 0.1
@export var acceleration: float = 10.0
@export var movement_speed: float = 5.0
@export var movement_crouch_speed: float = 3.0
@export var movement_speed_change: float = 4.0
@export var jump_height: float = 1.0
@export_range(0.0, 1.0, 0.1) var crouch_height_percent: float = 0.5
@export var crouch_speed: float = 30.0
@export var max_step_height: float = 0.49
@export var interaction_distance: float = 3.0
@export var flashlight_position_smoothness: float = 15.0
@export var flashlight_rotation_smoothness: float = 15.0

var pickup_processor: PlayerPickupProcessor = null
var footstep_processor: FootstepProcessor = null

var collision_height: float = 0.0
var _last_frame_was_on_floor: int = -1
var _snapped_to_stairs_last_frame: bool = false
var is_cursor_captured: bool = false
var is_flashlight_enabled: bool = false
var current_movement_speed: float = 1.0

func _ready() -> void:
	INSTANCE = self
	ValveIONode.define_alias("!player", self);

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	is_cursor_captured = true
	collision_height = collision.shape.height 
	pickup_processor = PlayerPickupProcessor.new(hand_point);
	footstep_processor = FootstepProcessor.new(self)
	current_movement_speed = movement_speed


func _input(event: InputEvent) -> void:
	input_mouse_event(event)
	input_capture_mouse(event)
	input_interact(event)
	input_throw(event)
	input_flashlight(event)
	
func input_mouse_event(event: InputEvent):	
	if !event is InputEventMouseMotion or !is_cursor_captured: return 
	var this = event as InputEventMouseMotion
	rotate_y(deg_to_rad(-this.relative.x * mouse_sensitivity))
	head.rotate_x(deg_to_rad(-this.relative.y * mouse_sensitivity))
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-70), deg_to_rad(70))

func input_capture_mouse(event: InputEvent):
	if event.is_action_pressed("cancel") and is_cursor_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		is_cursor_captured = false
	if event is InputEventMouseButton and !is_cursor_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		is_cursor_captured = true

func input_throw(event: InputEvent) -> void:
	if event.is_action_pressed("throw"):
		if pickup_processor.has_item():
			pickup_processor.throw_item()

func input_interact(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		if pickup_processor.has_item():
			pickup_processor.drop_item()
			return

		var ray_start = camera.global_transform.origin
		var ray_end = camera.global_transform.origin - camera.global_transform.basis.z * interaction_distance
		var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, 1, [self])
		var result = get_world_3d().direct_space_state.intersect_ray(query)

		if result:
			print(result)
			var body = result.collider.get_parent()
			if body.has_method("_interact_and_pickup"):
				body._interact(self)
			if body.has_method("_interact"):
				print("body has _interact method, exiting method")
				body._interact(self)
				return

			pickup_processor.pickup_item(result.collider)

func input_flashlight(event: InputEvent) -> void:
	if event.is_action_pressed("flashlight"):
		print("pressed")
		if is_flashlight_enabled:
			is_flashlight_enabled = false
			flash_spot_light.visible = is_flashlight_enabled
		else:
			is_flashlight_enabled = true
			flash_spot_light.visible = is_flashlight_enabled
			
func _process(delta: float) -> void:
	process_flashlight_movement(delta)
	
func _physics_process(delta: float) -> void:
	if is_on_floor(): _last_frame_was_on_floor = Engine.get_physics_frames()
	process_movement(delta)
	process_jump(delta)
	process_crouch(delta)
	pickup_processor.physics_process(delta);
	footstep_processor.physics_process(delta)
	
func process_movement(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * delta
		
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0 , input_dir.y)).normalized()
	
	velocity.x = lerp(velocity.x, direction.x * current_movement_speed, acceleration * delta)
	velocity.z = lerp(velocity.z, direction.z * current_movement_speed, acceleration * delta)
	if !try_snap_up_check(delta):
		move_and_slide()
		try_snap_down(delta)

func process_jump(_delta: float) -> void:
	if is_on_floor() or _snapped_to_stairs_last_frame:
		if Input.is_action_just_pressed("jump"):
			velocity.y = sqrt(2 * jump_height * get_gravity().length());

func process_crouch(delta: float) -> void:
	var is_crouching = Input.is_action_pressed("crouch")
	
	if is_crouching:
		current_movement_speed = lerp(current_movement_speed, movement_crouch_speed, movement_speed_change * delta)
	else:
		current_movement_speed = lerp(current_movement_speed, movement_speed, movement_speed_change * delta)
	
	var crouch_height = collision_height * crouch_height_percent
	var target_height = crouch_height if is_crouching else collision_height
	
	collision.shape.height = lerp(collision.shape.height, target_height, crouch_speed * delta)

func process_flashlight_movement(delta: float) -> void:
	var sbasis = flash_spot_light.global_basis.slerp(camera.global_basis, delta * flashlight_rotation_smoothness)
	var origin = flash_spot_light.global_transform.origin.slerp(camera.global_transform.origin, delta * flashlight_position_smoothness)
	
	flash_spot_light.global_transform = Transform3D(sbasis, origin)

#https://www.youtube.com/watch?v=Tb-R3l0SQdc
func is_surface_too_steep(normal : Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle

func try_snap_down(_delta: float) -> void:
	var did_snap: bool = false
	var was_on_floor_last_frame = Engine.get_physics_frames() - _last_frame_was_on_floor == 1
	
	var floor_below: bool = ray_stair_below.is_colliding() and !is_surface_too_steep(ray_stair_below.get_collision_normal())
	
	if !is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = KinematicCollision3D.new()
		if test_move(global_transform, Vector3(0, -max_step_height, 0), body_test_result):
			var translate_y = body_test_result.get_travel().y
			position.y += translate_y
			apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap

func try_snap_up_check(delta: float) -> bool:
	if !is_on_floor() and !_snapped_to_stairs_last_frame: return false
	var expected_move_motion = velocity * Vector3(1, 0, 1) * delta
	var step_pos_with_clearance = global_transform.translated(expected_move_motion + Vector3(0, max_step_height * 2, 0))
	
	var body_test_result = KinematicCollision3D.new()
	if test_move(step_pos_with_clearance, Vector3(0, -max_step_height * 2, 0), body_test_result) and (body_test_result.get_collider().is_class("StaticBody3D") or body_test_result.get_collider().is_class("RigidBody3D")):
		var step_height = ((step_pos_with_clearance.origin + body_test_result.get_travel()) - global_position).y
		if step_height > max_step_height or step_height <= 0.01 or (body_test_result.get_position() - global_position).y > max_step_height: return false
		
		ray_stair_front.global_position = body_test_result.get_position() + Vector3(0, max_step_height, 0) + expected_move_motion.normalized() * 0.1
		ray_stair_front.force_raycast_update()
		if ray_stair_front.is_colliding() and !is_surface_too_steep(ray_stair_front.get_collision_normal()):
			global_position = step_pos_with_clearance.origin + body_test_result.get_travel()
			apply_floor_snap()
			_snapped_to_stairs_last_frame = true
			return true
	return false
