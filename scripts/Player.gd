extends KinematicBody2D

signal throwing_force(dir, pos)
signal tetherBall(norm)
signal rotateChain(pos)
signal ballEnable(enabled)

# Declare member variables here. Examples:
#children
onready var arrow = $"Charge Arrow"
onready var sprite = $AnimatedSprite
onready var grunt = $"Grunt"
#physics
var velocity = Vector2(0,0)
var gravity = Vector2(0, 400) #(0, 200)
var friction = .8
#throwing
var maxPower = 1500.0
var minPower = 600.0
var maxChargeTime = 2000 #milliseconds
var startTime = 0 #milliseconds
var endTime = 0 #milliseconds
var dir = Vector2()
var UIArrowDistance = 128
var leftClickFlag = false



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
			#print(oldvel)
			pass
		else:
			velocity = Vector2(0,0)
	if !is_on_floor():
		sprite.play("hang")
		sprite.set_rotation(velocity.angle() + PI/2)
		emit_signal("rotateChain", $AnimatedSprite/FlyNode.global_position)
	else:
		if sprite.animation == "hang":
			sprite.play("idle")
			sprite.set_rotation(0)
		emit_signal("rotateChain", $AnimatedSprite/FootNode.global_position)
		
	

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed and is_on_floor():
			emit_signal("ballEnable", false)
			startTime = OS.get_ticks_msec()
			dir = Vector2(get_global_mouse_position() - self.global_position)
			dir = dir.normalized()
			print("event", get_global_mouse_position())
			print("self.position", self.global_position)
			#UI charge arrow show
			arrow.position = dir * UIArrowDistance
			arrow.rotation = dir.tangent().angle() + PI
			arrow.visible = true
			arrow.play()
			#flip player
			if get_global_mouse_position().x < self.global_position.x and !sprite.flip_h:
				sprite.flip_h = true
			elif get_global_mouse_position().x > self.global_position.x and sprite.flip_h:
				sprite.flip_h = false
			#get into throw stance
			sprite.play("throw start")
			grunt.play()
			leftClickFlag = true
		if event.button_index == BUTTON_LEFT and !event.pressed and leftClickFlag:
			leftClickFlag = false
			endTime = OS.get_ticks_msec()
			var elapsedTime = endTime - startTime
			var chargeTime = elapsedTime - floor(elapsedTime / maxChargeTime) * maxChargeTime
			var interpolation = minPower + (maxPower - minPower) * (chargeTime / maxChargeTime) #interpolate power with charge time
			dir *= interpolation
			emit_signal("throwing_force", dir, self.global_position)
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


func _on_DeathBox_death():
	get_tree().reload_current_scene()

func pull(vel, pos):
	var dist = global_position - pos
	if dist.length() > 256:
		var move = (pos + dist.normalized() * 256) - global_position
		if move.length() > 1:
			move_and_slide(Vector2(0, move.y))
			var collision = null
			for i in get_slide_count():
				if i == 0:
					collision = get_slide_collision(i)
			move_and_slide(Vector2(move.x, 0))
			for i in get_slide_count():
				if i == 0:
					collision = get_slide_collision(i)
			if collision != null:
				emit_signal("tetherBall", collision.normal)
			else:
				velocity = (-dist.normalized()) * max(vel.length()*1.1, velocity.length())

func bump(vel):
	pass
