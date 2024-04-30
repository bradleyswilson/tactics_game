extends TextureButton
 
@onready var cooldown = $Cooldown
@onready var key = $Key
@onready var time = $Time
@onready var timer = $Timer

signal ability_used(index: int)

func set_button_data(button_data: AbilityData) -> void:
	cooldown.max_value = button_data.cooldown
	texture_normal = button_data.texture
	timer.text = "%d" % button_data.cooldown

var change_key = "":
	set(value):
		change_key = value
		key.text = value
 
		shortcut = Shortcut.new()
		var input_key = InputEventKey.new()
		input_key.keycode = value.unicode_at(0)
 
		shortcut.events = [input_key]
 
func _ready():
	change_key = "1"
	cooldown.max_value = int(timer.text)
	set_process(false)
 
func _on_pressed():
	#timer.start()
	#disabled = true
	set_process(true)
	ability_used.emit(get_index())
 
func _on_timer_timeout():
	#disabled = false
	time.text = ""
	cooldown.value = 0
	set_process(false)
