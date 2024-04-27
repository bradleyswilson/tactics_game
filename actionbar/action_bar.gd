extends PanelContainer

const Ability = preload("res://actionbar/spell_button.tscn")

@onready var h_box_container = $HBoxContainer

func set_player_ability_data(inventory_data: InventoryData) -> void:
	populate_action_bar(inventory_data)
	
	# This is moved to the spell manager
func populate_action_bar(inventory_data: InventoryData) -> void:
	for child in h_box_container.get_children():
		child.queue_free()
	
	var i = 1
	for slot in inventory_data.slot_datas:
		if slot and slot.item_data and slot.item_data is AbilityData:
			var ability = Ability.instantiate()
			h_box_container.add_child(ability)
			ability.set_button_data(slot.item_data)
			ability.change_key = str(i)
			ability.ability_used.connect(inventory_data.on_ability_used)
		i+=1
		
	
	#match [grabbed_slot_data, button]:
		#[null, MOUSE_BUTTON_LEFT]:
			#grabbed_slot_data = inventory_data.grab_slot_data(index)
		#[_, MOUSE_BUTTON_LEFT]:
			#grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)
		#[null, MOUSE_BUTTON_RIGHT]:
			#pass
		#[_, MOUSE_BUTTON_RIGHT]:
			#grabbed_slot_data = inventory_data.drop_single_slot_data(grabbed_slot_data, index)
	#update_grabbed_slot()
