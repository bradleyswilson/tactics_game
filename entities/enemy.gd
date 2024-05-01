extends Entity
class_name Enemy 

@export var shape_tiles: Array
@onready var tilemap = get_tree().get_nodes_in_group("tilemaps")[0]
@onready var pathfinder = get_tree().get_nodes_in_group("pathfinder")[0]
@onready var move_candidates: Array

func _ready():
	shape_tiles = [Vector2i(0,0), Vector2i(-1,0), Vector2i(0, -1), Vector2i(-1, -1)]
	StatusEffects.on_entity_death.connect(_on_entity_death)
	action_bar_data = load("res://actionbar/test_enemy_actionbar.tres")
	#
func _on_entity_death(entity: Entity):
	if entity == self:
		super._on_entity_death(entity)
	
func get_available_actions():
	var self_pos = Globals.turn_entity.global_position # easier to use
	
	# Get move data and other data
	var move_data = Globals.turn_entity.action_bar_data.slot_datas[0].item_data
	var ability_data = Globals.turn_entity.action_bar_data.slot_datas[-1]
	
	# Get move candidates
	move_candidates = pathfinder.get_range_squares(move_data.ability_range, self_pos, true)
	
	# set variables for selection
	var selected_move: Vector2
	var selected_ability: AbilityData
	var selected_entity: Entity
	var dmg_details: Array
	var max_damage: int = 0
	
	# for each move option, check all cast options, preferring highest damage
	for move in move_candidates:
		if ability_data is SlotData:
			var cast_loc_candidates = pathfinder.get_range_squares( \
				ability_data.item_data.ability_range, move, false)
			for cast_loc in cast_loc_candidates:
				dmg_details = check_option(cast_loc, ability_data.item_data)
				if dmg_details[0] > max_damage:
					max_damage = dmg_details[0]
					selected_ability = ability_data.item_data
					selected_move = move
					selected_entity = dmg_details[1]
	
	# if no damaging options, just pick a random move for now
	if max_damage == 0:
		selected_ability = move_data
		selected_move = move_candidates.pick_random()
		tilemap.is_target_valid(move_data, self_pos, selected_move)
	else:
		selected_ability._damage(selected_ability, selected_entity)
		tilemap.is_target_valid(move_data, self_pos, selected_move)
#
func check_option(cast_loc: Vector2, casted_ability: AbilityData):
	var damage: int
	var damage_entity: Entity
	for entity in Globals.turn_queue:
		if entity is PlayableEntity: # dont damage self (for now)
			if entity.global_position == cast_loc: 
				damage = casted_ability._try_damage(casted_ability, entity)	
				damage_entity = entity
	return([damage, damage_entity])
	



