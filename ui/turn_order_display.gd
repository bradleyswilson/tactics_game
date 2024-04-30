extends Control

@onready var h_box_container = $HBoxContainer

const ENTITY_INFO = preload("res://ui/entity_info.tscn")

func _ready():
	Globals.stat_change.connect(update_turn_display)
	
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

func update_turn_display():
	for child in h_box_container.get_children():
		child.queue_free()
		
	for entity in Globals.turn_queue:
		if entity:
			var entity_info = ENTITY_INFO.instantiate()
			h_box_container.add_child(entity_info)
			entity_info.set_entity_info(entity)
