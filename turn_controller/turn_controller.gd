class_name FiniteStateController
extends Node

@export var turn: Turn
@export var turn_queue: Array[Entity]
@export var turn_entity: Entity
@export var test: int
@onready var active_turn = $ActiveTurn

# Called when the node enters the scene tree for the first time.
func _ready():
	turn = active_turn
	turn.state_finished.connect(on_state_change)
	
func start_turn(turn_entity: Entity):
	turn.turn_entity = turn_entity
	turn._enter_state()

var i: int
func on_state_change():
	turn._exit_state()
	i +=1
	if i > 1:
		i = 0
	start_turn(turn_queue[i])
	

