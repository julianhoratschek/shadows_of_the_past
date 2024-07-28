extends Node

class_name BaseRoom


func load_properties(player: Player):
	if g.player_properties:
		player.transmutable_properties.set_properties(g.player_properties)
