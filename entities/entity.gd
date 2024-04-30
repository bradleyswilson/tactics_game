extends CharacterBody2D
class_name Entity

@export var speed = 200
@export var move_data: AbilityData
@export var inventory_data: InventoryData
@export var action_bar_data: InventoryData
@export var health = 100

func toggle_outline(enabled: bool):
	$Sprite2D.material.set_shader_parameter("enable_outline", enabled) 
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
