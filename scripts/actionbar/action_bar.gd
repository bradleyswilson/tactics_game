extends PanelContainer

const Slot = preload("res://scenes/slot.tscn")

@onready var item_grid: GridContainer = $MarginContainer/ItemGrid

func set_ability_data(abilities_data: AbilitiesData) -> void:
	#abilities.data.inventory_updated.connect(populate_item_grid)
	populate_action_bar(abilities_data)
	
#func clear_inventory_data(inventory_data: InventoryData) -> void:
#	inventory_data.inventory_updated.disconnect(populate_item_grid)

func populate_action_bar(abilities_data: AbilitiesData) -> void:
	for child in item_grid.get_children():
		child.queue_free()
		
	for ability_data in abilities_data.ability_data:
		var slot = Slot.instantiate()
		item_grid.add_child(slot)

		slot.slot_pressed.connect(abilities_data.on_slot_pressed)
		if ability_data:
			slot.set_ability_data(ability_data)

