extends Area2D

onready var animation_player: AnimationPlayer = $AnimationPlayer

# HOOKS
func _ready():
	set_meta("name", "key")
	animation_player.play("Float")
	pass

# FUNCTIONS
func pick():
	animation_player.play("Pick")
	pass
