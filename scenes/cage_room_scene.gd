extends Node


func _ready():
	$TileMap/Door.open()

## If possible, try to touch the shadow
func _on_area_2d_body_entered(body):
	if not body is Player:
		pass
	
	if body.transmutable_properties.transmute_color != TransmutableProperties.TransColor.BLUE:
		body.desintegrate()
