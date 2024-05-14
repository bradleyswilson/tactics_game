extends CharacterBody2D
class_name Entity

@export var speed = 300
#@export var move_data: AbilityData
@export var inventory_data: InventoryData
@export var action_bar_data: InventoryData
@export var health = 100
@export var texture = Texture2D
@export var cd_array = []
@export var ap = 10

const MIN_HP: int = 0

func toggle_outline(enabled: bool):
	$Sprite2D.material.set_shader_parameter("enable_outline", enabled) 
#
func _on_entity_death(entity: Entity):
	var ind = Globals.turn_queue.find(entity)
	Globals.turn_queue.remove_at(ind)
	UiBattle.turn_order_display.update_turn_display()
	Globals.hover_entity = null
	UiBattle.entity_info_container.hide()
	entity.queue_free()
	
	var live_party = Globals.turn_queue.any(func(ent): return ent is PlayableEntity)
	var live_enemies = Globals.turn_queue.any(func(ent): return ent is Enemy)
	if not live_party:
		Globals.level_over.emit('lose')
	
	if not live_enemies:
		print('win')
		Globals.level_over.emit('win')

	
	#self.queue_free()
	
