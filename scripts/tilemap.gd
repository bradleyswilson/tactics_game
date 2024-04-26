extends TileMap

@export var selected_tile_map: Vector2i
@export var selected_tile_loc: Vector2i
@export var player_tile_map: Vector2i
@export var player_tile_loc: Vector2i

var ability_path: Array[Vector2i]
var target_position: Vector2
var astar_grid = AStarGrid2D.new()
var iso_offset: Vector2i

signal move_success()

@onready var player = get_tree().get_nodes_in_group("moveable_entities")[0]

enum layers{
	level0 = 0,
	level1 = 1,
	level2 = 2
}

const highlight_atlas_pos = Vector2i(2,0)
const main_source = 0

func _use_tile_data_runtime_update(layer: int, coords: Vector2i) -> bool:
	return layer in [0]
	
func _tile_data_runtime_update(layer: int, coords: Vector2i, tile_data: TileData) -> void:
	tile_data.set_collision_polygons_count(0, 0)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	iso_offset = get_used_rect().position * -1
	astar_grid.region = Rect2i(0, 0, 480, 270)
	astar_grid.cell_size = Vector2i(32,16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
func check_range(ability_data: AbilityData, pos: Vector2) -> bool:
	var range = ability_data.ability_range

	ability_path = astar_grid.get_id_path(
			local_to_map(pos) + iso_offset,
			local_to_map(get_global_mouse_position()) + iso_offset
			).slice(1)
			
	if len(ability_path) > range or ability_data.ability_name != 'move':
		ability_path = []
		return false
	else:
		return true
	
func move_entity():
	target_position = map_to_local(ability_path.front() - iso_offset) + Vector2(0, -8)
	player.global_position = player.global_position.move_toward(target_position, 1)
	
	if player.global_position == target_position:
		ability_path.pop_front()
		player.global_position = player.global_position.move_toward(target_position, 1)
		
		if not ability_path.is_empty():
			target_position = map_to_local(ability_path.front() - iso_offset) + Vector2(0, -8)
		else:
			Globals.player_pos = player.global_position
			return
		
func _process(delta):
	selected_tile_map = local_to_map(get_global_mouse_position())
	player_tile_map = local_to_map(Globals.player_pos)
	selected_tile_loc = map_to_local(selected_tile_map)
	player_tile_loc = map_to_local(player_tile_map)

	if ability_path.is_empty():
		return
	else:
		move_entity()
