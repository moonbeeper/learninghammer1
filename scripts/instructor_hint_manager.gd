extends Node

# hardcoded land wahoo
var interact_icon = preload("res://materials/game/hud/hard_interact.png")
var flashlight_icon = preload("res://materials/game/hud/hard_flashlight.png")
var info_icon = preload("res://materials/game/hud/inffoof.png")

enum HintIcon {
	KEYBIND, INFO, KEYBIND2
}

signal hint(caption: String, caption_color: Color, icon: Texture2D, timeout: int)
signal end_hint()

func _ready() -> void:
	hint.connect(_on_hint)
	end_hint.connect(_on_end_hint)
	
func _on_hint(_caption: String, _caption_color: Color, _icon: Texture2D, _timeout: int) -> void:
	print("sent hint show uhhh thing")
	
func _on_end_hint() -> void:
	print("iuiuuvijoi enfdsfnd")
	
func show_hint(caption: String, caption_color: Color = Color(1,1,1,1), icon: HintIcon = HintIcon.INFO, timeout: int = 0, _bound_key: String = "") -> void:
	print("nfijodfdfvdijo")
	var emit_icon: Texture2D
	# lol, am just too tired to do actual stuff. so hardooded land
	match icon:
		HintIcon.KEYBIND:
			emit_icon = interact_icon
		HintIcon.INFO:
			emit_icon = info_icon
		HintIcon.KEYBIND2:
			emit_icon = flashlight_icon
	
	hint.emit(caption, caption_color, emit_icon, timeout)

func hide_hint() -> void:
	end_hint.emit()
