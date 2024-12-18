extends Node

signal stat_change

signal get_enemy_moves(Vector2)
signal return_enemy_moves(Array)
signal start_turn()
signal player_clicked_end_turn()
signal end_turn()
signal new_level()
signal level_over(type: String)

signal spawn()

## Highlight interface - cursor
signal toggle_entity_details(Entity)
signal toggle_terrain_details(CellData)


var hover_entity: Entity
var hover_terrain: CellData
var turn_entity: Entity
var turn_queue: Array[Entity]
var entities_pos: Array[Vector2]
var spell_ind: int
var gridData: Dictionary = {}

func _ready():
	hover_entity = null
	start_turn.connect(on_start_turn)
	#end_turn.connect(on_end_turn)
	
func on_start_turn():
	entities_pos = []
	for entity in turn_queue:
		entities_pos.append(entity.global_position)

func on_end_turn():
	pass
	#entities_pos = []
