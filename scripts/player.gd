extends CharacterBody2D
class_name Entity

@export var speed = 200
@export var movement_range = 4
@export var inventory_data: InventoryData
@export var action_bar_data: InventoryData
@onready var interact_ray = $InteractRay
@onready var animated_sprite = $AnimatedSprite

signal ability(movement_range: int)
signal toggle_inventory()
signal confirm()
	
func get_input():
	velocity = Vector2.ZERO
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	if (input_direction.x != 0 and (input_direction.y !=0)):
		velocity = input_direction * Vector2(2,1) * speed

func _physics_process(delta):
	get_input()
	#move_and_slide()
	Globals.player_pos = global_position

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		toggle_inventory.emit()
		
	if Input.is_action_just_pressed("interact"):
		interact()
		
	if Input.is_action_just_pressed("move_click"):
		ability.emit(movement_range)
	
	if Input.is_action_just_pressed("confirm_click"):
		confirm.emit()

func interact() -> void:
	if interact_ray.is_colliding():
		interact_ray.get_collider().player_interact()
	
