extends Node2D
class_name LevelParent

@onready var player: CharacterBody2D = $Player
@onready var enemy = $Enemy
@onready var tilemap = $Tilemap
@onready var highlight_interface = $HighlightInterface
@onready var range_highlight = $HighlightInterface/Abilities
@onready var spell_manager = $SpellManager
@onready var active_entities: Array
var casting_ability: AbilityData

signal ability_confirmed(ability_data: AbilityData)

func _ready():
	active_entities = [player, enemy]
	Globals.player_pos = player.global_position # set original play pos
	player.move.connect(_on_show_range)
	spell_manager.show_range.connect(_on_show_range)
	spell_manager.ability_confirm.connect(_on_ability_confirm)

func _unhandled_input(event):
	if Input.is_action_just_pressed("left_click"):
		var cell = query_tile(tilemap.selected_tile_map, active_entities)
		print(cell)
		
func query_tile(target_cell: Vector2i, active_entities: Array):
	for entity in active_entities:
		if tilemap.local_to_map(entity.global_position) == target_cell:
			return entity
	return null
	
func _physics_process(delta):
	if tilemap.get_cell_tile_data(0,tilemap.selected_tile_map):
		$HighlightInterface/Cursor.show()		
		highlight_interface.show_cursor(tilemap.selected_tile_loc + Vector2i(0, 8)) 
	else:
		$HighlightInterface/Cursor.hide()
	
func _on_show_range(ability_data: AbilityData) -> void:
	var range = ability_data.ability_range
	range_highlight.visible = not range_highlight.visible
	highlight_interface.show_range(range, tilemap.player_tile_loc)
		
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
				ability_execute(casting_ability, tilemap.selected_tile_loc)
				range_highlight.visible = not range_highlight.visible
			
				
var spell_test = preload('res://scenes/highlight_square.tscn')
func ability_execute(casted_ability: AbilityData, cast_location: Vector2):
	for n in spell_manager.get_children():
		spell_manager.remove_child(n)
		n.queue_free()
		
	match [casted_ability.ability_type]:
		["RangedAOE"]:
			#print(enemy.health)
			var spell = spell_test.instantiate()
			spell_manager.add_child(spell)
			spell.global_position = cast_location - Vector2(0, -8)
			spell.modulate = Color(0,1,0)
			casted_ability._damage(casted_ability, query_tile(tilemap.selected_tile_map, active_entities))
			#print(enemy.health)
