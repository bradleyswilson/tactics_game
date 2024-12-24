class_name FiniteStateController
extends Node

@onready var turn = $Turn
@onready var label = $Turn/Label
@onready var spawn = $EnemySpawner
@onready var player_turn: bool
@onready var label_text: String

func _ready():
	player_turn = true
	turn.state_finished.connect(on_state_change)

func on_state_change():
	turn._exit_state()
	player_turn = !player_turn
	start_turn(player_turn)

func start_turn(player_turn: bool):
	turn.player_turn = player_turn
	label_text = 'player turn' if player_turn else 'enemy turn'
	print('turn_starting: ' + label_text)
	turn._enter_state()

func _process(_delta):
	label.text = label_text
