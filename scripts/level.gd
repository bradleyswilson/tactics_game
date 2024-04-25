extends Node2D
class_name LevelParent

@onready var player: CharacterBody2D = $Player
@onready var tilemap = $Tilemap
@onready var highlight_interface = $HighlightInterface
@onready var range_highlight = $HighlightInterface/Abilities
@onready var spell_manager = $SpellManager
@onready var active_entities: Array
var casting_ability: AbilityData


func _ready():
	active_entities = [player]
	Globals.player_pos = player.global_position # set original play pos
	player.move.connect(_on_show_range)
	spell_manager.show_range.connect(_on_show_range)
	spell_manager.ability_confirm.connect(_on_ability_confirm)

func _unhandled_input(event):
	if Input.is_action_just_pressed("left_click"):
		var cell = query_tile(tilemap.local_to_map(get_global_mouse_position()),
		active_entities)
		print(cell)
		
func query_tile(target_cell: Vector2i, active_entities: Array):
	for entity in active_entities:
		if tilemap.local_to_map(entity.global_position) == target_cell:
			return entity
	return null
	
func _physics_process(delta):
	if tilemap.selected_tile and tilemap.get_cell_tile_data(0, 
			tilemap.local_to_map(tilemap.selected_tile)):
		$HighlightInterface/Cursor.show()		
		highlight_interface.show_cursor(tilemap.selected_tile + Vector2(0, 8)) 
	else:
		$HighlightInterface/Cursor.hide()
	
func _on_show_range(ability_data: AbilityData) -> void:
	var range = ability_data.ability_range
	range_highlight.visible = not range_highlight.visible
	highlight_interface.show_range(range, tilemap.player_tile)
	
	if range_highlight.visible:
		casting_ability = ability_data
	else:
		casting_ability = null

#todo - doesn't handle when player clicks outside valid range for other spells yet
func _on_ability_confirm() -> void:
	if casting_ability != null:
		match [casting_ability.ability_type]:
			["player_movement"]:
				if tilemap.set_movement_coords(player, Globals.player_pos):
					range_highlight.visible = not range_highlight.visible
			[_]:
				print("casting_ability")
				range_highlight.visible = not range_highlight.visible
