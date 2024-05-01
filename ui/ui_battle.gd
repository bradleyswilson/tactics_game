extends CanvasLayer

@onready var inventory_interface = $InventoryInterface
@onready var action_bar = $ActionBar
@onready var entity_info_container = $EntityInfoContainer
@onready var turn_order_display = $TurnOrderDisplay

const ENTITY_INFO = preload("res://ui/entity_info.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	Globals.stat_change.connect(update_entity_info)

func battle_start():
	turn_order_display.set_turn_data(Globals.turn_queue)
	
func toggle_enemy_details(enemy: Enemy):
	if enemy:
		var entity_info = ENTITY_INFO.instantiate()
		entity_info_container.add_child(entity_info)
		entity_info.set_entity_info(enemy)
		entity_info_container.visible = not entity_info_container.visible
	
	# if not visible, clear the data
	if not entity_info_container.visible:
		for n in entity_info_container.get_children():
			n.queue_free()

func update_entity_info():
	if Globals.hover_entity is Enemy:
		entity_info_container.get_children()[0].progress_bar.value = Globals.hover_entity.health

