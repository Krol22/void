extends Node2D

const player_scene = preload("res://Entities/Player.tscn")
var level_scene = preload("res://Levels/Level0.tscn")
var level1_scene = preload("res://Levels/Level1.tscn")

var current_level
var prev_level
var falling_blocks: TileMap
var static_blocks: TileMap
var player

var levels = [
	level_scene,
	level1_scene,
]

var current_level_index = 0

# HOOKS
func _ready():
	current_level = levels[current_level_index].instance()
	player = player_scene.instance()

	add_child(player)
	init_level(current_level)
	add_child(current_level)

func _process(_delta):
	if Input.is_action_just_pressed("ui_action"):
		if !player.alive:
			load_level(current_level_index)

# SIGNALS
func _on_player_move(is_on_falling_block, next_position):
	if (!is_on_ground(next_position)):
		player.kill("drop")
		return

	if (is_on_falling_block):
		var tile_pos = falling_blocks.world_to_map(player.position)
		falling_blocks.set_cellv(tile_pos, -1)

func _on_player_entered_exit():
	call_deferred("load_next_level")

# FUNCTIONS
func init_level(loaded_level):
	player.position.x = loaded_level.get_node("Entrance").position.x
	player.position.y = loaded_level.get_node("Entrance").position.y

	loaded_level.get_node("Exit").connect("player_entered", self, "_on_player_entered_exit")

	falling_blocks = loaded_level.get_node("FallingBlocks")
	static_blocks = loaded_level.get_node("StaticBlocks")

	player.connect("player_moved", self, "_on_player_move")

	if (loaded_level.get_node("InfoSigns")):
		handle_info_signs(loaded_level)


func handle_info_signs(loaded_level):
	var info_signs_group = loaded_level.get_node("InfoSigns")

	for node in info_signs_group.get_children():
		node.connect("info_sign_entered", self, "_on_player_entered_info_sign")
		node.connect("info_sign_exited", self, "_on_player_exited_info_sign")

func is_on_ground(next_position: Vector2):
	var falling_tile_pos = falling_blocks.world_to_map(next_position)
	var static_tile_pos = static_blocks.world_to_map(next_position)

	return (
		static_blocks.get_cellv(static_tile_pos) != -1 ||
		falling_blocks.get_cellv(falling_tile_pos) != -1
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
	remove_child(player)

	prev_level = current_level

	current_level = levels[next_level_index].instance()
	player = player_scene.instance()

	add_child(player)
	init_level(current_level)
	add_child(current_level)
	
