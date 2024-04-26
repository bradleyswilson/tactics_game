extends Area2D

signal highlight_data(body)

#func _on_mouse_entered():
#	highlight_data.emit(get_global_mouse_position()) # Replace with function body.

func _on_body_entered(body):
	highlight_data.emit(body) # Replace with function body.

func _on_body_exited(body):
	highlight_data.emit(body) # Replace with function body.
