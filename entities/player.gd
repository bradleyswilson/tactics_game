extends Entity
class_name PlayableEntity

@onready var interact_ray = $InteractRay
@onready var animated_sprite = $AnimatedSprite

signal move(AbilityData)
signal toggle_inventory()
#signal ability_confirm(ability_name: String)
	
func _ready():
	health = 100
	speed = 100
	#ap = 10
	StatusEffects.on_entity_death.connect(_on_entity_death)
	cd_array.resize(len(action_bar_data.slot_datas))
	cd_array.fill(0)

	
func _on_entity_death(entity: Entity):
	if entity == self:
		super._on_entity_death(entity)
		
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		toggle_inventory.emit()
		
	#if Input.is_action_just_pressed("interact"):
		#interact()
