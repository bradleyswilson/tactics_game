extends Node2D
class_name LevelParent

@onready var player: CharacterBody2D = $Party/Player
@onready var party = $Party.get_children()
@onready var enemies = $Enemies.get_children()
@onready var enemy = $Enemies/Enemy
@onready var tilemap = $Tilemap
@onready var highlight_interface = $HighlightInterface
@onready var range_highlight = $HighlightInterface/Abilities
@onready var spell_manager = $SpellManager
@onready var active_entities: Array
@onready var turn_manager = $TurnManager

var selected_body
var temp_body
var casting_ability: AbilityData

signal ability_confirmed(ability_data: AbilityData)

func _ready():
	active_entities += party
	active_entities += enemies
	#TODO sort by initiative?
	
	$TurnManager/ActiveTurn.ability_used.connect(show_range)
	$HighlightInterface/Cursor.get_children()[0].highlight_entered.connect(on_body_entered)
	$HighlightInterface/Cursor.get_children()[0].highlight_exited.connect(on_body_exited)
	
func _update():
	Globals.turn_queue.assign(active_entities)
	turn_manager.start_turn(active_entities[0])
	UiBattle.battle_start()
	
func _input(event):
	if event.is_action_pressed('start_battle'):
		_update()
	if event.is_action_released("confirm_click"):
		selected_body = Globals.hover_entity
		_on_ability_confirm()
		
func on_body_entered(body):
	temp_body = body
	if temp_body is Enemy:
		Globals.hover_entity = temp_body
		UiBattle.toggle_enemy_details(Globals.hover_entity)
	
func on_body_exited(body):
	if temp_body == body:
		temp_body = null
		if Globals.hover_entity is Enemy:
			UiBattle.toggle_enemy_details(Globals.hover_entity)
			Globals.hover_entity = null
			
func _physics_process(_delta):
	if tilemap.get_cell_tile_data(0,tilemap.selected_tile_map):
		$HighlightInterface/Cursor.show()		
		highlight_interface.show_cursor(tilemap.selected_tile_loc + Vector2i(0, 8)) 
	else:
		$HighlightInterface/Cursor.hide()
		
func show_range(ability_data: AbilityData) -> void:
	# turns on range indicators and sets ability data
	var ability_range = ability_data.ability_range
	range_highlight.visible = not range_highlight.visible
	highlight_interface.show_range(ability_range, tilemap.player_tile_loc)
	
	for i in range_highlight.get_children():
		if tilemap.get_cell_tile_data(0,  
		tilemap.local_to_map(i.global_position - Vector2(0, 8))) == null:
			i.queue_free()
		
	if range_highlight.visible:
		casting_ability = ability_data
	else:
		casting_ability = null

func _on_ability_confirm() -> void:
	# if a casted ability is loaded, matches ability type, checks range,
	# and calls execute function
	if casting_ability != null:
		match [casting_ability.ability_type]:
			["player_movement"]:
				if tilemap.check_range(player.move_data, Globals.player_pos):
					range_highlight.visible = not range_highlight.visible
			["RangedAOE"]:
				if tilemap.check_range(casting_ability, Globals.player_pos):
					ability_execute(casting_ability, tilemap.selected_tile_loc)
					range_highlight.visible = not range_highlight.visible
					casting_ability = null
				else:
					print('exceeds range')

				
var spell_test = preload('res://ui/highlight_square.tscn')
func ability_execute(casted_ability: AbilityData, cast_location: Vector2):
	for n in spell_manager.get_children():
		spell_manager.remove_child(n)
		n.queue_free()
		
	match [casted_ability.ability_type]:
		["RangedAOE"]:
			var spell = spell_test.instantiate()
			spell_manager.add_child(spell)
			spell.global_position = cast_location - Vector2(0, -8)
			spell.modulate = Color(0,1,0)
			casted_ability._damage(casted_ability, selected_body)



