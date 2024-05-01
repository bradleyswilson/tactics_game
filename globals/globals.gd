extends Node

signal stat_change
signal get_enemy_moves(Vector2)
signal return_enemy_moves(Array)
signal start_turn()
signal end_turn()
signal game_over()

var turn_entity: Entity
var turn_queue: Array[Entity]
var entities_pos: Array[Vector2]

func _ready():
	start_turn.connect(on_start_turn)
	#end_turn.connect(on_end_turn)
	
func on_start_turn():
	entities_pos = []
	for entity in turn_queue:
		entities_pos.append(entity.global_position)

func on_end_turn():
	pass
	#entities_pos = []


	
var hover_entity: Entity
#UiBattle.member_hp.value = turn_entity.health


var offset_x = Vector2(-32,-16)
var offset_y = Vector2(32, -16)
