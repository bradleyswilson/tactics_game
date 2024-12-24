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
	Globals.player_clicked_end_turn.connect(_on_player_endturn)

func _enter_state() -> void:
	full_reset()
	if player_turn == false:
		start_enemy_actions()
	pass
	
func _exit_state():
	pass
	#Globals.end_turn.emit()

func start_enemy_actions():
	for enemy in Globals.enemies:
		print('Taking action for: ' + str(enemy))
		character_action.set_action_entity(enemy)
		character_action._enter_state()
		await get_tree().create_timer(1).timeout  # Wait for action to complete
		character_action._exit_state()
		print('Action completed for: ' + str(enemy))  # Debug log to track completion

func _input(event):
	if event.is_action_pressed('left_click') and Globals.hover_entity is PlayableEntity:
		if Globals.hover_entity.can_act == true and not Globals.hover_entity.has_acted:
			character_action.set_action_entity(Globals.hover_entity)
			character_action._enter_state()
			print('Taking action for: ' + str(Globals.hover_entity))
			
			for entity in Globals.party:
				if entity != Globals.hover_entity:
					entity.can_act = false
		
		else:
			print("this character used it's turn!")
		
	if event.is_action_pressed("interact"):
		character_action._exit_state() 
	
func _on_player_endturn():
	state_finished.emit()

func reset_action():
	for entity in Globals.party:
		entity.can_act = true

func full_reset():
	for entity in Globals.party:
		entity.can_act = true
		entity.has_acted = false
		
func check_all_acted() -> bool:
	return Globals.party.all(func(entity): return entity.has_acted)
	
func check_board_state():
	reset_action()
	if check_all_acted() == true:
		state_finished.emit()

	#if Globals.turn_queue.size() <= 4:
	#	Globals.spawn.emit()
