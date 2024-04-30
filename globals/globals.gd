extends Node

signal stat_change
signal get_enemy_moves(Vector2)
signal return_enemy_moves(Array)

var turn_entity: Entity
var turn_queue: Array[Entity]
var turn_entity_pos: Vector2


var hover_entity: Entity
#UiBattle.member_hp.value = turn_entity.health


var offset_x = Vector2(-32,-16)
var offset_y = Vector2(32, -16)
