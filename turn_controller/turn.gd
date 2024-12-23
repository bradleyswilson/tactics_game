class_name Turn
extends State

@export var action_entity: Entity
@export var character_action = CharacterAction
var grabbed_ability: SlotData
var ability_data: ItemData

signal get_available_actions(Entity)

func _ready():
	character_action = CharacterAction.new()
	Globals.player_clicked_end_turn.connect(_on_player_endturn)
	pass
	#set_process(false)
	
func _enter_state() -> void:
	Globals.start_turn.emit()
	pass
	
func _exit_state():
	Globals.end_turn.emit()

func _input(event):
	if event.is_action_pressed('left_click') and Globals.hover_entity is PlayableEntity:
		character_action.set_action_entity(Globals.hover_entity)
		character_action._enter_state()
		print('working')

func _on_player_endturn():
	state_finished.emit()

