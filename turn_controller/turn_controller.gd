class_name FiniteStateController
extends Node

@export var turn: Turn
@export var test: int
@onready var active_turn = $ActiveTurn
@onready var spawn = $EnemySpawner
var turn_queue = Globals.turn_queue

# Called when the node enters the scene tree for the first time.
func _ready():
	turn = active_turn
	turn.state_finished.connect(on_state_change)

func on_state_change():
	turn._exit_state()
	turn_queue.push_back(turn_queue.pop_front())
	check_board_state()
	print('start turn for: ', Globals.turn_queue[0])
	
	start_turn(turn_queue[0])
	UiBattle.turn_order_display.set_turn_data(Globals.turn_queue)

func start_turn(turn_entity: Entity):
	turn.turn_entity = turn_entity
	turn._enter_state()

func check_board_state():
	if Globals.turn_queue.size() <= 4:
		Globals.spawn.emit()
