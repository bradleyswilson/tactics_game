extends Node2D

@onready var tilemap = $Tilemap
@onready var player = $Player
@onready var ability_manager = $AbilityManager

# Called when the node enters the scene tree for the first time.
func _ready():
	ability_manager.highlight_interface.show_range(5, Vector2(150,150), false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
