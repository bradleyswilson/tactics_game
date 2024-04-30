class_name IsActiveTurn
extends Turn

@export var turn_entity: Entity
var grabbed_ability: SlotData
var ability_data: ItemData

signal ability_used(ability_data: AbilityData)

func _ready():
	pass
	#set_process(false)
	
func _enter_state() -> void:
	Globals.turn_entity = turn_entity
	Globals.turn_entity_pos = turn_entity.global_position
	
	turn_entity.toggle_outline(true)
	if turn_entity is PlayableEntity:
		UiBattle.action_bar.set_player_ability_data(turn_entity.action_bar_data)
		turn_entity.action_bar_data.ability_used.connect(on_ability_used)
	
	elif turn_entity is Enemy:
		turn_entity.get_available_actions()
		


func _exit_state():
	turn_entity.toggle_outline(false)
	if turn_entity.action_bar_data != null:
		turn_entity.action_bar_data.ability_used.disconnect(on_ability_used)

func _input(event):
	if event.is_action_pressed("interact"):
		state_finished.emit()

func on_ability_used(ability_datas: InventoryData, index: int) -> void:
	grabbed_ability = ability_datas.grab_ability_data(index)
	ability_data = grabbed_ability.item_data
	match [ability_data.ability_type]:
		[_]:
			ability_used.emit(ability_data)
