extends ItemData
class_name AbilityData

@export var ability_name: String = ""
@export var ability_type: String = ""
@export var ability_damage: float = 0.0
@export var ability_range: int
@export var cooldown : float


func _damage(ability_data: AbilityData, target: Entity):
	if target:
		target.health -= ability_data.ability_damage
		Globals.stat_change.emit()
		#print(target.health)

