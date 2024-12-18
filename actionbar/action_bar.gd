extends PanelContainer

const Ability = preload("res://actionbar/spell_button.tscn")

@onready var h_box_container = $HBoxContainer

func set_player_ability_data(inventory_data: InventoryData, cooldown_array: Array) -> void:
	populate_action_bar(inventory_data, cooldown_array)
	
func populate_action_bar(inventory_data: InventoryData, cooldown_array: Array) -> void:
	for child in h_box_container.get_children():
		child.queue_free()
	
	var i = 1
	for slot in inventory_data.slot_datas:
		if slot and slot.item_data and slot.item_data is AbilityData:
			var ability = Ability.instantiate()
			h_box_container.add_child(ability)
			ability.set_button_data(slot.item_data)
			ability.update_cooldown(cooldown_array, i-1)
			ability.change_key = str(i)
			ability.ability_used.connect(inventory_data.on_ability_used)
		i+=1

func update_action_bar(inventory_data: InventoryData, cooldown_array: Array) -> void:
	var i = 0
	for slot in inventory_data.slot_datas:
		if slot and slot.item_data and slot.item_data is AbilityData:
			h_box_container.get_child(i).update_cooldown(cooldown_array, i)
		i+=1
	
