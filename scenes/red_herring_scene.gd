extends BaseRoom


var mouth_fed := 0

func _ready():
	load_properties($Player)
	center_camera($Camera2D, $TileMap)



func _on_red_area_body_entered(body: Node2D):
	for child in body.get_children():
		if child is TransmutableProperties:
			if child.transmute_color != TransmutableProperties.TransColor.RED:
				body.desintegrate()


func _on_mouth_fed():
	mouth_fed += 1
	
	if mouth_fed == 2:
		$Door.open()
