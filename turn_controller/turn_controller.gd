class_name FiniteStateController
extends Node

@export var turn = Turn
@onready var spawn = $EnemySpawner
var turn_queue = Globals.turn_queue

# Called when the node enters the scene tree for the first time.
func _ready():
	turn = turn.new()
	#turn = active_turn
	turn.state_finished.connect(on_state_change)

func on_state_change():
	turn._exit_state()
	
	turn_queue.push_back(turn_queue.pop_front())
	check_board_state()
	print('start turn for: ', Globals.turn_queue[0])
	
	#start_turn(turn_queue[0])
	#character_action(turn_queue[0])
	#UiBattle.turn_order_display.set_turn_data(Globals.turn_queue)

func start_turn(turn_entity: Entity):
	pass

func character_action(turn_entity: Entity):
	turn.action_entity = turn_entity
	turn._enter_state()

func check_board_state():
	if Globals.turn_queue.size() <= 4:
		Globals.spawn.emit()

func _process(_delta):
	pass
	#print(Globals.hover_entity)
