extends Control

@onready var action_bar = $ActionBar

#var grabbed_slot_data: SlotData
#@onready var grabbed_slot: PanelContainer = $GrabbedSlot


#func _physics_process(delta: float) -> void:
#	if grabbed_slot.visible:
#		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5,5)

	
func _ready():
	pass#inventory_data.inventory_interact.connect(on_inventory_interact)
		
func set_player_abilities_data(abilities_data: AbilitiesData) -> void:
	abilities_data.ability_use.connect(on_ability_use)
	action_bar.set_ability_data(abilities_data)

func on_ability_use(abilities_data: AbilitiesData, index: int) -> void:
	print('connected')

