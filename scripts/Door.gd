extends Area2D

# Declare member variables here. Examples:
export var nextSceneString = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Door_body_entered(body):
	if body is KinematicBody2D:
		SceneChanger.change_scene(nextSceneString)
