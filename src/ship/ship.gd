extends KinematicBody2D

export(float) var thrust_strength := 200.0
export(float) var rotational_thrust_strength := 1.5

var velocity := Vector2.ZERO
var rotation_direction := 0.0

func _physics_process(delta: float) -> void:
	# reset move variables
	velocity = Vector2.ZERO
	rotation_direction = 0.0
	
	# handle velocity
	if Input.is_action_pressed("thrust_forward"):
		velocity = (Vector2.UP * thrust_strength).rotated(rotation)
	if Input.is_action_pressed("thrust_backward"):
		velocity = (Vector2.DOWN * thrust_strength).rotated(rotation)

	# handle rotation
	if Input.is_action_pressed("thrust_left"):
		rotation_direction -= 1.0
	if Input.is_action_pressed("thrust_right"):
		rotation_direction += 1.0
	
	# movement
	rotation += rotation_direction * rotational_thrust_strength * delta
	velocity = move_and_slide(velocity)
