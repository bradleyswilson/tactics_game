class_name CharacterAction
extends State

var action_entity: Entity
var grabbed_ability: SlotData
var ability_data: ItemData

signal ability_used(ability_data: AbilityData, is_valid_cast: bool)
signal get_available_actions(Entity)
signal spawn()

func _ready():
	pass
	#set_process(false)
	
func set_action_entity(entity: Entity) -> void:
	action_entity = entity
	
func _enter_state() -> void:
	action_entity.toggle_outline(true)
	
	Globals.turn_entity = action_entity
	action_entity.ap = 2
	if action_entity is PlayableEntity:
		UiBattle.action_bar.set_player_ability_data(action_entity.action_bar_data, action_entity.cd_array)
		action_entity.action_bar_data.ability_used.connect(on_ability_used)
		action_entity.endturn_direction.connect(_on_endturn_direction)
	
	elif action_entity is Enemy:
		get_available_actions.emit(action_entity)

func _exit_state():
	Globals.end_turn.emit()
	action_entity.toggle_outline(false)
	action_entity.ap = 2
	if action_entity is PlayableEntity:
		action_entity.action_bar_data.ability_used.disconnect(on_ability_used)
		action_entity.direction_indicator.hide()
		action_entity.endturn_direction.disconnect(_on_endturn_direction)
	
		#var click_position = get_global_mouse_position()
		#action_entity.face_direction(click_position)

func _input(event):
	if event.is_action_pressed("interact"):
		if action_entity is PlayableEntity:
			action_entity.turnable = true
			action_entity.ending_turn = true
			action_entity.direction_indicator.show()
			action_entity.set_process(true)
		else:
			state_finished.emit()

func _on_player_endturn():
	if action_entity is PlayableEntity:
		action_entity.turnable = true
		action_entity.ending_turn = true
		action_entity.direction_indicator.show()
		action_entity.set_process(true)
	else:
		state_finished.emit()
	
func _on_endturn_direction():
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
