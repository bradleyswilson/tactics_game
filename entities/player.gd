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
	StatusEffects.on_entity_death.connect(_on_entity_death)
	
func _on_entity_death(entity: Entity):
	if entity == self:
		super._on_entity_death(entity)
		
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		toggle_inventory.emit()
		
	#if Input.is_action_just_pressed("interact"):
		#interact()
