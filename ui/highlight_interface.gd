extends Node2D

@onready var abilities = $Abilities
@onready var Square = preload("res://ui/highlight_square.tscn")
@onready var cursor_square = Square.instantiate()
@onready var cursor = $Cursor

var offset_x = Vector2(-32,-16)
var offset_y = Vector2(32, -16)

@onready var tilemap = get_tree().get_nodes_in_group("tilemaps")[0]

func _ready():
	cursor.add_child(cursor_square)

func show_cursor(source_loc: Vector2):
	cursor_square.global_position = source_loc
	cursor_square.modulate = Color(0,0,1)
	cursor_square.top_level = true

func show_range(movement_range: int, source_loc: Vector2):
	# Clear existing children from the highlight interface, if needed
	for n in abilities.get_children():
		n.queue_free()
	
	var indicator_positions = get_range_squares(movement_range, source_loc)

	for ind in indicator_positions:
		var square = Square.instantiate()
		abilities.add_child(square)
		square.global_position = ind
		if square.global_position == source_loc:
			square.queue_free()
				
	if not abilities.visible:
		for n in abilities.get_children():
			n.queue_free()
			
func get_range_squares(movement_range: int, source_loc: Vector2):
	var move_options: Array = []
	for dx in range(-movement_range, movement_range + 1):
		for dy in range(-movement_range, movement_range + 1):
			if abs(dx) + abs(dy) <= movement_range:
				var pos_x = dx * offset_x.x * 0.5  + dy * offset_y.x * 0.5
				var pos_y = dx * offset_x.y * 0.5  + dy * offset_y.y * 0.5
				var target_position = source_loc +  Vector2(pos_x, pos_y)
				move_options.append(target_position)
	var new_target_positions = check_path(source_loc, move_options, movement_range)
	return(new_target_positions)

func check_path(source_pos: Vector2, target_positions: Array, movement_range: int):

	var new_target_positions: Array = []
	for target_pos in target_positions:
		if tilemap.get_cell_tile_data(0, tilemap.local_to_map(target_pos)) != null:
			var path = tilemap.astar_grid.get_id_path(
					tilemap.local_to_map(source_pos) + tilemap.iso_offset,
					tilemap.local_to_map(target_pos) + tilemap.iso_offset
					).slice(1)
			if len(path) <= movement_range and not Globals.entities_pos.has(target_pos):
				new_target_positions.append(target_pos)
		
	return(new_target_positions)

