extends Control

@onready var portrait = $MarginContainer/ColorRect/Portrait
@onready var progress_bar = $MarginContainer/HealthBar/ProgressBar

# Called when the node enters the scene tree for the first time.
#func _ready():
	#var entity: Entity
	#set_entity_info(entity)

func set_entity_info(entity: Entity):
	if entity:
		portrait.texture = entity.get_child(0).texture
		progress_bar.value = entity.health
