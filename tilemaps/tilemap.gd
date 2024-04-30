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

signal move_success()

enum layers{
	level0 = 0,
	level1 = 1,
	level2 = 2
}


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

@onready var Square = preload("res://ui/highlight_square.tscn")


func get_enemy_moves(enemy_pos: Vector2, ability_data: AbilityData):
	var offset_x = Vector2(-32,-16)
	var offset_y = Vector2(32, -16)
	
	var movement_range = ability_data.ability_range
	var move_options: Array[Vector2]
	
	for dx in range(-movement_range, movement_range + 1):
		for dy in range(-movement_range, movement_range + 1):
			if abs(dx) + abs(dy) <= movement_range:
				# Position each square using isometric offset calculations
				var pos_x = dx * offset_x.x * 0.5  + dy * offset_y.x * 0.5
				var pos_y = dx * offset_x.y * 0.5  + dy * offset_y.y * 0.5
				move_options.append(enemy_pos + Vector2(pos_x, pos_y))

	return(move_options)
	#return()
	#Globals.return_enemy_moves.emit(move_options)
	##check_range(move_data, 
	#			enemy_pos,
	#			move_options.pick_random())

				
func check_range(ability_data: AbilityData, pos: Vector2, target_pos: Vector2) -> bool:
	var ability_range = ability_data.ability_range
	should_move = true if ability_data.ability_name == 'move' else false
	ability_path = astar_grid.get_id_path(
			local_to_map(pos) + iso_offset,
			local_to_map(target_pos) + iso_offset
			).slice(1)
			
	# TODO this breaks spell damage, but is needed for movement
	#or ability_data.ability_name != 'move'
	if len(ability_path) > ability_range :
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
			Globals.turn_entity_pos = entity.global_position
			return

#func tile_entity_check(tile_loc: Vector2):
	#var loc = map_to_local(tile_loc)
	#
	#for entity in Globals.turn_queue:
		#if entity is PlayableEntity:
			#
#@	var loc = map_to_local
	
	
		

func _process(_delta):
	selected_tile_map = local_to_map(get_global_mouse_position())
	player_tile_map = local_to_map(Globals.turn_entity_pos)
	selected_tile_loc = map_to_local(selected_tile_map)
	player_tile_loc = map_to_local(player_tile_map)

	if ability_path.is_empty() or not should_move:
		return
	else:
		move_entity(Globals.turn_entity)
