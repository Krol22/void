extends Node2D

onready var animation_player = $AnimationPlayer

func _ready():
	pass

func open():
	animation_player.play("Open")
