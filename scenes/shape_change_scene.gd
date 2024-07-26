extends BaseRoom


func _ready():
	load_properties($Player)
	center_camera($Camera2D, $TileMap)

func _on_player_transmuted(property_name, old_value, new_value):
	if (property_name == TransmutableProperties.PropertyName.COLOR
	and new_value == TransmutableProperties.TransColor.GREEN):
		$Door.open()
	else:
		$Door.close()
