extends Node
class_name RoyalAssignmentController

signal assignment_started(team:int)
signal assignment_completed(team:int)
signal assignment_hovered(unit)
signal assignment_canceled()

var board: Node = null
var current_turn: int = 0
var royal_assignment_active: bool = false
var hovered_assignment_unit: Unit = null
var assignment_overlay_layer: CanvasLayer = null
var assignment_overlay_rect: ColorRect = null

func init(_board: Node) -> void:
	board = _board

func start_assignment(team: int) -> void:
	royal_assignment_active = true
	current_turn = team
	if board != null:
		board.current_turn = current_turn
	_show_assignment_overlay()
	_refresh_unit_interaction()
	emit_signal("assignment_started", team)

func try_assign(unit: Unit) -> void:
	if unit == null or not royal_assignment_active or unit.team != current_turn:
		return
	if board == null or not board.has_method("get_player"):
		return
	var player : Player = board.get_player(unit.team)
	if player == null:
		return
	player.assign_royal_unit(unit)
	clear_hover()
	if current_turn == 0:
		current_turn = 1
		if board != null:
			board.current_turn = current_turn
		_refresh_unit_interaction()
	else:
		finalize_assignment()

func finalize_assignment() -> void:
	if board == null:
		return
	royal_assignment_active = false
	var completed_team := current_turn
	if board.has_method("finalize_royal_assignment"):
		board.finalize_royal_assignment()
	if board != null:
		current_turn = board.current_turn
	_hide_assignment_overlay()
	emit_signal("assignment_completed", completed_team)

func show_hover(unit: Unit) -> void:
	if unit == null:
		return
	clear_hover()
	hovered_assignment_unit = unit
	if unit.sprite_node != null:
		unit._original_modulate = unit.sprite_node.modulate
		unit.sprite_node.modulate = Color(1.25, 1.25, 0.9, 1)
		unit.sprite_node.scale = unit.sprite_node.scale * 1.08
	emit_signal("assignment_hovered", unit)

func clear_hover() -> void:
	if hovered_assignment_unit == null:
		return
	var u := hovered_assignment_unit
	hovered_assignment_unit = null
	if u != null and u.sprite_node != null:
		u.sprite_node.modulate = u._original_modulate
		u.sprite_node.scale = u._original_scale

func cancel_assignment() -> void:
	royal_assignment_active = false
	_refresh_unit_interaction()
	_hide_assignment_overlay()
	emit_signal("assignment_canceled")

func is_active() -> bool:
	return royal_assignment_active

func _refresh_unit_interaction() -> void:
	if board == null or not board.has_method("_set_unit_input_pickable"):
		return
	board._set_unit_input_pickable(royal_assignment_active, current_turn)

func _show_assignment_overlay() -> void:
	if assignment_overlay_layer != null and is_instance_valid(assignment_overlay_layer):
		return
	assignment_overlay_layer = CanvasLayer.new()
	assignment_overlay_layer.layer = 100
	get_tree().get_root().call_deferred("add_child", assignment_overlay_layer)
	assignment_overlay_rect = ColorRect.new()
	assignment_overlay_rect.color = Color(0, 0, 0, 0.45)
	assignment_overlay_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	assignment_overlay_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	assignment_overlay_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	assignment_overlay_rect.size = get_viewport().get_visible_rect().size
	assignment_overlay_layer.add_child(assignment_overlay_rect)

func _hide_assignment_overlay() -> void:
	if assignment_overlay_layer != null and is_instance_valid(assignment_overlay_layer):
		assignment_overlay_layer.queue_free()
		assignment_overlay_layer = null
		assignment_overlay_rect = null
