extends CanvasLayer

@onready var entity_info_container = $EntityInfoContainer
@onready var turn_order_display = $TurnOrderDisplay
@onready var cid_texture_rect = $CellInfoDisplay/TextureRect

const ENTITY_INFO = preload("res://ui/entity_info.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	Globals.new_level.connect(on_new_level)
	Globals.stat_change.connect(update_entity_info)
	Globals.toggle_enemy_details.connect(_toggle_enemy_details)
	Globals.toggle_terrain_details.connect(_toggle_terrain_details)
		
func battle_start():
	turn_order_display.set_turn_data(Globals.turn_queue)
	
func _toggle_terrain_details(cell_data: CellData):
	if cell_data:
		cid_texture_rect.texture = cell_data.texture
	else:
		cid_texture_rect.texture = null
		
func _toggle_enemy_details(enemy: Enemy):
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
