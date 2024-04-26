extends Entity

@onready var interact_ray = $InteractRay
@onready var animated_sprite = $AnimatedSprite

signal move(AbilityData)
signal toggle_inventory()
#signal ability_confirm(ability_name: String)
	
func _ready():
	health = 100
	move_data.ability_range = 5
	
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
		move.emit(move_data)
		

func interact() -> void:
	if interact_ray.is_colliding():
		interact_ray.get_collider().player_interact()
	
