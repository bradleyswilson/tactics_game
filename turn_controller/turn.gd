class_name Turn
extends State

@export var action_entity: Entity
@export var character_action = CharacterAction
var player_turn: bool
var grabbed_ability: SlotData
var ability_data: ItemData

signal get_available_actions(Entity)

func _ready():
	character_action = CharacterAction.new()
	character_action.state_finished.connect(check_board_state)
	#Globals.player_clicked_end_turn.connect(_on_player_endturn)
	pass
	#set_process(false)
	
func _enter_state() -> void:
	Globals.start_turn.emit()
	pass
	
#func _exit_state():
#	Globals.end_turn.emit()

func _input(event):
	if event.is_action_pressed('left_click') and Globals.hover_entity is PlayableEntity:
		if Globals.hover_entity.can_act == true:
			character_action.set_action_entity(Globals.hover_entity)
			character_action._enter_state()
		else:
			print("this character used it's turn!")
		
	if event.is_action_pressed("interact"):
		character_action._exit_state() 
	
#func _on_player_endturn():
#	state_finished.emit()

func check_board_state():
	
	pass
	#if Globals.turn_queue.size() <= 4:
	#	Globals.spawn.emit()
