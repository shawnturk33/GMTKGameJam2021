extends CanvasLayer

signal scene_changed()

# Declare member variables here. Examples:
onready var animationPlayer = $AnimationPlayer
onready var black = $Control/Black

func change_scene(path, delay = 0.5):
	yield(get_tree().create_timer(delay), "timeout")
	animationPlayer.play("Fade")
	yield(animationPlayer, "animation_finished")
	get_tree().change_scene(path)
	animationPlayer.play_backwards("Fade")
	emit_signal("scene_changed")
