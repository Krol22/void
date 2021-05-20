extends Node2D

onready var Hud = $HUD

const player_scene = preload("res://Entities/Player.tscn")
var level_scene = preload("res://Levels/Level0.tscn")
var level1_scene = preload("res://Levels/Level1.tscn")

var current_level
var prev_level
var falling_blocks: TileMap
var static_blocks: TileMap
var exit_door: Node2D
var bridge: Area2D
var pressure_plate: Area2D

var character_1
var character_2
var keys
var keys_to_pick
var players_on_exit = 0

var levels = [
	level_scene,
	level1_scene,
]

var current_level_index = 0

# HOOKS
func _ready():
	current_level = levels[current_level_index].instance()

	character_1 = player_scene.instance()
	character_2 = player_scene.instance()

	add_child(character_1)
	add_child(character_2)

	init_level(current_level)
	add_child(current_level)

func _process(_delta):
	if Input.is_action_just_pressed("ui_action"):
		if !character_1.alive || !character_2.alive:
			load_level(current_level_index)
	if Input.is_action_just_pressed("ui_swap"): 
		if character_1.active:
			character_1.deactivate()
			character_2.activate()
		else:
			character_1.activate()
			character_2.deactivate()

# SIGNALS
func _on_player_move(character, next_position):
	if (!is_on_ground(character, next_position)):
		character.kill("drop")
		Hud.toggle_reset_level_text(true)
		return

	var falling_tile_pos = falling_blocks.world_to_map(next_position)
	var is_on_falling_block =	!!falling_blocks.get_cellv(falling_tile_pos) != -1

	# TODO this is shitty too
	var collider = character.get_node("RayCast2D").get_collider()
	if (collider && collider.get_meta("type") == "pressure_plate"):
		collider.press()
		character.set_pressure_plate(collider)
	elif (character.pressure_plate):
		character.pressure_plate.unpress()
		character.set_pressure_plate(null)

	if (is_on_falling_block):
		var tile_pos = falling_blocks.world_to_map(character.position)
		var tile_index = falling_blocks.get_cellv(tile_pos)

		if (tile_index == 1):
			falling_blocks.set_cellv(tile_pos, 13)
		else:
			falling_blocks.set_cellv(tile_pos, -1)

func _on_key_picked(key):
	keys_to_pick = keys_to_pick - 1
	key.pick()

	if (keys_to_pick == 0):
		exit_door.open()

func _on_player_entered_exit():
	call_deferred("load_next_level")

func _on_player_on_exit():
	players_on_exit = players_on_exit + 1
	if players_on_exit == 2:
		players_on_exit = 0
		load_level(0)

func _on_player_off_exit():
	players_on_exit = players_on_exit - 1


# FUNCTIONS
func init_level(loaded_level):
	character_1.position.x = loaded_level.get_node("Entrance").position.x
	character_1.position.y = loaded_level.get_node("Entrance").position.y
	character_1.activate()

	character_2.position.x = loaded_level.get_node("Entrance1").position.x
	character_2.position.y = loaded_level.get_node("Entrance1").position.y

	character_1.set_meta("name", "char_1")
	character_2.set_meta("name", "char_2")

	loaded_level.get_node("Exit").connect("player_entered", self, "_on_player_entered_exit")
	Hud.toggle_reset_level_text(false)
	falling_blocks = loaded_level.get_node("FallingBlocks")
	static_blocks = loaded_level.get_node("StaticBlocks")
	exit_door = loaded_level.get_node("ExitDoor")

	#TODO - this won't be on every level.
	pressure_plate = loaded_level.get_node("PressurePlate")
	bridge = loaded_level.get_node("Bridge")
	bridge.set_pressure_plate(pressure_plate)

	keys = loaded_level.get_node("Keys").get_children()
	keys_to_pick = keys.size()

	character_1.connect("player_moved", self, "_on_player_move")
	character_2.connect("player_moved", self, "_on_player_move")

	character_1.connect("key_picked", self, "_on_key_picked")
	character_2.connect("key_picked", self, "_on_key_picked")

	character_1.connect("player_on_exit", self, "_on_player_on_exit")
	character_2.connect("player_on_exit", self, "_on_player_on_exit")

	character_1.connect("player_off_exit", self, "_on_player_off_exit")
	character_2.connect("player_off_exit", self, "_on_player_off_exit")

func is_on_ground(character: Area2D, next_position: Vector2):
	var falling_tile_pos = falling_blocks.world_to_map(next_position)
	var static_tile_pos = static_blocks.world_to_map(next_position)

	var is_on_static_tile = static_blocks.get_cellv(static_tile_pos) != -1
	var is_on_falling_tile = falling_blocks.get_cellv(falling_tile_pos) != -1
	var is_on_bridge = false

	if bridge:
		var collider = character.get_node("RayCast2D").get_collider()
		if collider && collider.get_meta("type") == "bridge":
			is_on_bridge = true
			collider.set_active_player(character)
			character.set_bridge(collider)
		elif !collider && character.bridge:
			character.bridge.set_active_player(null)
			character.set_bridge(null)
			

	return (
		is_on_static_tile ||
		is_on_falling_tile ||
		is_on_bridge
	)

func load_next_level():
	current_level_index += 1

	if current_level_index > levels.size() - 1:
		current_level_index = 0
	
	load_level()


func load_level(level_index = -1):
	var next_level_index

	if level_index < 0:
		next_level_index = current_level_index 
	else:
		next_level_index = level_index

	$"/root/SceneTransition".change_scene()
	yield($"/root/SceneTransition", "scene_hidden")

	remove_child(current_level)
	remove_child(character_1)
	remove_child(character_2)

	prev_level = current_level

	current_level = levels[next_level_index].instance()
	character_1 = player_scene.instance()
	character_2 = player_scene.instance()

	add_child(character_1)
	add_child(character_2)
	init_level(current_level)
	add_child(current_level)
	
