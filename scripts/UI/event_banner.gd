extends Node2D
class_name EventBanner

signal finished

var title_label: Label = null
var sub_label: Label = null
var banner_panel: Control = null
var banner_bg: ColorRect = null
var banner_tween: Tween = null

func _ready() -> void:
	_resolve_banner_nodes()
	# initialize start state for panel
	if banner_panel != null:
		banner_panel.scale = Vector2(1.0, 1.0)
		var c: Color = banner_panel.modulate
		c.a = 0.0
		banner_panel.modulate = c
		_create_banner_background()
	visible = false

func _resolve_banner_nodes() -> void:
	if banner_panel == null:
		banner_panel = find_child("BannerPanel", true, false) as Panel
	if title_label == null:
		title_label = find_child("Title_Label", true, false) as Label
	if sub_label == null:
		sub_label = find_child("Sub_Label", true, false) as Label

func _create_banner_background() -> void:
	if banner_bg != null and is_instance_valid(banner_bg):
		banner_bg.queue_free()
		banner_bg = null

	banner_bg = ColorRect.new()
	banner_bg.name = "BannerBackground"
	banner_bg.color = Color(0.149, 0.149, 0.608, 0.949)
	banner_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	banner_bg.set_offsets_preset(Control.PRESET_FULL_RECT)
	banner_bg.z_index = -1
	banner_bg.modulate = Color(1, 1, 1, 0)
	banner_bg.scale = Vector2(1.0, 0.0)
	banner_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner_panel.add_child(banner_bg)
	banner_panel.move_child(banner_bg, 0)

func show_banner(title: String, subtitle: String = "", hold_time: float = 1.2) -> void:
	print("EventBanner.show_banner():", title, subtitle)
	_resolve_banner_nodes()
	if title_label != null:
		title_label.text = title
	if sub_label != null:
		sub_label.text = subtitle
		sub_label.visible = subtitle != ""
	visible = true
	if banner_tween != null:
		banner_tween.kill()
	banner_tween = get_tree().create_tween()
	# reveal from the center upward and downward
	banner_tween.tween_property(banner_bg, "scale:y", 1.0, 0.3).from(0.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	banner_tween.parallel().tween_property(banner_bg, "modulate:a", 0.95, 0.25)
	banner_tween.parallel().tween_property(banner_panel, "modulate:a", 1.0, 0.2)
	await banner_tween.finished
	# wait a short hold period
	await get_tree().create_timer(hold_time).timeout
	# hide tween: shrink and fade
	banner_tween = get_tree().create_tween()
	banner_tween.tween_property(banner_bg, "scale:y", 0.0, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	banner_tween.parallel().tween_property(banner_bg, "modulate:a", 0.0, 0.2)
	banner_tween.parallel().tween_property(banner_panel, "modulate:a", 0.0, 0.2)
	await banner_tween.finished
	visible = false
	emit_signal("finished")

func _process(delta: float) -> void:
	pass
