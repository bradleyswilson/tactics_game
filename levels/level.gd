extends Node2D
class_name LevelParent

@export var turn_count: int
@export var level_turns: int

@onready var party_member = preload("res://entities/player.tscn")
@onready var enemy = preload("res://entities/enemy.tscn")

@onready var party = $GameState/Party
@onready var enemies = $GameState/Enemies
@onready var turn_dummy = $GameState/TurnDummy
@onready var tilemap = $GameState/Tilemap

@onready var active_entities: Array
@onready var turn_manager = $GameState/TurnManager

var selected_body
var temp_body
var casting_ability: AbilityData

func _ready():
	start_battle()
	active_entities += party.get_children()
	active_entities += enemies.get_children()
	level_turns = 5
	
	#TODO sort by initiative?
func start_battle():
	var char1 = party_member.instantiate()
	var char2 = party_member.instantiate()
	party.add_child(char1)
	party.add_child(char2)
	party.get_children()[0].global_position = tilemap.map_to_local(Vector2i(12,5))
	party.get_children()[1].global_position = tilemap.map_to_local(Vector2i(12,4))
	
	var enemy1 = enemy.instantiate()
	var enemy2 = enemy.instantiate()
	enemies.add_child(enemy1)
	enemies.add_child(enemy2)
	enemies.get_children()[0].global_position = tilemap.map_to_local(Vector2i(11,-3)) 
	enemies.get_children()[1].global_position = tilemap.map_to_local(Vector2i(15,-3))
	
func _update():
	Globals.turn_queue.assign(active_entities)
	Globals.turn_queue.append(turn_dummy)
	turn_manager.start_turn(active_entities[0])
	UiBattle.battle_start()
	print(Globals.turn_queue)

func _input(event):
	if event.is_action_pressed('start_battle'):
		_update()
		UiBattle.show()
		
