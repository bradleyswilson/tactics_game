extends Node2D
class_name LevelParent

@onready var player: CharacterBody2D = $Player
@onready var tilemap = $Tilemap
@onready var highlight_interface = $HighlightInterface
@onready var can_cast: bool

var offset_x = Vector2(-32,-16)
var offset_y = Vector2(32, -16)

func _ready():
	can_cast = false
	player.ability.connect(on_ability_button_pressed)
	player.confirm.connect(on_confirm)
	Globals.player_pos = player.global_position # set original play pos

# on_spell_cast()
# show range - togglable
# confirm cast (toggles off range indicator)
# cast
#
func on_ability_button_pressed() -> void:
	var range = player.movement_range

	if highlight_interface.hidden: 
		highlight_interface.visible = not highlight_interface.visible
		can_cast = not can_cast
		show_range(range, tilemap.player_tile)
		
func on_confirm() -> void:
	if can_cast:
		if tilemap.set_movement_coords(player, Globals.player_pos):
			highlight_interface.visible = not highlight_interface.visible
			can_cast = not can_cast
		
func show_range(movement_range: int, source_loc: Vector2):
	var Square = preload("res://scenes/highlight_square.tscn")
	# Clear existing children from the highlight interface, if needed
	for n in highlight_interface.get_children():
		highlight_interface.remove_child(n)
		n.queue_free()

	for dx in range(-movement_range, movement_range + 1):
		for dy in range(-movement_range, movement_range + 1):
			if abs(dx) + abs(dy) <= movement_range:
				var square = Square.instantiate()
				highlight_interface.add_child(square)
				# Position each square using isometric offset calculations
				var pos_x = dx * offset_x.x * 0.5  + dy * offset_y.x * 0.5
				var pos_y = dx * offset_x.y * 0.5  + dy * offset_y.y * 0.5
				square.global_position = source_loc - Vector2(0, -8) +  Vector2(pos_x, pos_y)
