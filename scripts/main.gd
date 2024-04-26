extends Node

@onready var player: CharacterBody2D = $Level/Player
@onready var inventory_interface: Control = $UI/InventoryInterface
@onready var action_bar = $UI/ActionBar
@onready var spell_manager = $Level/SpellManager

func _ready():
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player.inventory_data)
	action_bar.set_player_ability_data(player.action_bar_data)
	player.action_bar_data.ability_used.connect(spell_manager.on_ability_used)
	
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)
		
func toggle_inventory_interface(external_inventory_owner = null) -> void:
	inventory_interface.visible = not inventory_interface.visible
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if external_inventory_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else: 
		inventory_interface.clear_external_inventory()

