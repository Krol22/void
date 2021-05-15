extends Area2D

onready var move_tween = $MoveTween
onready var animation_player = $AnimationPlayer

signal player_moved

var on_falling_block = false
var speed = 10

# TODO State manager
var alive = true

# HOOKS
func _ready():
	set_meta("name", "player")
	position = position.snapped(Vector2.ONE * Globals.TILE_SIZE)

func _process(_delta):
	get_input()

# SIGNALS
func _on_Player_body_entered(_body):
	on_falling_block = true

func _on_Player_body_exited(_body):
	on_falling_block = false

# FUNCTIONS
func get_input():
	if Input.is_action_just_pressed("ui_left"):
		move(Vector2.LEFT)
	if Input.is_action_just_pressed("ui_right"):
		move(Vector2.RIGHT)
	if Input.is_action_just_pressed("ui_up"):
		move(Vector2.UP)
	if Input.is_action_just_pressed("ui_down"):
		move(Vector2.DOWN)

func move(dir):
	if (!alive): return

	var next_position = position + dir * Globals.TILE_SIZE

	move_tween.interpolate_property(
		self,
		"position",
		position,
		next_position,
		1.0/speed,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT_IN
	)
	move_tween.start()
	emit_signal("player_moved", on_falling_block, next_position)

func kill(_reason):
	alive = false
	animation_player.play("Fall")
