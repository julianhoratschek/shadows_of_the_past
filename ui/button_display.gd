extends VBoxContainer

@onready var buttons := [
	$ButtonDisplay/TextureRect, 
	$ButtonDisplay2/TextureRect]

func _ready():
	_joy_connection_changed(0, false)
	Input.joy_connection_changed.connect(_joy_connection_changed)


func _joy_connection_changed(device: int, connected: bool):
	var new_y := 32 if Input.get_connected_joypads().size() > 0 else 0
	
	for button in buttons:
		(button.texture as AtlasTexture).region.position.y = new_y
			
		
