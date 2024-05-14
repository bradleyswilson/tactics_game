extends Node2D

@onready var Square = preload("res://ui/highlight_square.tscn")

@onready var cursor_positions: Array = []
@onready var cursor_array: Array
@onready var cursor_range: int
@onready var tilemap = get_tree().get_nodes_in_group("tilemaps")[0]
var temp_body

func _ready():
	cursor_range = 0


func _physics_process(_delta):
	if tilemap.get_cell_tile_data(0,tilemap.selected_tile_map):
		show()		
		
		if get_children().is_empty():
			add_cursors(1)

		cursor_positions = get_cursor_pos(cursor_range, Vector2(tilemap.selected_tile_loc))
		show_cursors(get_children(), cursor_positions) 
	else:
		hide()

func add_cursors(n_cursors):
	remove_cursors()
	
	for i in range(0, n_cursors):
		var square = Square.instantiate()
		add_child(square)
		square.modulate = Color.DARK_BLUE
	
	if get_children().size() == 1:
		get_child(0).highlight_entered.connect(on_body_entered)
		get_child(0).highlight_exited.connect(on_body_exited)
	
func remove_cursors():
	for n in get_children():
		n.queue_free()

func show_cursors(cursors: Array, source_loc: Array):
	if cursors.size() > source_loc.size():
		cursors.pop_front()
		
	if source_loc and cursors:
		for i in range(0, cursors.size()):
			cursors[i].global_position = source_loc[i]
			cursors[i].top_level = true
		#
func get_cursor_pos(cursor_range: int, current_loc: Vector2):
	var offset_x = Vector2(-32,-16)
	var offset_y = Vector2(32, -16)
	
	var current_positions: Array = [current_loc]
	for dx in range(-cursor_range, cursor_range + 1):
		for dy in range(-cursor_range, cursor_range + 1):
			if abs(dx) + abs(dy) <= cursor_range:
				var pos_x = dx * offset_x.x * 0.5  + dy * offset_y.x * 0.5
				var pos_y = dx * offset_x.y * 0.5  + dy * offset_y.y * 0.5
				var target_position = current_loc +  Vector2(pos_x, pos_y)
				if target_position != current_loc:
					current_positions.append(target_position)	
	return(current_positions)


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
			
			
