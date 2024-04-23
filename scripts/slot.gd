extends PanelContainer

@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var quantity_label: Label = $QuantityLabel

signal slot_clicked(index:int, button:int)
signal slot_pressed(index:int)

func set_slot_data(slot_data: SlotData) -> void:
	var item_data = slot_data.item_data
	texture_rect.texture = item_data.texture
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
	
	if slot_data.quantity > 1:
		quantity_label.text = "x%s" % slot_data.quantity
		quantity_label.show()
	else:
		quantity_label.hide()
		
func set_ability_data(ability_data: AbilityData) -> void: 
	texture_rect.texture = ability_data.texture
		
func _on_gui_input(event) -> void:
	if event is InputEventMouseButton \
			and (event.button_index == MOUSE_BUTTON_LEFT \
			or event.button_index == MOUSE_BUTTON_RIGHT) \
			and event.is_pressed():
		slot_clicked.emit(get_index(), event.button_index)
		
func _unhandled_input(event) -> void:
	if event is InputEventKey and event.is_pressed():
		var index = event.keycode - 48
		slot_pressed.emit(index)

		
