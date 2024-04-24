extends Resource
class_name ActionBarData

@export var action_bar_data: Array[AbilityData]

signal ability_use(action_bar_data: ActionBarData, index: int)

func on_slot_pressed(index: int) -> void:
	ability_use.emit(self, index)


