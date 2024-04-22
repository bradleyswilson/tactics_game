extends Node2D

@onready var tilemap = $Tilemap
@onready var player = $Player

var current_id_path: Array[Vector2i]
var target_position: Vector2
var astar_grid = AStarGrid2D.new()
var is_moving: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	astar_grid.region = Rect2i(0, 0, 480, 270)
	astar_grid.cell_size = Vector2i(32,16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	player.move.connect(on_player_move)
	
func on_player_move() -> void:
	print('received')
	var range = player.movement_range
	var id_path
	
	if is_moving:
		id_path = astar_grid.get_id_path(
			tilemap.local_to_map(target_position),
			tilemap.local_to_map(get_global_mouse_position()) + Globals.iso_offset
	)
	else:
		id_path = astar_grid.get_id_path(
			tilemap.local_to_map(Globals.player_pos) + Globals.iso_offset,
			tilemap.local_to_map(get_global_mouse_position()) + Globals.iso_offset
		).slice(1)
		if len(id_path) > player.movement_range:
			print('exceeds movement range!')
			id_path = []

	if id_path.is_empty() == false:
		current_id_path = id_path

func _process(delta):
	if current_id_path.is_empty():
		return
	
	if is_moving == false:
		target_position = tilemap.map_to_local(current_id_path.front() - Globals.iso_offset) + Vector2(0, -8)
		print(target_position)
		is_moving = true
	
	player.global_position = player.global_position.move_toward(target_position, 1)

	if player.global_position == target_position:
		current_id_path.pop_front()
		
		if current_id_path.is_empty() == false:
			target_position = tilemap.map_to_local(current_id_path.front() - Globals.iso_offset) + Vector2(0, -8)
		else:
			is_moving = false
