extends Entity
class_name Enemy 

@export var shape_tiles: Array
@onready var tilemap = get_tree().get_nodes_in_group("tilemaps")[0]
@onready var pathfinder = get_tree().get_nodes_in_group("pathfinder")[0]
@onready var move_candidates: Array

func _ready():
	shape_tiles = [Vector2i(0,0), Vector2i(-1,0), Vector2i(0, -1), Vector2i(-1, -1)]
	StatusEffects.on_entity_death.connect(_on_entity_death)
	action_bar_data = load("res://actionbar/test_enemy_actionbar.tres")
	#
func _on_entity_death(entity: Entity):
	if entity == self:
		super._on_entity_death(entity)
	

