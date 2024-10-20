extends Turn

const ENEMY = preload("res://entities/enemy.tscn")

signal spawn()

func _enter_state() -> void:
	spawn.emit()
	
func _exit_state() -> void:
	pass

