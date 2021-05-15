extends CanvasLayer

onready var info_text = $MarginContainer/VBoxContainer/MarginContainer/InfoText
onready var info_text_container = $MarginContainer/VBoxContainer/MarginContainer
onready var animation_player = $MarginContainer/VBoxContainer/AnimationPlayer

func _ready():
	info_text_container.anchor_top = 0.1	
	info_text_container.anchor_bottom = 0.1	

func _show_info_text(message):
	info_text.text = message
	animation_player.play("show_info")

func _hide_info_text():
	animation_player.play_backwards("show_info")
