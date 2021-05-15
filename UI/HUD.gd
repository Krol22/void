extends CanvasLayer

func toggle_reset_level_text(force):
	if force != null:
		$MarginContainer2.visible = force
		return

	$MarginContainer2.visible = !$MarginContainer2.visible
