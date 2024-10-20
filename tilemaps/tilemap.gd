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
var cell_local_pos: Array

enum layers{
	level0 = 0,
	level1 = 1
}
const brain_coral_pos = Vector2i(2, 0)
const main_source = 0

var cells = get_used_cells(layers.level1)
var ground_cells = get_used_cells(layers.level0)
var empty_cell_pos := []

func _use_tile_data_runtime_update(layer: int, _coords: Vector2i) -> bool:
	return layer in [0, 1]
	
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
	set_cell_data()
	
	for cell in cells:
		astar_grid.set_point_solid(cell + Vector2i(1,1) + iso_offset)
		
	var cells = get_used_cells(layers.level1)
	
	# get empty cells (not sure why these are empty)
	for y in get_used_rect().size.y:
		for x in get_used_rect().size.x:
			var cell_pos = get_used_rect().position + Vector2i(x, y)
			if not ground_cells.has(cell_pos):
				empty_cell_pos.append(cell_pos)

func set_cell_data():
	for cell in cells:
		Globals.gridData[cell] = CellData.new()
		cell_local_pos.append(map_to_local(cell + Vector2i(1,1)))

	Globals.gridData[Vector2i(15,0)] = load("res://tilemaps/brain_coral.tres")
	
func on_start_turn():
	# makes terrain un-navigateable 
	for cell in cells:
		astar_grid.set_point_solid(cell + Vector2i(1,1) + iso_offset)
		
	# makes entities un-navigateable 
	for entity in Globals.turn_queue:
		astar_grid.set_point_solid(local_to_map(entity.global_position) + iso_offset)
	
	# make empty cells un-navigateable
	for cell in empty_cell_pos:
		astar_grid.set_point_solid(cell + iso_offset)

func on_end_turn():
	# clear solids to rest on a new grid (clears everything, so reset on start turn)
	astar_grid.fill_solid_region(astar_grid.region, false)
				
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

func move_entity(entity: Entity, delta):
	target_position = map_to_local(ability_path.front() - iso_offset)
	entity.global_position = entity.global_position.move_toward(target_position, entity.speed*delta)
	if entity.global_position == target_position:
		ability_path.pop_front()
		entity.global_position = entity.global_position.move_toward(target_position, entity.speed*delta)
		
		if not ability_path.is_empty():
			target_position = map_to_local(ability_path.front() - iso_offset)
		else:
			Globals.entities_pos[0] = entity.global_position
			return

func _process(delta):
	if Globals.entities_pos:
		selected_tile_map = local_to_map(get_global_mouse_position())
		player_tile_map = local_to_map(Globals.entities_pos[0])
		selected_tile_loc = map_to_local(selected_tile_map)
		player_tile_loc = map_to_local(player_tile_map)

	if ability_path.is_empty() or not should_move:
		return
	else:
		move_entity(Globals.turn_entity, delta)

