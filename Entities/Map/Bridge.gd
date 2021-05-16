extends Area2D

onready var top_ray_cast = $TopRaycast
onready var bottom_ray_cast = $BottomRaycast

var pressure_plate = null
var is_done = false
var move = false
var speed = 20 
var direction = Vector2.UP

# HOOKS
func _ready():
	set_meta("type", "bridge")
	pass

func _process(delta):
	if (move && !is_done):
		position.y = position.y + (direction.y * speed) * delta
		if (direction.y < 0):
			var collider = top_ray_cast.get_collider()
			if (collider):
				move = false
				is_done = true
		elif (direction.y > 0):
			var collider = bottom_ray_cast.get_collider()
			print(collider)
			if (collider):
				move = false
				is_done = true
		

# SIGNALS
func _on_pressure_plate_pressed():
	is_done = false
	move = true
	direction = Vector2.UP

func _on_pressure_plate_unpressed():
	is_done = false
	move = true
	direction = Vector2.DOWN

# FUNCTIONS
func set_pressure_plate(new_pressure_plate):
	var pressure_plate = new_pressure_plate 		
	pressure_plate.connect("pressure_plate_pressed", self, "_on_pressure_plate_pressed")
	pressure_plate.connect("pressure_plate_unpressed", self, "_on_pressure_plate_unpressed")
