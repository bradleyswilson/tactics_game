extends Area2D

signal highlight_entered(body)
signal highlight_exited(body)
#func _on_mouse_entered():
#	highlight_data.emit(get_global_mouse_position()) # Replace with function body.

func _on_body_entered(body):
	highlight_entered.emit(body) # Replace with function body.

func _on_body_exited(body):
	highlight_exited.emit(body) # Replace with function body.
