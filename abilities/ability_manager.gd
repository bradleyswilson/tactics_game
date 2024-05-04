extends Node2D

var grabbed_ability: SlotData

@onready var highlight_interface = $HighlightInterface
@onready var range_highlight = $HighlightInterface/Abilities
@onready var tilemap = get_tree().get_nodes_in_group("tilemaps")[0]
@onready var casting_ability
@onready var live_abilities = $LiveAbilities

var selected_body: Entity

signal ability_confirm()

	
func _input(event):
	if event.is_action_released("confirm_click"):
		selected_body = Globals.hover_entity
		_on_ability_confirm(casting_ability)

func ability_eval(ability_data: AbilityData, is_valid_cast: bool) -> AbilityData:
	"""
	Displays range indicators, returns ability data if highlight is on
	"""
	
	# if cast signal isn't valid (usually from CD, return nothing immediately)
	if not is_valid_cast:
		print("Cooldown not ready!")
		return null
	
	# show range indicators
	range_highlight.visible = not range_highlight.visible
	var collisions = true if ability_data.ability_name == 'move' else false
	highlight_interface.show_range(ability_data.ability_range, 
									Globals.entities_pos[0],
									collisions)
	
	# remove indicators that aren't on tile cells
	for i in range_highlight.get_children():
		if tilemap.get_cell_tile_data(0, tilemap.local_to_map(i.global_position)) == null:
			i.queue_free()
		
	casting_ability = ability_data if range_highlight.visible else null
	return(casting_ability)

func _on_ability_confirm(casting_ability: AbilityData) -> void:
	"""
	if a casted ability is loaded, matches ability type, checks range,
	# and calls execute function
	"""
	if casting_ability:
		match [casting_ability.ability_type]:
			["player_movement"]:
				if tilemap.is_target_valid(casting_ability, Globals.turn_entity.global_position, get_global_mouse_position()):
					range_highlight.visible = not range_highlight.visible
				else:
					print('invalid movement_target') # placeholder
			["RangedAOE"]:
				print(casting_ability)
				if tilemap.is_target_valid(casting_ability, Globals.turn_entity.global_position, get_global_mouse_position()):
					ability_execute(casting_ability, tilemap.selected_tile_loc)
					range_highlight.visible = not range_highlight.visible
					casting_ability = null
				else:
					print('ability exceeds range') # placeholder

				
var spell_test = preload('res://ui/highlight_square.tscn')
func ability_execute(casted_ability: AbilityData, cast_location: Vector2):
	update_cooldown_display(casted_ability)
										
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

func update_cooldown_display(casted_ability: AbilityData):
	Globals.turn_entity.cd_array[Globals.spell_ind] = casted_ability.cooldown
	Globals.spell_ind = -1
	UiBattle.action_bar.update_action_bar(Globals.turn_entity.action_bar_data,
										  Globals.turn_entity.cd_array)
