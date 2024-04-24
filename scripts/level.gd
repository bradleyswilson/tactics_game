extends Node2D
class_name LevelParent

@onready var player: CharacterBody2D = $Player
@onready var tilemap = $Tilemap
@onready var highlight_interface = $HighlightInterface
@onready var can_cast: bool
@onready var spell_manager = $SpellManager

var casting_ability: AbilityData

	
func _ready():
	can_cast = false
	Globals.player_pos = player.global_position # set original play pos
	player.move.connect(_on_show_range)
	spell_manager.show_range.connect(_on_show_range)
	spell_manager.ability_confirm.connect(_on_ability_confirm)
	#player.ability_confirm.connect(_on_ability_confirm)


# if its hidden, turns visible

func _on_show_range(ability_data: AbilityData) -> void:
	var range = ability_data.ability_range
	highlight_interface.visible = not highlight_interface.visible
	highlight_interface.show_range(range, tilemap.player_tile)
	
	if highlight_interface.visible:
		casting_ability = ability_data
	else:
		casting_ability = null

# doesn't handle when player clicks outside valid range for other spells yet
func _on_ability_confirm() -> void:
	if casting_ability != null:
		match [casting_ability.ability_type]:
			["player_movement"]:
				if tilemap.set_movement_coords(player, Globals.player_pos):
					highlight_interface.visible = not highlight_interface.visible
			[_]:
				print("casting_ability")
				highlight_interface.visible = not highlight_interface.visible
