extends Node2D

@onready var Square = preload("res://ui/highlight_square.tscn")
@onready var cursor_square = Square.instantiate()

var temp_body

@onready var tilemap = get_tree().get_nodes_in_group("tilemaps")[0]

func _ready():
	add_child(cursor_square)
	get_children()[0].highlight_entered.connect(on_body_entered)
	get_children()[0].highlight_exited.connect(on_body_exited)

func _process(_delta):
	if tilemap.get_cell_tile_data(0,tilemap.selected_tile_map):
		show()		
		show_cursor(tilemap.selected_tile_loc) 
	else:
		hide()

func show_cursor(source_loc: Vector2):
	cursor_square.global_position = source_loc
	cursor_square.modulate = Color(0,0,1)
	cursor_square.top_level = true
		
func on_body_entered(body):
	temp_body = body
	if temp_body is Enemy:
		Globals.hover_entity = temp_body
		Globals.toggle_enemy_details.emit(Globals.hover_entity)
	if temp_body is TileMap:
		var cell = tilemap.local_to_map(tilemap.get_global_mouse_position()) - Vector2i(1,1)
		if cell in Globals.gridData:
			Globals.hover_terrain = Globals.gridData[cell]
			Globals.toggle_terrain_details.emit(Globals.hover_terrain)
	
func on_body_exited(body):
	if temp_body == body:
		temp_body = null
		if Globals.hover_entity is Enemy:
			Globals.toggle_enemy_details.emit(Globals.hover_entity)
			Globals.hover_entity = null
		if Globals.hover_terrain is CellData:
			Globals.hover_terrain = null
			Globals.toggle_terrain_details.emit(Globals.hover_terrain)
			
			
