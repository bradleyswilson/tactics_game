extends Node2D

var grabbed_ability: SlotData

@onready var highlight_interface = $HighlightInterface
@onready var range_highlight = $HighlightInterface/Abilities
@onready var tilemap = get_tree().get_nodes_in_group("tilemaps")[0]
@onready var current_cast: AbilityData
@onready var live_abilities = $LiveAbilities

var selected_body: Entity
var selected_terrain: CellData
var last_clicked: AbilityData
var toggle_count = 0

signal ability_confirm()
	
func _input(event):
	if event.is_action_released("confirm_click") and not Globals.turn_entity.ending_turn:
		selected_body = Globals.hover_entity
		selected_terrain = Globals.hover_terrain
		_on_ability_confirm(current_cast)
		
	# handle if user ends turn while spell is being cast
	if event.is_action_released("interact"): 
		if range_highlight.visible:
			range_highlight.hide() 
			highlight_interface.shown_positions = [] 
			current_cast = null
			highlight_interface.cursor.swap_cursor("square")
			
func ai_available_actions(turn_entity: Entity):
	var move_candidates: Array
	var self_pos = turn_entity.global_position # easier to use
	
	# Get move data and other data
	var move_data = turn_entity.action_bar_data.slot_datas[0].item_data
	var ability_data = turn_entity.action_bar_data.slot_datas[-1]

	# Get move candidates
	move_candidates = highlight_interface.get_range_squares(move_data.ability_range, self_pos, true)
	# set variables for selection
	var selected_move: Vector2
	var selected_ability: AbilityData
	var selected_entity: Entity
	var dmg_details: Array
	var max_damage: int = 0
	
	# for each move option, check all cast options, preferring highest damage
	for move in move_candidates:
		if ability_data is SlotData:
			var cast_loc_candidates = highlight_interface.get_range_squares( \
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
	
func ability_eval(ability_data: AbilityData, is_valid_cast: bool) -> AbilityData:
	"""
	Displays range indicators, returns ability data if highlight is on
	"""
	# if cast signal isn't valid (usually from CD, return nothing immediately)
	if not is_valid_cast:
		print("Cooldown not ready!")
		return null
	
	if Globals.turn_entity.ap == 0 or \
	(Globals.turn_entity.ap == 1 and ability_data.ability_name == 'move'): 
		print("already moved!")
		return null
	
	# handles if a user clicks another spell instead of the same spell
	if ability_data == last_clicked or toggle_count == 0:
		toggle_count += 1
		range_highlight.visible = not range_highlight.visible
	
	# show range indicators
	#range_highlight.visible = not range_highlight.visible
	var collisions = true if ability_data.ability_name == 'move' else false
	highlight_interface.show_range(ability_data, 
									Globals.entities_pos[0],
									collisions)
	
	# remove indicators that aren't on tile cells
	for i in range_highlight.get_children():
		if tilemap.get_cell_tile_data(0, tilemap.local_to_map(i.global_position)) == null:
			i.queue_free()
		
	current_cast = ability_data if range_highlight.visible else null
	last_clicked = ability_data
	return(current_cast)

func _on_ability_confirm(casting_ability: AbilityData) -> void:
	"""
	if a casted ability is loaded, matches ability type, checks range,
	# and calls execute function
	"""
	toggle_count = 0 
	if casting_ability:
		if tilemap.is_target_valid(casting_ability, Globals.turn_entity.global_position, get_global_mouse_position()):
			print("yes")
			# remove range indicators
			range_highlight.visible = not range_highlight.visible
			
			# reset cursor
			highlight_interface.shown_positions = []
			
			match [casting_ability.ability_type]:
				["player_movement"]:
					Globals.turn_entity.ap -= 1
				[_]:
					ability_execute(casting_ability, tilemap.selected_tile_loc)
					Globals.turn_entity.ap = 0		
				
var spell_test = preload('res://ui/highlight_square.tscn')
func ability_execute(casted_ability: AbilityData, cast_location: Vector2):
	if Globals.turn_entity.ap > 0:
		update_cooldown_display(casted_ability)
	
		## TODO not sure if this is correct								
		for n in live_abilities.get_children():
			live_abilities.remove_child(n)
			n.queue_free()
			
		match [casted_ability.ability_type]:
			["RangedAOE"]:
				var spell = spell_test.instantiate()
				live_abilities.add_child(spell)
				spell.global_position = cast_location
				spell.modulate = Color(0,1,0)
				casted_ability._damage(casted_ability, selected_body)
			["mining"]:
				casted_ability._mine(casted_ability, selected_terrain)


func update_cooldown_display(casted_ability: AbilityData):
	Globals.turn_entity.cd_array[Globals.spell_ind] = casted_ability.cooldown
	Globals.spell_ind = -1
	UiBattle.action_bar.update_action_bar(Globals.turn_entity.action_bar_data,
										  Globals.turn_entity.cd_array)
