@tool
class_name prop_physics
extends prop_studio

var model_scale: float = 1.0:
	get: return entity.get('modelscale', 1.0)

var skin: int = 0:
	get: return entity.get('skin', 0)

var mass_scale: float = 1.0:
	get: return entity.get('massScale', 1.0)

var screen_space_fade: bool = false:
	get: return entity.get('screenspacefade', 0) == 1

var fade_min: float = 0.0:
	get: return entity.get('fademindist', 0.0) * VMFConfig.import.scale

var fade_max: float = 0.0:
	get: return entity.get('fademaxdist', 0.0) * VMFConfig.import.scale

func _entity_setup(e: VMFEntity):
	super._entity_setup(e);
	print(entity)

	var m_model_instance: MeshInstance3D = model_instance
	m_model_instance.reparent($body)
	
	if not m_model_instance:
		VMFLogger.error("Corrupted prop_physics: " + str(model));
		return;

	m_model_instance.set_owner(get_owner());
	m_model_instance.scale *= model_scale;
	MDLCombiner.apply_skin(m_model_instance, skin);
	
	$body/collision.shape = m_model_instance.mesh.create_convex_shape()
	$body/collision.scale = m_model_instance.scale
	$body.mass = 1.0 + m_model_instance.get_aabb().size.x * m_model_instance.get_aabb().size.y * m_model_instance.get_aabb().size.z * 0.01;
	print(mass_scale * $body.mass)
	$body.mass *= mass_scale
	var fade_margin = fade_max - fade_min;

	m_model_instance.visibility_range_end = max(0.0, fade_max);
	m_model_instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF \
		if screen_space_fade \
		else GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED;

	if m_model_instance.visibility_range_fade_mode != GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED:
		m_model_instance.visibility_range_end_margin = fade_margin;
	
	m_model_instance.set_layer_mask_value(2, true)
	m_model_instance.set_layer_mask_value(1, false)
