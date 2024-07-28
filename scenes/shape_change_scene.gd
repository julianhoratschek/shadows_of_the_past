extends Node

@onready var door := $TileMap/Door

## Just do one transmutation to open the door
func _on_player_transmuted(property_name, old_value, new_value):
	if (property_name == TransmutableProperties.PropertyName.COLOR
	and new_value == TransmutableProperties.TransColor.GREEN):
		door.open()
	else:
		door.close()
