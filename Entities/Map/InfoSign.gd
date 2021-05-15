extends Area2D

signal info_sign_entered
signal info_sign_exited

export var message = "INFO MESSAGE"

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("wait")

func _on_InfoSign_body_entered(body):
	if (body.get_meta("name") != "player"): 
		return

	$Exclamation.visible = false
	emit_signal("info_sign_entered", message)

func _on_InfoSign_body_exited(body):
	if (body.get_meta("name") != "player"): 
		return

	$Exclamation.visible = true
	emit_signal("info_sign_exited")
