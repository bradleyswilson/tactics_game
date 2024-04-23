extends TileMap

var selected_tile
var player_tile
var id_path: Array[Vector2i]
var target_position: Vector2
var astar_grid = AStarGrid2D.new()
var is_moving: bool
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
	
	
func set_movement_coords(entity: Entity, pos: Vector2) -> bool:
	var range = entity.movement_range

	id_path = astar_grid.get_id_path(
			local_to_map(pos) + iso_offset,
			local_to_map(get_global_mouse_position()) + iso_offset
			).slice(1)
			
	if len(id_path) > entity.movement_range:
		print('exceeds movement range!')
		id_path = []
		return false
	else:
		return true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var tile = local_to_map(get_global_mouse_position())
	var player_loc = local_to_map(Globals.player_pos)
	selected_tile = map_to_local(tile)
	player_tile = map_to_local(player_loc)

	if id_path.is_empty():
		return
	target_position = map_to_local(id_path.front() - iso_offset) + Vector2(0, -8)
	player.global_position = player.global_position.move_toward(target_position, 1)
	
	if player.global_position == target_position:
		id_path.pop_front()
		player.global_position = player.global_position.move_toward(target_position, 1)
		
		if not id_path.is_empty():
			target_position = map_to_local(id_path.front() - iso_offset) + Vector2(0, -8)
		else:
			Globals.player_pos = player.global_position
			return


