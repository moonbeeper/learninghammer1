extends Control

@export var icon_tex: TextureRect
@export var label: Label
@export var timer: Timer

var tween: Tween

func _ready() -> void:
	InstructorHintManager.hint.connect(_on_hint)
	InstructorHintManager.end_hint.connect(_on_end_hint)
	modulate = Color(1,1,1,0)
	
func _on_hint(caption: String, caption_color: Color, icon: Texture2D, timeout: int) -> void:
	kill_and_hide()
	await tween.finished
	
	label.text = caption
	label.remove_theme_color_override("font_color")
	label.add_theme_color_override("font_color", caption_color)
	icon_tex.texture = icon
	
	
	print("i can't veliebe that i cannot ge this wrokingv value: ", timeout)
	
	if timeout != 0:
		timer.wait_time = timeout
		timer.start()
		print("wait_time: ", timer.wait_time)
		print("IS IT RUNNING: ", !timer.is_stopped())
	else:
		timer.stop()
		print("timeout was 0")
		
	kill_and_create_tween()
	show_hint_tween()

func kill_and_create_tween() -> void:
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func show_hint_tween() -> void:
	tween.tween_property(self, "modulate", Color(1,1,1,1), 0.3)

func hide_hint_tween() -> void:
	tween.tween_property(self, "modulate", Color(1,1,1,0), 0.3)

func _on_timer_timeout() -> void:
	print("TIMER TIMEOUT FIREDDDDDDDDDDDDDDDDDDDd")
	kill_and_hide()
	
func _on_end_hint() -> void:
	kill_and_hide()

func kill_and_hide() -> void:
	kill_and_create_tween()
	hide_hint_tween()
