class_name IsActiveTurn
extends Turn

@export var turn_entity: Entity

func _ready():
	pass
	#set_process(false)
	
func _enter_state() -> void:
	print('entered_state: ', turn_entity)

func _exit_state():
	print('exited_state: ', turn_entity)

func _input(event):
	if event.is_action_pressed("interact"):
		state_finished.emit()
