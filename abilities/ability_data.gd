extends ItemData
class_name AbilityData

@export var ability_name: String = ""
@export var ability_type: String = ""
@export var ability_damage: float = 0.0
@export var ability_range: int
@export var cooldown : float

func _try_damage(ability_data: AbilityData, target: Entity):
	var start_health = target.health
	var end_health = target.health
	if target:
		end_health -= ability_data.ability_damage
	return(start_health - end_health)

func _damage(ability_data: AbilityData, target: Entity):
	if target:
		target.health -= ability_data.ability_damage
		Globals.stat_change.emit()
	
		if target.health <= target.MIN_HP:
			StatusEffects.on_entity_death.emit(target)
	#print(target.health)

