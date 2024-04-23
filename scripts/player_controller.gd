extends Node2D

@onready var tilemap = $Tilemap
@onready var player = $Player

var id_path: Array[Vector2i]
var target_position: Vector2
var astar_grid = AStarGrid2D.new()
var is_moving: bool
var iso_offset: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready():
	iso_offset = tilemap.get_used_rect().position * -1
	astar_grid.region = Rect2i(0, 0, 480, 270)
	astar_grid.cell_size = Vector2i(32,16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	player.ability.connect(on_player_move)
	
func on_player_move() -> void:
	var range = player.movement_range

	id_path = astar_grid.get_id_path(
			tilemap.local_to_map(Globals.player_pos) + iso_offset,
			tilemap.local_to_map(get_global_mouse_position()) + iso_offset
			).slice(1)
			
	if len(id_path) > player.movement_range:
		print('exceeds movement range!')
		id_path = []

func _process(delta):
	if id_path.is_empty():
		return
	target_position = tilemap.map_to_local(id_path.front() - iso_offset) + Vector2(0, -8)
	player.global_position = player.global_position.move_toward(target_position, 1)
	
	if player.global_position == target_position:
		id_path.pop_front()
		player.global_position = player.global_position.move_toward(target_position, 1)
		
		if not id_path.is_empty():
			target_position = tilemap.map_to_local(id_path.front() - iso_offset) + Vector2(0, -8)
		else:
			return
