extends Entity
class_name Enemy 

@export var shape_tiles: Array
@onready var tilemap = get_tree().get_nodes_in_group("tilemaps")[0]
@onready var move_candidates: Array[Vector2]

func _ready():
	shape_tiles = [Vector2i(0,0), Vector2i(-1,0), Vector2i(0, -1), Vector2i(-1, -1)]
	StatusEffects.on_entity_death.connect(_on_entity_death)
	#
func _on_entity_death(entity: Entity):
	super._on_entity_death(entity)
	
func get_available_actions():
	var move_data = Globals.turn_entity.action_bar_data.slot_datas[0].item_data
	var ability_data = Globals.turn_entity.action_bar_data.slot_datas[-1]
	
	#move_candidates = tilemap.get_enemy_moves(Globals.turn_entity_pos, shape_tiles, move_data)
	# Get all possible movement locations
	#move_candidates = tilemap.get_enemy_moves(Globals.turn_entity_pos, shape_tiles, move_data)
	
	var player_positions: Array = []
	for entity in Globals.turn_queue:
		if entity is PlayableEntity:
			player_positions.append(entity.global_position)
	
	move_candidates = move_candidates.filter(func(pos): return not player_positions.has(pos))
	
	# for each move, get all possible spell cast locations
	var selected_move: Vector2
	var selected_ability: AbilityData
	var selected_entity: Entity
	var dmg_details: Array
	var max_damage: int = 0

	for move in move_candidates:
		if ability_data is InventoryData:
			for ability in ability_data:
				pass

		elif ability_data is SlotData:
			var ability_candidates = tilemap.get_enemy_moves(move, [Vector2i(0,0)], ability_data.item_data)
			for cast_loc in ability_candidates:
				dmg_details = check_option(cast_loc, ability_data.item_data)
				if dmg_details[0] > max_damage:
					max_damage = dmg_details[0]
					selected_ability = ability_data.item_data
					selected_move = move
					selected_entity = dmg_details[1]

	if max_damage == 0:
		selected_ability = move_data
		selected_move = move_candidates.pick_random()
		tilemap.check_range(move_data, Globals.turn_entity_pos, selected_move)
	else:
		selected_ability._damage(selected_ability, selected_entity)
		tilemap.check_range(move_data, Globals.turn_entity_pos, selected_move)

func check_option(cast_loc: Vector2, casted_ability: AbilityData):
	var damage: int
	var damage_entity: Entity
	for entity in Globals.turn_queue:
		if entity is PlayableEntity: # dont damage self (for now)
			if entity.global_position == cast_loc: 
				damage = casted_ability._try_damage(casted_ability, entity)	
				damage_entity = entity
	return([damage, damage_entity])
	
	
	#casted_ability._damage(casted_ability, selected_body)
	# query ability pattern at target locations (AOE)
	# check for intersection with players




