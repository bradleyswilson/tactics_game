extends Node2D

@onready var abilities = $Abilities
@onready var Square = preload("res://ui/highlight_square.tscn")
@onready var Plus = preload("res://ui/highlight_plus.tscn")

@onready var cursor = $Cursor
@onready var cursor_visible = false
@onready var shown_positions: Array

var offset_x = Vector2(-32,-16)
var offset_y = Vector2(32, -16)
var mouse_pos 
@onready var tilemap = get_tree().get_nodes_in_group("tilemaps")[0]

func _process(_delta):
	mouse_pos = get_global_mouse_position()
	check_cursor(shown_positions, mouse_pos)

func show_range(ability_data: AbilityData, source_loc: Vector2, collisions: bool):
	# toggles range indicators
	var indicator_positions
	var ability_range = ability_data.ability_range
	for n in abilities.get_children():
		n.queue_free()
	
	match [ability_data.range_type]:
		["Free"]:
			indicator_positions = get_range_squares(ability_range, source_loc, collisions)
			cursor.swap_cursor("square")
		["Line"]:
			indicator_positions = get_plus_squares(ability_range, source_loc, collisions)
			cursor.swap_cursor("square")
		["Cluster"]:
			indicator_positions = get_range_squares(ability_range, source_loc, collisions)	
			cursor.swap_cursor("plus")
	
	for ind in indicator_positions:
		var square = Square.instantiate()
		abilities.add_child(square)
		square.global_position = ind
		if square.global_position == source_loc:
			square.queue_free()
			
	shown_positions = indicator_positions
	if not abilities.visible:
		for n in abilities.get_children():
			n.queue_free()
		shown_positions = []

	
func clear_range():
	# clear range indicators, used on a fresh turn.
	for n in abilities.get_children():
		n.queue_free()
	cursor.swap_cursor("square")
	abilities.visible = false
	get_parent().toggle_count = 0
		
func get_range_squares(movement_range: int, source_loc: Vector2, collisions: bool):
	var move_options: Array = []
	for dx in range(-movement_range, movement_range + 1):
		for dy in range(-movement_range, movement_range + 1):
			if abs(dx) + abs(dy) <= movement_range:
				var pos_x = dx * offset_x.x * 0.5  + dy * offset_y.x * 0.5
				var pos_y = dx * offset_x.y * 0.5  + dy * offset_y.y * 0.5
				var target_position = source_loc +  Vector2(pos_x, pos_y)
				move_options.append(target_position)
	var new_target_positions = check_path(source_loc, move_options, \
										  movement_range, collisions)
	return(new_target_positions)

func get_plus_squares(movement_range: int, source_loc: Vector2, collisions: bool):
	var move_options: Array = []
	for dx in range(-movement_range, movement_range + 1):
		if dx != 0:
			var pos_x = dx * offset_x.x * 0.5
			var pos_y = dx * offset_x.y * 0.5
			var target_position = source_loc +  Vector2(pos_x, pos_y)
			move_options.append(target_position)
		
	for dy in range(-movement_range, movement_range + 1):
		if dy != 0:
			var pos_x = dy * offset_y.x * 0.5
			var pos_y = dy * offset_y.y * 0.5
			var target_position = source_loc +  Vector2(pos_x, pos_y)
			move_options.append(target_position)
	#var new_target_positions = check_path(source_loc, move_options, \
	#									  movement_range, collisions)
	return(move_options)
	
	
func check_path(source_pos: Vector2, target_positions: Array, 
				movement_range: int, collisions: bool):
	var invalid_cells = []
	invalid_cells.append_array(tilemap.cell_local_pos)
	var new_target_positions: Array = []
	for target_pos in target_positions:
		if tilemap.get_cell_tile_data(0, tilemap.local_to_map(target_pos)) != null:
			var path = tilemap.astar_grid.get_id_path(
					tilemap.local_to_map(source_pos) + tilemap.iso_offset,
					tilemap.local_to_map(target_pos) + tilemap.iso_offset
					).slice(1)
			if collisions:
				invalid_cells.append_array(Globals.entities_pos)
				# need to update these each turn?
				if len(path) <= movement_range and not invalid_cells.has(target_pos):
					new_target_positions.append(target_pos)
			else:
				new_target_positions.append(target_pos)

	return(new_target_positions)

func check_cursor(target_positions: Array, mouse_pos: Vector2):
	"""
	checks if current mouse position is in the shown spell range and
	changes cursor color to match validity of action
	"""
	
	var target_pos_loc = target_positions.map(func(x): return tilemap.local_to_map(x))
	
	if target_pos_loc.has(tilemap.local_to_map(mouse_pos)):
		for child in cursor.get_children():
			child.modulate = Color.GREEN
	else:
		for child in cursor.get_children():
			child.modulate = Color.RED
	
	if target_positions.is_empty():
		for child in cursor.get_children():
			child.modulate = Color.DARK_BLUE
	
