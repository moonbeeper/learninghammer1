@tool
class_name info_player_start extends VMFEntityNode

@export var player_scene: PackedScene
var instance: Player

## Use this method instead _ready
func _entity_ready() -> void:
	instance = Player.INSTANCE if Player.INSTANCE else player_scene.instantiate()
	
	get_tree().current_scene.add_child(instance);
	instance.global_transform = global_transform;
	instance.basis *= Basis.IDENTITY.rotated(Vector3.UP, PI * -0.5);
	get_parent().remove_child(self);
