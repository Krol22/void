extends Area2D

signal player_entered

func _on_Exit_body_entered(body):
	if body.get_meta("name") == "player":
		emit_signal("player_entered")
