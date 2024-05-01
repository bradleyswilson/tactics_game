extends TileMap

@export var selected_tile_map: Vector2i
@export var selected_tile_loc: Vector2i
@export var player_tile_map: Vector2i
@export var player_tile_loc: Vector2i

var ability_path: Array[Vector2i]
var target_position: Vector2
var astar_grid = AStarGrid2D.new()
var iso_offset: Vector2i
var should_move: bool

const highlight_atlas_pos = Vector2i(2,0)
const main_source = 0

func _use_tile_data_runtime_update(layer: int, _coords: Vector2i) -> bool:
	return layer in [0]
	
func _tile_data_runtime_update(_layer: int, _coords: Vector2i, tile_data: TileData) -> void:
	tile_data.set_collision_polygons_count(0, 0)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	iso_offset = get_used_rect().position * -1
	astar_grid.region = Rect2i(0, 0, 480, 270)
	astar_grid.cell_size = Vector2i(32,16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	Globals.start_turn.connect(on_start_turn)
	Globals.end_turn.connect(on_end_turn)

func on_start_turn():
	# makes entities un-navigateable 
	for entity in Globals.turn_queue:
		astar_grid.set_point_solid(local_to_map(entity.global_position) + iso_offset)

func on_end_turn():
	# clear solids to rest on a new grid
	astar_grid.fill_solid_region(astar_grid.region, false)
	

#TODO clean up movement
func get_enemy_moves(shape_tiles: Array, ability_data: AbilityData):
	var offset_x = Vector2(-32,-16)
	var offset_y = Vector2(32, -16)
	
	var movement_range = ability_data.ability_range
	var move_options: Array[Vector2] = []
	var final_position
	var pos_key
	var added_positions = {}  # Use a dictionary to track added positions to avoid duplicates
	
	var shape_tiles_map = map_coords_oversized_entity(shape_tiles)
	
	for tile in shape_tiles_map:
		for dx in range(-movement_range, movement_range + 1):
			for dy in range(-movement_range, movement_range + 1):
				if abs(dx) + abs(dy) <= movement_range:
					# Position each square using isometric offset calculations
					var pos_x = dx * offset_x.x * 0.5  + dy * offset_y.x * 0.5
					var pos_y = dx * offset_x.y * 0.5  + dy * offset_y.y * 0.5
					final_position = tile + Vector2(pos_x, pos_y)
					
					# Convert position to a unique key to avoid duplicates
					pos_key = str(final_position.x) + "," + str(final_position.y)
					if pos_key not in added_positions:
						if footprint_is_oob(final_position, shape_tiles):
							#var square = Square.instantiate()
							#add_child(square)
							move_options.append(final_position)
							added_positions[pos_key] = true
							#square.global_position = final_position
	
	return(move_options)
	
func footprint_is_oob(fposition: Vector2, shape_tiles: Array) -> bool:
	var shape_tiles_bool = shape_tiles.all( \
		func(cell): return get_cell_tile_data(0, local_to_map(fposition) + cell)!=null)
	return(shape_tiles_bool)
	
func map_coords_oversized_entity(shape_tiles: Array): 
	# returns map coordinates of an entity that's oversized
	var shape_tiles_loc: Array[Vector2] = []
	for tile in shape_tiles:
		var tile_pos_loc = local_to_map(Globals.turn_entity_pos) + tile
		shape_tiles_loc.append(map_to_local(tile_pos_loc))
	return(shape_tiles_loc)

				
func is_target_valid(ability_data: AbilityData, pos: Vector2, target_pos: Vector2) -> bool:
	# This should be clean, if the target is off the map just immediately break
	if get_cell_tile_data(0, local_to_map(target_pos)) == null:
		return false
	
	var ability_range = ability_data.ability_range
	
	if ability_data.ability_name != 'move':
		astar_grid.set_point_solid(local_to_map(target_pos) + iso_offset, false)
		should_move = false
	else:
		should_move = true
	
	ability_path = astar_grid.get_id_path(
			local_to_map(pos) + iso_offset,
			local_to_map(target_pos) + iso_offset
			).slice(1)	

	astar_grid.set_point_solid(local_to_map(target_pos) + iso_offset)
	if len(ability_path) > ability_range:
		ability_path = []
		return false
	else:
		return true

func move_entity(entity: Entity):
	target_position = map_to_local(ability_path.front() - iso_offset)
	entity.global_position = entity.global_position.move_toward(target_position, 1)
	if entity.global_position == target_position:
		ability_path.pop_front()
		entity.global_position = entity.global_position.move_toward(target_position, 1)
		
		if not ability_path.is_empty():
			target_position = map_to_local(ability_path.front() - iso_offset)
		else:
			Globals.entities_pos[0] = entity.global_position
			return

func _process(_delta):
	if Globals.entities_pos:
		selected_tile_map = local_to_map(get_global_mouse_position())
		player_tile_map = local_to_map(Globals.entities_pos[0])
		selected_tile_loc = map_to_local(selected_tile_map)
		player_tile_loc = map_to_local(player_tile_map)
		
	if ability_path.is_empty() or not should_move:
		return
	else:
		move_entity(Globals.turn_entity)
		

