extends KinematicBody2D


signal pullPlayer(vel, pos)
signal bumpPlayer(vel)

# Declare member variables here.
onready var thud = $"thud"
var velocity = Vector2(0, 0)
var gravity = Vector2(0, 400)
var friction = .8
var enabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Replace with function body.
	$BallCollider.disabled = true
	$Sprite.visible = false
	$ChainPivot/chain_chain.visible = false


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
		if velocity.length() > 1:
			emit_signal("pullPlayer", velocity, global_position)

func throwBall(vel, pos):
	setEnabled(true)
	velocity = vel
	global_position = pos
	move_and_collide(Vector2(0, -80))

func tether(norm):
	velocity -= velocity.dot(norm)*norm

func chain(pos):
	var dir = pos - global_position
	$ChainPivot.rotation = dir.angle()

func setEnabled(new):
	if(new != enabled):
		enabled = new
		$BallCollider.disabled = !new
		$Sprite.visible = new
		$ChainPivot/chain_chain.visible = new
		if!enabled:
			velocity = Vector2(0,0)
