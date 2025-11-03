extends CanvasLayer

@export var target: Node3D
@export var arrow: Control

func _ready() -> void:
	set_process(false)

func _process(_delta):	
	return
	var camera = Player.INSTANCE.get_viewport().get_camera_3d()	

	var player_pos = Player.INSTANCE.global_position
	var target_pos = target.global_position
	
	player_pos.y = 0
	target_pos.y = 0
	
	var direction_3d = (target_pos - player_pos).normalized()
	
	var cam_transform = camera.global_transform
	var local_dir = cam_transform.basis.inverse() * direction_3d
	var direction_2d = Vector2(local_dir.x, -local_dir.y)
	
	arrow.rotation = direction_2d.angle() + PI/2
