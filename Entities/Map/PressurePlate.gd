extends Area2D

onready var animated_sprite = $AnimatedSprite

signal pressure_plate_pressed
signal pressure_plate_unpressed

var was_pressed

# HOOKS
func _ready():
	set_meta("type", "pressure_plate")
	animated_sprite.animation = "normal"

# FUNCTIONS
func press():
	was_pressed = true
	emit_signal("pressure_plate_pressed")
	animated_sprite.animation = "pressed"

func unpress():
	if (!was_pressed):
		return

	was_pressed = false
	emit_signal("pressure_plate_unpressed")
	animated_sprite.animation = "normal"
