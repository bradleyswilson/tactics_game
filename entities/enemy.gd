extends Entity
class_name Enemy 

func _ready():
	StatusEffects.on_entity_death.connect(_on_entity_death)
	action_bar_data = load("res://actionbar/test_enemy_actionbar.tres")
	#
func _on_entity_death(entity: Entity):
	if entity == self:
		super._on_entity_death(entity)
	

