extends Node


@onready var turn_manager = $TurnManager
@onready var active_turn = $TurnManager/ActiveTurn
@onready var ability_manager = $AbilityManager


# Called when the node enters the scene tree for the first time.
func _ready():
	active_turn.ability_used.connect(ability_manager.ability_eval)
	active_turn.get_available_actions.connect(ability_manager.ai_available_actions)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
