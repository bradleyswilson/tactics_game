extends Node2D

@onready var Square = preload("res://ui/highlight_square.tscn")
@onready var Plus = preload("res://ui/highlight_plus.tscn")
@onready var tilemap = get_tree().get_nodes_in_group("tilemaps")[0]

var temp_body
var current_cursor
var _last_type

func _ready():
	var single_cursor = Square.instantiate()
	add_child(single_cursor)
	current_cursor = single_cursor
	current_cursor.highlight_entered.connect(on_body_entered)
	current_cursor.highlight_exited.connect(on_body_exited)

func _physics_process(_delta):
	if tilemap.get_cell_tile_data(0,tilemap.selected_tile_map):
		show()		
		current_cursor.global_position = tilemap.selected_tile_loc
		current_cursor.top_level = true			
	else:
		hide()

func swap_cursor(cursor_type):
	for n in get_children():
		n.queue_free()
	
	if cursor_type == "plus" and _last_type != "plus":
		var plus_cursor = Plus.instantiate()
		add_child(plus_cursor)
		current_cursor = plus_cursor
		_last_type = 'plus'
	else:
		var single_cursor = Square.instantiate()
		add_child(single_cursor)
		current_cursor = single_cursor
		_last_type = 'square'
		
	current_cursor.highlight_entered.connect(on_body_entered)
	current_cursor.highlight_exited.connect(on_body_exited)
		
func on_body_entered(body):
	temp_body = body
	if temp_body is Entity:
		Globals.hover_entity = temp_body
		Globals.toggle_entity_details.emit(Globals.hover_entity)
	elif temp_body is TileMap:
		var cell = tilemap.local_to_map(tilemap.get_global_mouse_position()) - Vector2i(1,1)
		if cell in Globals.gridData:
			Globals.hover_terrain = Globals.gridData[cell]
			Globals.toggle_terrain_details.emit(Globals.hover_terrain)
	
func on_body_exited(body):
	if temp_body == body:
		temp_body = null
		if Globals.hover_entity is Entity:
			Globals.toggle_entity_details.emit(Globals.hover_entity)
			Globals.hover_entity = null
		elif Globals.hover_terrain is CellData:
			Globals.hover_terrain = null
			Globals.toggle_terrain_details.emit(Globals.hover_terrain)
			
			
