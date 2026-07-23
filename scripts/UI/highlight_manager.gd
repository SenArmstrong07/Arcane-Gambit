extends Node
class_name HighlightManager

const HighlightScene = preload("res://scenes/UI/HighlightCells.tscn")
const HighlightAtkScene = preload("res://scenes/UI/HighlightAtk.tscn")

var chess_board: Node2D = null
var highlight_markers: Node2D = null
var highlighted_cells: Array = []

func init(_chess_board: Node2D, _highlight_markers: Node2D) -> void:
	chess_board = _chess_board
	highlight_markers = _highlight_markers
	highlighted_cells = []
	if highlight_markers != null:
		highlight_markers.visible = false

func show_move_tiles(cells: Array[Vector2i]) -> void:
	_show_tiles(cells, false)

func show_attack_tiles(cells: Array[Vector2i]) -> void:
	_show_tiles(cells, true)

func clear() -> void:
	if highlight_markers == null:
		return
	for child in highlight_markers.get_children():
		child.queue_free()
	highlighted_cells.clear()
	highlight_markers.visible = false

func _show_tiles(cells: Array[Vector2i], use_attack_texture: bool) -> void:
	clear()
	if highlight_markers == null or chess_board == null:
		return
	for cell in cells:
		var marker: Node2D
		if use_attack_texture:
			marker = HighlightAtkScene.instantiate() as Node2D
		else:
			marker = HighlightScene.instantiate() as Node2D
		marker.position = chess_board.map_to_local(cell)
		highlight_markers.add_child(marker)
		highlighted_cells.append(marker)
	highlight_markers.visible = highlighted_cells.size() > 0
