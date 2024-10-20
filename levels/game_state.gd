extends Node


@onready var turn_manager = $TurnManager
@onready var active_turn = $TurnManager/ActiveTurn
@onready var ability_manager = $AbilityManager
@onready var highlight_interface = $AbilityManager/HighlightInterface
@onready var enemy_spawner = $TurnManager/EnemySpawner
@onready var tilemap = $Tilemap


#  Enemy spawning
@onready var enemies = $Enemies
const ENEMY = preload("res://entities/enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	active_turn.ability_used.connect(ability_manager.ability_eval)
	active_turn.get_available_actions.connect(ability_manager.ai_available_actions)
	Globals.start_turn.connect(on_start_turn)
	Globals.spawn.connect(on_spawn)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func on_start_turn():
	highlight_interface.clear_range()
	
func on_spawn():
	var invalid_cells = []
	invalid_cells.append_array(tilemap.cell_local_pos)
	invalid_cells.append_array(Globals.entities_pos)
	
	var new_enemy = ENEMY.instantiate()
	enemies.add_child(new_enemy)
	enemies.get_children()[-1].global_position = tilemap.map_to_local(Vector2i(12,-3)) 
	
	Globals.turn_queue.append(new_enemy)
	## TODO 
	# Add into turn queue - new enemies don't show up. 
