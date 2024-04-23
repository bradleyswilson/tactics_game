extends Node2D
class_name LevelParent

@onready var player: CharacterBody2D = $Player
@onready var tilemap = $Tilemap
@onready var highlight_interface = $HighlightInterface
@onready var can_cast: bool

func _ready():
	can_cast = false
	player.ability.connect(on_ability_button_pressed)
	player.confirm.connect(on_confirm)
	Globals.player_pos = player.global_position # set original play pos

func on_ability_button_pressed() -> void:
	var range = player.movement_range

	if highlight_interface.hidden: 
		highlight_interface.visible = not highlight_interface.visible
		can_cast = not can_cast
		highlight_interface.show_range(range, tilemap.player_tile)
		
func on_confirm() -> void:
	if can_cast:
		if tilemap.set_movement_coords(player, Globals.player_pos):
			highlight_interface.visible = not highlight_interface.visible
			can_cast = not can_cast
		
