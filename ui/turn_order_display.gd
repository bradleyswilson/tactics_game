extends Control

@onready var h_box_container = $HBoxContainer

const ENTITY_INFO = preload("res://ui/entity_info.tscn")

func set_turn_data(turn_queue: Array[Entity]) -> void:
	populate_turn_display(turn_queue)
	
func populate_turn_display(turn_queue: Array[Entity]) -> void:
	for child in h_box_container.get_children():
		child.queue_free()
	
	for entity in turn_queue:
		if entity:
			var entity_info = ENTITY_INFO.instantiate()
			h_box_container.add_child(entity_info)
			entity_info.set_entity_info(entity)
