extends KinematicBody2D

# Declare member variables here. Examples:
#children
onready var arrow = $"Charge Arrow"
onready var sprite = $AnimatedSprite
#physics
var velocity = Vector2(0,0)
var gravity = Vector2(0, 200) #(0, 200)
var friction = .8
#throwing
var maxPower = 1000.0
var minPower = 100.0
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
	move_and_slide(velocity + gravity, Vector2(0, -1))
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
		if event.button_index == BUTTON_LEFT and event.pressed and is_on_floor():
			startTime = OS.get_ticks_msec()
			dir = Vector2(event.position - self.position)
			dir = dir.normalized()
			#UI charge arrow show
			arrow.position = dir * UIArrowDistance
			arrow.rotation = dir.tangent().angle() + PI
			arrow.visible = true
			arrow.play()
			#flip player
			if event.position.x < self.position.x and !sprite.flip_h:
				sprite.flip_h = true
			elif event.position.x > self.position.x and sprite.flip_h:
				sprite.flip_h = false
			#get into throw stance
			sprite.play("throw start")
		if event.button_index == BUTTON_LEFT and !event.pressed and is_on_floor():
			endTime = OS.get_ticks_msec()
			var elapsedTime = endTime - startTime
			var chargeTime = elapsedTime - floor(elapsedTime / maxChargeTime) * maxChargeTime
			var interpolation = minPower + (maxPower - minPower) * (chargeTime / maxChargeTime) #interpolate power with charge time
			dir *= interpolation
			print("charge", chargeTime)
			print("interpolation", interpolation)
			print("dir", dir)
			velocity += dir
			#UI charge arrow remove
			arrow.position = Vector2(0, 0)
			arrow.rotation = 0
			arrow.visible = false
			arrow.stop()
			arrow.frame = 0
			#play throw anim
			sprite.play("throw")


func _on_AnimatedSprite_animation_finished():
	if sprite.animation == "throw":
		sprite.play("idle")
