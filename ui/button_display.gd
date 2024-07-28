extends VBoxContainer


## All available buttons
@onready var buttons := [
	$ButtonDisplay/TextureRect, 
	$ButtonDisplay2/TextureRect]


## Test for Joypad connection
func _ready():
	_joy_connection_changed(0, false)
	Input.joy_connection_changed.connect(_joy_connection_changed)


## Whenever a joypad connection changed test if we still use one and change
## displayed buttons accordingly
func _joy_connection_changed(device: int, connected: bool):
	var new_y := 32 if Input.get_connected_joypads().size() > 0 else 0
	
	for button in buttons:
		(button.texture as AtlasTexture).region.position.y = new_y
