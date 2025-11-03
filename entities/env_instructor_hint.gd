@tool

# omg i hecking hate all of this why would i even tried to use this god dammit am too hecking stuupid for these things

## @entity PointClass
## @base Targetname, Angles
## @appearance iconsprite("game/hud/inffoof.vmt")
## Description of the entity
class_name env_instructor_hint
extends VMFEntityNode

# SolidClass means it's a brush entity
# PointClass means it's a point entity

# Will be presented in the FGD as "integer". Description should begin after `@exposed` mark
## @exposed
## The text showed in the hint
var caption: String = "Hello world":
	get: return entity.get("caption", "Hello world")

# awawwa
## @exposed
## The text color showed in the hint
var caption_color: Color:
	get:
		var color_vec = entity.get("caption_color", Vector3(1,1,1))
		return Color(color_vec.x, color_vec.y, color_vec.z)

enum OnScreenIcon {
	KEYBIND, INFO, KEYBIND2
}

## @exposed
## just use keybind to show the interact key haha
var on_screen_icon: OnScreenIcon = OnScreenIcon.INFO:
	get: return entity.get("on_screen_icon", OnScreenIcon.INFO)

## @exposed
## The key icon that will be showed if the On Screen Icon is KEYBIND. does nothing lmao
var bound_key: String = "":
	get: return entity.get("bound_key", "")

## @exposed
## If set, an arrow will be shown pointing towards that entity. does nothing lmao
var target_entity: Node:
	get: return get_target(entity.get("target_entity", null))
## @exposed
## The timeout to hide the hint. If its 0, the hint won't hide until manually calling EndHint
var timeout: int = 0:
	get: return entity.get("timeout", 0)

func EndHint(_param = null) -> void:
	print("env_instructor_hint end")
	InstructorHintManager.hide_hint()
	
func StartHint(_param = null) -> void:
	print("env_instructor_hint start")
	var uhh: InstructorHintManager.HintIcon
	
	match on_screen_icon:
		OnScreenIcon.KEYBIND:
			uhh = InstructorHintManager.HintIcon.KEYBIND
		OnScreenIcon.INFO:
			uhh = InstructorHintManager.HintIcon.INFO
		OnScreenIcon.KEYBIND2:
			uhh = InstructorHintManager.HintIcon.KEYBIND2
	InstructorHintManager.show_hint(caption, caption_color, uhh, timeout, bound_key)
