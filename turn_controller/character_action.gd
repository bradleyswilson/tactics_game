class_name CharacterAction
extends State

var action_entity: Entity
var grabbed_ability: SlotData
var ability_data: ItemData

signal ability_used(ability_data: AbilityData, is_valid_cast: bool)
signal get_available_actions(Entity)
signal enemy_action_completed
	
func set_action_entity(entity: Entity) -> void:
	action_entity = entity
	
func _enter_state() -> void:
	Globals.start_action.emit()
	Globals.action_entity = action_entity
	action_entity.toggle_outline(true)
	action_entity.ap = 2
	if action_entity is PlayableEntity:
		UiBattle.action_bar.set_player_ability_data(action_entity.action_bar_data, action_entity.cd_array)
		action_entity.action_bar_data.ability_used.connect(on_ability_used)
		#action_entity.endturn_direction.connect(_on_endturn_direction)
	
	elif action_entity is Enemy:
		get_available_actions.emit(action_entity)

func _exit_state():
	Globals.end_action.emit()
	action_entity.set_process(false)
	action_entity.toggle_outline(false)
	action_entity.has_acted = true

	if action_entity is PlayableEntity:
		action_entity.action_bar_data.ability_used.disconnect(on_ability_used)
		action_entity.direction_indicator.hide()
		#action_entity.endturn_direction.disconnect(_on_endturn_direction)
	state_finished.emit()
	
func on_ability_used(ability_datas: InventoryData, index: int) -> void:
	grabbed_ability = ability_datas.grab_ability_data(index)
	ability_data = grabbed_ability.item_data
	var is_valid_cast = true if action_entity.cd_array[index] == 0 else false
	
	Globals.spell_ind = index
	if is_valid_cast:
		ability_used.emit(ability_data, is_valid_cast)
		action_entity.turnable = true
		action_entity.set_process(true)

func _on_endturn_direction():
	state_finished.emit()

#func end_action_rotation():
	#if action_entity is PlayableEntity:
		#action_entity.turnable = true
		#action_entity.ending_turn = true
		#action_entity.direction_indicator.show()
		#action_entity.set_process(true)
	#else:
		#state_finished.emit()
