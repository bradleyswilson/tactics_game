extends CharacterBody2D
class_name Entity

@export var speed = 300
#@export var move_data: AbilityData
@export var inventory_data: InventoryData
@export var action_bar_data: InventoryData
@export var health = 100
@export var texture = Texture2D

const MIN_HP: int = 0

func toggle_outline(enabled: bool):
	$Sprite2D.material.set_shader_parameter("enable_outline", enabled) 

func _on_entity_death(entity: Entity):
	var ind = Globals.turn_queue.find(entity)
	Globals.turn_queue.remove_at(ind)
	UiBattle.turn_order_display.update_turn_display()
	entity.queue_free()
	print('dead!')
	
	#self.queue_free()
	
