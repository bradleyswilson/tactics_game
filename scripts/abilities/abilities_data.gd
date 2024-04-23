extends Resource
class_name AbilitiesData

@export var ability_data: Array[AbilityData]

signal ability_use(abilities_data: AbilitiesData, index: int)

func on_slot_pressed(index: int) -> void:
	ability_use.emit(self, index)


