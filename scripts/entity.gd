extends CharacterBody2D
class_name Entity

@export var speed = 200
@export var move_data: AbilityData
@export var inventory_data: InventoryData
@export var action_bar_data: InventoryData
@export var health = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass