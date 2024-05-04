extends Node

@onready var player: CharacterBody2D = $Level/Party/Player
@onready var inventory_interface: Control = UiBattle.inventory_interface
@onready var button = $StartScreen/Control/Button
@onready var level = $Level

@onready var level_over = $StartScreen/LevelOver
@onready var game_over_label = $StartScreen/LevelOver/GameOverLabel
@onready var win_label = $StartScreen/LevelOver/WinLabel
@onready var restart = $StartScreen/LevelOver/Restart


func _ready():
	button.pressed.connect(on_start_battle)
	restart.pressed.connect(on_restart)
	Globals.level_over.connect(on_level_over)

	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player.inventory_data)
	
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)
		
func toggle_inventory_interface(_external_inventory_owner = null) -> void:
	inventory_interface.visible = not inventory_interface.visible
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#if external_inventory_owner and inventory_interface.visible:
		#inventory_interface.set_external_inventory(external_inventory_owner)
	#else: 
		#inventory_interface.clear_external_inventory()


func on_start_battle():
	button.hide()
	level.show()
	UiBattle.show()
	
func on_level_over(type: String):
	level.hide()
	UiBattle.hide()
	level.queue_free()
	
	level_over.show()
	if type == 'win':
		win_label.show()
	elif type == 'lose':
		game_over_label.show()
	restart.show()
	
var level_scene = preload('res://levels/level.tscn') as PackedScene
func on_restart():
	Globals.new_level.emit()
	level_over.hide()
	var new_level = level_scene.instantiate()
	add_child(new_level)
	level = new_level
	UiBattle.show()
	
