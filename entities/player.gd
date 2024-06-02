extends Entity
class_name PlayableEntity

@onready var interact_ray = $InteractRay
@onready var animated_sprite = $AnimatedSprite
@onready var sprite = $Sprite2D
@onready var direction_indicator = $DirectionIndicator
@onready var turnable = false

var sprite_front = preload("res://assets/iso_diver_front.aseprite")
var sprite_back = preload("res://assets/iso_diver_back.aseprite")

signal move(AbilityData)
signal toggle_inventory()
signal endturn_direction
#signal ability_confirm(ability_name: String)

func _ready():
	ending_turn = false
	health = 100
	speed = 600
	ap = 10
	StatusEffects.on_entity_death.connect(_on_entity_death)
	cd_array.resize(len(action_bar_data.slot_datas))
	cd_array.fill(0)
	set_process(false)
	

func _process(_delta):
	face_direction(get_global_mouse_position())
	
func _on_entity_death(entity: Entity):
	if entity == self:
		super._on_entity_death(entity)
		
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		toggle_inventory.emit()
		
	if event is InputEventMouseButton and event.pressed and turnable and ending_turn:
		face_direction(event.position)
		set_process(false)
		turnable = false
		ending_turn = false
		endturn_direction.emit()
	
	if event is InputEventMouseButton and event.pressed and turnable and not ending_turn:
		face_direction(event.position)
		set_process(false)
		turnable = false	

func face_direction(mouse_position):
	var direction = mouse_position - sprite.global_position
	
	if direction.x > 0:
		direction_indicator.offset = Vector2(16,0)
		sprite.flip_h = true
		if direction.y > 0:
			sprite.texture = sprite_front
			direction_indicator.flip_h = false
			direction_indicator.flip_v = true
		else:
			sprite.texture = sprite_back
			direction_indicator.flip_h = false
			direction_indicator.flip_v = false
	else:		
		direction_indicator.offset = Vector2(-16,0)
		sprite.flip_h = false
		if direction.y > 0:
			sprite.texture = sprite_front
			direction_indicator.flip_h = true
			direction_indicator.flip_v = true
		else:
			sprite.texture = sprite_back
			direction_indicator.flip_h = true
			direction_indicator.flip_v = false

