extends TileMap

var selected_tile
var player_tile


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
	var cells = get_used_rect()
	print(cells.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	var tile = local_to_map(get_global_mouse_position())
	var player_loc = local_to_map(Globals.player_pos)
	selected_tile = map_to_local(tile)
	player_tile = map_to_local(player_loc)



