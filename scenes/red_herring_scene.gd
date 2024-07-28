extends Node

@onready var door := $TileMap/Door

var mouth_fed := 0

## Kill Player and Objects on contact with line, if they are not red
func _on_red_area_body_entered(body: Node2D):
	for child in body.get_children():
		if child is TransmutableProperties:
			if child.transmute_color != TransmutableProperties.TransColor.RED:
				body.desintegrate()


## Feed all mouths to open door
func _on_mouth_fed():
	mouth_fed += 1
	
	if mouth_fed == 2:
		door.open()
