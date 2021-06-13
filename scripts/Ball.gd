extends KinematicBody2D


# Declare member variables here.
onready var thud = $"thud"
var velocity = Vector2(100, -500)
var gravity = Vector2(0, 200)
var friction = .8
var enabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Replace with function body.
	$BallCollider.disabled = true
	$Sprite.visible = false


func _physics_process(delta):
	print("pos", self.global_position)
	if enabled:
		var oldvel = velocity
		move_and_slide(velocity + gravity)
		var collision = null
		for i in get_slide_count():
			if i == 0:
				collision = get_slide_collision(i)
		if collision == null:
			velocity += gravity*delta
		else:
			thud.play()
			var dot = collision.normal.dot(velocity)
			if oldvel.length() > 10:
				velocity -= dot * collision.normal
			velocity = velocity*friction
			oldvel = oldvel - velocity
			if oldvel.length() > 1:
				emit_signal("bumpPlayer", oldvel)
			else:
				velocity = Vector2(0,0)

func throwBall(vel, pos):
	setEnabled(true)
	velocity = vel
	position = pos + vel.normalized()*100

func setEnabled(new):
	if(new != enabled):
		enabled = new
		$BallCollider.disabled = !new
		$Sprite.visible = new
		if!enabled:
			velocity = Vector2(0,0)
