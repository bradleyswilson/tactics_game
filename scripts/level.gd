extends Node2D
class_name LevelParent

@onready var player: CharacterBody2D = $Player
@onready var tilemap = $Tilemap
@onready var highlight_interface = $HighlightInterface
@onready var can_cast: bool
@onready var spell_manager = $SpellManager

func _ready():
	can_cast = false
	player.ability.connect(_on_show_range)
	player.confirm.connect(on_confirm)
	Globals.player_pos = player.global_position # set original play pos
	spell_manager.show_range.connect(_on_show_range)

func _on_show_range(range: int) -> void:

	if highlight_interface.hidden: 
		highlight_interface.visible = not highlight_interface.visible
		can_cast = not can_cast
		highlight_interface.show_range(range, tilemap.player_tile)
	
func on_confirm() -> void:
	if can_cast:
		if tilemap.set_movement_coords(player, Globals.player_pos):
			highlight_interface.visible = not highlight_interface.visible
			can_cast = not can_cast
		
