extends CanvasLayer

@onready var inventory_interface = $InventoryInterface
@onready var action_bar = $ActionBar
@onready var entity_info_container = $EntityInfoContainer
@onready var turn_order_display = $TurnOrderDisplay
@onready var tilemap = get_tree().get_nodes_in_group("tilemaps")[0]
@onready var pathfinder = get_tree().get_nodes_in_group("pathfinder")[0]
var temp_body

const ENTITY_INFO = preload("res://ui/entity_info.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	Globals.new_level.connect(on_new_level)
	Globals.stat_change.connect(update_entity_info)

func _physics_process(_delta):
	if tilemap.get_cell_tile_data(0,tilemap.selected_tile_map):
		pathfinder.cursor.show()		
		pathfinder.show_cursor(tilemap.selected_tile_loc) 
	else:
		pathfinder.cursor.hide()
		
func battle_start():
	turn_order_display.set_turn_data(Globals.turn_queue)
	pathfinder.cursor.get_children()[0].highlight_entered.connect(on_body_entered)
	pathfinder.cursor.get_children()[0].highlight_exited.connect(on_body_exited)
	
func on_body_entered(body):
	temp_body = body
	if temp_body is Enemy:
		Globals.hover_entity = temp_body
		UiBattle.toggle_enemy_details(Globals.hover_entity)
	
func on_body_exited(body):
	if temp_body == body:
		temp_body = null
		if Globals.hover_entity is Enemy:
			UiBattle.toggle_enemy_details(Globals.hover_entity)
			Globals.hover_entity = null
			
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
	if entity_info_container:
		if Globals.hover_entity is Enemy:
			entity_info_container.get_children()[0].progress_bar.value = Globals.hover_entity.health

func on_new_level():
	print("new_level")
	for n in entity_info_container.get_children():
			n.queue_free()
