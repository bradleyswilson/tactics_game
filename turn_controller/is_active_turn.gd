class_name IsActiveTurn
extends Turn

@export var turn_entity: Entity
var grabbed_ability: SlotData
var ability_data: ItemData

signal ability_used(ability_data: AbilityData, is_valid_cast: bool)
signal get_available_actions(Entity)
signal spawn()

func _ready():
	Globals.player_clicked_end_turn.connect(_on_player_endturn)
	pass
	#set_process(false)
	
func _enter_state() -> void:
	Globals.start_turn.emit()
	
	for i in range(turn_entity.cd_array.size()):
		turn_entity.cd_array[i] = max(0, turn_entity.cd_array[i] - 1)
	
	turn_entity.toggle_outline(true)
	Globals.turn_entity = turn_entity
	#turn_entity.ap = 2
	if turn_entity is PlayableEntity:
		UiBattle.action_bar.set_player_ability_data(turn_entity.action_bar_data, turn_entity.cd_array)
		turn_entity.action_bar_data.ability_used.connect(on_ability_used)
		turn_entity.endturn_direction.connect(_on_endturn_direction)
	
	elif turn_entity is Enemy:
		get_available_actions.emit(turn_entity)

func _exit_state():
	Globals.end_turn.emit()
	turn_entity.toggle_outline(false)
	turn_entity.ap = 2
	if turn_entity is PlayableEntity:
		turn_entity.action_bar_data.ability_used.disconnect(on_ability_used)
		turn_entity.direction_indicator.hide()
		turn_entity.endturn_direction.disconnect(_on_endturn_direction)
	
		#var click_position = get_global_mouse_position()
		#turn_entity.face_direction(click_position)
	

func _input(event):
	if event.is_action_pressed("interact"):
		if turn_entity is PlayableEntity:
			turn_entity.turnable = true
			turn_entity.ending_turn = true
			turn_entity.direction_indicator.show()
			turn_entity.set_process(true)
		else:
			state_finished.emit()

func _on_player_endturn():
	if turn_entity is PlayableEntity:
		turn_entity.turnable = true
		turn_entity.ending_turn = true
		turn_entity.direction_indicator.show()
		turn_entity.set_process(true)
	else:
		state_finished.emit()
	
func _on_endturn_direction():
	state_finished.emit()

func on_ability_used(ability_datas: InventoryData, index: int) -> void:
	grabbed_ability = ability_datas.grab_ability_data(index)
	ability_data = grabbed_ability.item_data
	var is_valid_cast = true if turn_entity.cd_array[index] == 0 else false
	
	Globals.spell_ind = index
	if is_valid_cast:
		ability_used.emit(ability_data, is_valid_cast)
		turn_entity.turnable = true
		turn_entity.turnable = true
		turn_entity.set_process(true)
