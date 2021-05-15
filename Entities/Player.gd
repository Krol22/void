extends Area2D

onready var move_tween = $MoveTween
onready var animation_player = $AnimationPlayer
onready var active_indicator = $ActiveIndicator

signal player_moved
signal key_picked
signal player_on_exit
signal player_off_exit

var on_falling_block = false
var speed = 10

# TODO State manager
var alive = true
var active = false

# HOOKS
func _ready():
	position = position.snapped(Vector2.ONE * Globals.TILE_SIZE)

func _process(_delta):
	get_input()

# SIGNALS
#func _on_Player_body_entered(body: Node):
#	on_falling_block = true
#
#func _on_Player_body_exited(body: Node):
#	on_falling_block = false

func _on_Player_area_entered(area):
	var type = area.get_meta("name")

	if type == "key":
		emit_signal("key_picked", area)

	if type == "exit":
		emit_signal("player_on_exit")

func _on_Player_area_exited(area):
	var type = area.get_meta("name")

	if type == "exit":
		emit_signal("player_off_exit")

# FUNCTIONS
func get_input():
	if !active:
		return

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
	emit_signal("player_moved", self, next_position)
	
func activate():
	animation_player.play("Activate")
	active = true

func deactivate():
	animation_player.play_backwards("Activate")
	active = false


func kill(_reason):
	alive = false
	animation_player.play("Fall")

