extends BaseRoom


var red_letters := 0

func _ready():
	load_properties($Player)
	center_camera($Camera2D, $TileMap)


func _on_letter_transmuted(property_name, old_value, new_value):
	if old_value == new_value:
		return

	if new_value == TransmutableProperties.TransColor.RED:
		red_letters += 1
		
	elif old_value == TransmutableProperties.TransColor.RED:
		red_letters -= 1
	
	if red_letters == 3:
		$Door.open()
	elif $Door.is_open:
		$Door.close()
