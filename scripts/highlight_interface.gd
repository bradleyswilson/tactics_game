extends Node2D

var offset_x = Vector2(-32,-16)
var offset_y = Vector2(32, -16)

func show_range(movement_range: int, source_loc: Vector2):
	var Square = preload("res://scenes/highlight_square.tscn")
	# Clear existing children from the highlight interface, if needed
	for n in get_children():
		remove_child(n)
		n.queue_free()

	for dx in range(-movement_range, movement_range + 1):
		for dy in range(-movement_range, movement_range + 1):
			if abs(dx) + abs(dy) <= movement_range:
				var square = Square.instantiate()
				add_child(square)
				# Position each square using isometric offset calculations
				var pos_x = dx * offset_x.x * 0.5  + dy * offset_y.x * 0.5
				var pos_y = dx * offset_x.y * 0.5  + dy * offset_y.y * 0.5
				square.global_position = source_loc - Vector2(0, -8) +  Vector2(pos_x, pos_y)
