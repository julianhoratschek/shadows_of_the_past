extends Node


var red_letters := 0

@onready var door := $TileMap/Door


func _on_letter_transmuted(property_name, old_value, new_value):
	if old_value == new_value:
		return

	if new_value == TransmutableProperties.TransColor.RED:
		red_letters += 1
		
	elif old_value == TransmutableProperties.TransColor.RED:
		red_letters -= 1
	
	if red_letters == 3:
		door.open()
	elif door.is_open:
		door.close()
