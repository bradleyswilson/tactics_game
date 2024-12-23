class_name FiniteStateController
extends Node

@export var turn = Turn
@onready var spawn = $EnemySpawner
@onready var player_turn: bool
var turn_queue = Globals.turn_queue

func _ready():
	player_turn = true
	turn = turn.new()
	turn.state_finished.connect(on_state_change)

func on_state_change():
	turn._exit_state()

	start_turn(player_turn)
	player_turn = !player_turn
	#UiBattle.turn_order_display.set_turn_data(Globals.turn_queue)

func start_turn(player_turn: bool):
	turn.player_turn = player_turn
	turn._enter_state()


