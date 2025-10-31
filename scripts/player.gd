extends CharacterBody3D

@export var head: Node3D
@export var collision: CollisionShape3D
@export var camera: Camera3D

@export var mouse_sensitivity: float = 0.1
@export var acceleration: float = 10.0
@export var movement_speed: float = 5.0
@export var jump_height: float = 1.0
@export_range(0.0, 1.0, 0.1) var crouch_height_percent: float = 0.5
@export var crouch_speed: float = 30.0

var collision_height: float = 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	collision_height = collision.shape.height 

func _input(event: InputEvent) -> void:
	input_mouse_event(event)
	pass
	
func input_mouse_event(event: InputEvent):	
	if !event is InputEventMouseMotion: return 
	var this = event as InputEventMouseMotion
	rotate_y(deg_to_rad(-this.relative.x * mouse_sensitivity))
	head.rotate_x(deg_to_rad(-this.relative.y * mouse_sensitivity))
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-70), deg_to_rad(70))

func _physics_process(delta: float) -> void:
	process_movement(delta)
	process_jump(delta)
	process_crouch(delta)
	pass
	
func process_movement(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * delta
		
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0 , input_dir.y)).normalized()
	
	velocity.x = lerp(velocity.x, direction.x * movement_speed, acceleration * delta)
	velocity.z = lerp(velocity.z, direction.z * movement_speed, acceleration * delta)
	move_and_slide()

func process_jump(_delta: float) -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = sqrt(2 * jump_height * get_gravity().length());

func process_crouch(delta: float) -> void:
	var is_crouching = Input.is_action_pressed("crouch")
	
	var crouch_height = collision_height * crouch_height_percent
	var target_height = crouch_height if is_crouching else collision_height
	
	collision.shape.height = lerp(collision.shape.height, target_height, crouch_speed * delta)
