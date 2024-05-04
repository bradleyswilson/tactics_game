extends Node2D
class_name LevelParent

@onready var party_member = preload("res://entities/player.tscn")
@onready var enemy = preload("res://entities/enemy.tscn")

@onready var party = $Party
@onready var enemies = $Enemies
@onready var tilemap = $Tilemap

#@onready var range_highlight = $HighlightInterface/Abilities
@onready var highlight_interface = $GameState/AbilityManager/HighlightInterface
@onready var cursor = $GameState/AbilityManager/HighlightInterface/Cursor

@onready var active_entities: Array
@onready var turn_manager = $GameState/TurnManager

var selected_body
var temp_body
var casting_ability: AbilityData

signal ability_confirmed(ability_data: AbilityData)

func _ready():
	start_battle()
	active_entities += $Party.get_children()
	active_entities += $Enemies.get_children()
	#TODO sort by initiative?
	_update()
	
func start_battle():
	var char1 = party_member.instantiate()
	var char2 = party_member.instantiate()
	party.add_child(char1)
	party.add_child(char2)
	party.get_children()[0].global_position = tilemap.map_to_local(Vector2i(9,4))
	party.get_children()[1].global_position = tilemap.map_to_local(Vector2i(12,4))
	
	var enemy1 = enemy.instantiate()
	var enemy2 = enemy.instantiate()
	enemies.add_child(enemy1)
	enemies.add_child(enemy2)
	enemies.get_children()[0].global_position = tilemap.map_to_local(Vector2i(11,-3)) 
	enemies.get_children()[1].global_position = tilemap.map_to_local(Vector2i(15,-3))
	
func _update():
	Globals.turn_queue.assign(active_entities)
	turn_manager.start_turn(active_entities[0])
	UiBattle.battle_start()

func _input(event):
	if event.is_action_pressed('start_battle'):
		_update()
		UiBattle.show()
		


