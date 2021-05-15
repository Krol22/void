extends CanvasLayer

onready var menu_options = $CenterContainer/VBoxContainer
onready var arrow = $Arrow
onready var animation_player_label = $AnimationPlayer

var selected_option = 1
var number_of_options = 3

var option_actions = {
	0: "continue_select",
	1: "new_game_select",
	2: "exit_select",
}

func _ready():
	animation_player_label.play("Blink")
	render_arrow(selected_option)

func _process(_delta):
	if Input.is_action_just_pressed("ui_up"):
		change_option(-1)
	if Input.is_action_just_pressed("ui_down"):
		change_option(1)
	if Input.is_action_just_pressed("ui_select"):
		select_option()

func continue_select():
	print("continue")

func new_game_select():
	$"/root/SceneTransition".change_scene()
	yield($"/root/SceneTransition", "scene_hidden")
	assert(get_tree().change_scene("res://Scenes/PlayScene.tscn") == OK)

func exit_select():
	print("test")

func change_option(option_offset):
	var next_option_index = selected_option + option_offset;

	if (next_option_index < 0):
		next_option_index = number_of_options - 1
	elif (next_option_index >= number_of_options):
		next_option_index = 0;

	selected_option = next_option_index
	render_arrow(next_option_index)

func render_arrow(option_index):
	var y = menu_options.rect_position.y + menu_options.get_children()[option_index].rect_position.y
	arrow.rect_position.y = y

func select_option():
	call(option_actions[selected_option])
