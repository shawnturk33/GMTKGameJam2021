extends KinematicBody2D

# Declare member variables here. Examples:
#physics
var velocity = Vector2(0,0)
var gravity = Vector2(0, 200) #(0, 200)
var friction = .8
#throwing
var maxPower = 50.0
var minPower = 10.0
var maxChargeTime = 2000 #milliseconds
var startTime = 0 #milliseconds
var endTime = 0 #milliseconds
var dir = Vector2()
var UIArrowDistance = 128


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	var oldvel = velocity
	move_and_slide(velocity + gravity)
	var collision = null
	for i in get_slide_count():
		if i == 0:
			collision = get_slide_collision(i)
	if collision == null:
		velocity += gravity*delta
	else:
		var dot = collision.normal.dot(velocity)
		if oldvel.length() > 10:
			velocity -= dot * collision.normal
		velocity = velocity*friction
		oldvel = oldvel - velocity
		if oldvel.length() > 1:
			print(oldvel)
		else:
			velocity = Vector2(0,0)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			startTime = OS.get_ticks_msec()
			dir = Vector2(event.position - self.position)
			dir = dir.normalized()
			#UI charge arrow show
			get_node("Charge Arrow").position = dir * UIArrowDistance
			get_node("Charge Arrow").rotation = dir.tangent().angle() + PI
			get_node("Charge Arrow").visible = true
			get_node("Charge Arrow").play()
			#flip player
			if event.position.x < self.position.x and !get_node("AnimatedSprite").flip_h:
				get_node("AnimatedSprite").flip_h = true
			elif event.position.x > self.position.x and get_node("AnimatedSprite").flip_h:
				get_node("AnimatedSprite").flip_h = false
		if event.button_index == BUTTON_LEFT and !event.pressed:
			endTime = OS.get_ticks_msec()
			var elapsedTime = endTime - startTime
			var chargeTime = elapsedTime - floor(elapsedTime / maxChargeTime) * maxChargeTime
			var interpolation = minPower + (maxPower - minPower) * (chargeTime / maxChargeTime) #interpolate power with charge time
			dir *= interpolation
			print("charge", chargeTime)
			print("interpolation", interpolation)
			print("dir", dir)
			#UI charge arrow remove
			get_node("Charge Arrow").position = Vector2(0, 0)
			get_node("Charge Arrow").rotation = 0
			get_node("Charge Arrow").visible = false
			get_node("Charge Arrow").stop()
			get_node("Charge Arrow").frame = 0
