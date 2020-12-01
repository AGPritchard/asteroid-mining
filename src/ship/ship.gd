extends KinematicBody2D

signal update_fuel(fuel)

export(float) var thrust_strength := 200.0
export(float) var rotational_thrust_strength := 1.5
export(float) var fuel_delta := 0.75
export(float) var fuel_rotational_factor := 0.5
export(float) var fuel_replenishment_rate = 0.25

var velocity := Vector2.ZERO
var acceleration := Vector2.ZERO
var rotation_direction := 0.0

var fuel := 100.0

func _physics_process(delta: float) -> void:
	# reset move variables
	acceleration = Vector2.ZERO
	rotation_direction = 0.0
	
	if fuel > 0:
		# handle velocity
		if Input.is_action_pressed("thrust_forward"):
			acceleration = (Vector2.UP * thrust_strength).rotated(rotation)
			fuel -= fuel_delta
			$BackThruster.emitting = true
		else:
			$BackThruster.emitting = false
		
		if Input.is_action_pressed("thrust_backward"):
			acceleration = (Vector2.DOWN * thrust_strength).rotated(rotation)
			fuel -= fuel_delta
			$FrontThruster.emitting = true
		else:
			$FrontThruster.emitting = false

		# handle rotation
		if Input.is_action_pressed("thrust_left"):
			rotation_direction = -1.0
			fuel -= fuel_delta * fuel_rotational_factor
			$LeftThruster.emitting = true
		else:
			$LeftThruster.emitting = false
		
		if Input.is_action_pressed("thrust_right"):
			rotation_direction = 1.0
			fuel -= fuel_delta * fuel_rotational_factor
			$RightThruster.emitting = true
		else:
			$RightThruster.emitting = false
	else:
		$FrontThruster.emitting = false
		$BackThruster.emitting = false
		$LeftThruster.emitting = false
		$RightThruster.emitting = false
	
	# movement
	rotation += rotation_direction * rotational_thrust_strength * delta
	velocity += acceleration * delta
	velocity = move_and_slide(velocity)
	
	if fuel < 100.0:
		fuel += fuel_replenishment_rate
	
	emit_signal("update_fuel", fuel)
