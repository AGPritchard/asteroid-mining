extends KinematicBody2D

signal update_fuel(fuel)

export(float) var thrust_strength := 200.0
export(float) var rotational_thrust_strength := 1.5
export(float) var fuel_delta := 0.75
export(float) var fuel_rotational_factor := 0.5
export(float) var fuel_replenishment_rate := 0.25
export(float) var thruster_reboot_time := 2

var velocity := Vector2.ZERO
var acceleration := Vector2.ZERO
var rotation_direction := 0.0

var can_thrust := true
var fuel := 100.0

func _ready() -> void:
	$ThrusterRebootTimer.wait_time = thruster_reboot_time

func _physics_process(delta: float) -> void:
	# reset move variables
	acceleration = Vector2.ZERO
	rotation_direction = 0.0
	
	if fuel > 0:
		if can_thrust:
			# foward and backward input
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

			# handle rotation input
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
		# start thruster reboot timer
		can_thrust = false
		$ThrusterRebootTimer.start()
		
		# turn off all thrusters (only visual)
		$FrontThruster.emitting = false
		$BackThruster.emitting = false
		$LeftThruster.emitting = false
		$RightThruster.emitting = false
	
	# movement
	rotation += rotation_direction * rotational_thrust_strength * delta
	velocity += acceleration * delta
	velocity = move_and_slide(velocity)
	
	# replenish fuel
	if fuel < 100.0:
		fuel += fuel_replenishment_rate
	
	emit_signal("update_fuel", fuel)

func _on_ThrusterRebootTimer_timeout() -> void:
	can_thrust = true
