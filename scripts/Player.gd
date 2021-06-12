extends Node2D


# Declare member variables here. Examples:
var maxPower = 50.0
var minPower = 10.0
var maxChargeTime = 2000 #milliseconds
var startTime = 0 #milliseconds
var endTime = 0 #milliseconds
var dir = Vector2()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			#left click
			startTime = OS.get_ticks_msec()
			dir = Vector2(event.position - self.position)
			dir = dir.normalized()
		if event.button_index == BUTTON_LEFT and !event.pressed:
			endTime = OS.get_ticks_msec()
			var elapsedTime = endTime - startTime
			var chargeTime = elapsedTime - floor(elapsedTime / maxChargeTime) * maxChargeTime
			var interpolation = minPower + (maxPower - minPower) * (chargeTime / maxChargeTime) #interpolate power with charge time
			dir *= interpolation
			print("charge", chargeTime)
			print("interpolation", interpolation)
			print("dir", dir)
