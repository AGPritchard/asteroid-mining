extends KinematicBody2D

const DEBUG := true

signal update_fuel(fuel)

export(float) var thrust_strength := 150.0
export(float) var rotational_thrust_strength := 1.5
export(float) var fuel_delta := 0.75
export(float) var fuel_replenishment_rate := 0.25
export(float) var thruster_reboot_time := 2

var velocity := Vector2.ZERO
var acceleration := Vector2.ZERO

var can_thrust := true
var fuel := 100.0


# --------------------
# Built-in Functions
# --------------------
func _ready() -> void:
	$ThrusterRebootTimer.wait_time = thruster_reboot_time

func _input(event: InputEvent) -> void:
	# interact with asteroid
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			if $DrillPointer.is_colliding():
				var collider = $DrillPointer.get_collider()
				if collider is Asteroid:
					collider.mine()
					# TODO: animate drill piece + play sounds

func _process(_delta: float) -> void:
	# disable thrusters
	if !DEBUG and can_thrust and fuel <= 0:
		# start thruster reboot timer
		can_thrust = false
		$ThrusterRebootTimer.start()
		
		# turn off thruster particle emitters
		$FrontThruster.emitting = false
		$BackThruster.emitting = false
		$LeftThruster.emitting = false
		$RightThruster.emitting = false
	
	# replenish fuel
	if !DEBUG and fuel < 100.0:
		fuel += fuel_replenishment_rate

	# emit signals
	emit_signal("update_fuel", fuel)

func _physics_process(delta: float) -> void:
	# reset move variable(s)
	acceleration = Vector2.ZERO
	
	if can_thrust:
		_thrust_input()
	_look()
	
	# apply velocity
	if DEBUG:
		velocity = acceleration
	else:
		velocity += acceleration * delta
	velocity = move_and_slide(velocity)
	

# --------------------
# Other Functions
# --------------------
func _thrust_input() -> void:
	if Input.is_action_pressed("thrust_forward"):
		acceleration = (Vector2.RIGHT * thrust_strength).rotated(rotation)
		fuel -= fuel_delta
		$BackThruster.emitting = true
	else:
		$BackThruster.emitting = false
	
	if Input.is_action_pressed("thrust_backward"):
		acceleration = (Vector2.LEFT * thrust_strength).rotated(rotation)
		fuel -= fuel_delta
		$FrontThruster.emitting = true
	else:
		$FrontThruster.emitting = false
	
	if Input.is_action_pressed("thrust_left"):
		acceleration = (Vector2.UP * thrust_strength).rotated(rotation)
		fuel -= fuel_delta
		$RightThruster.emitting = true
	else:
		$RightThruster.emitting = false
	
	if Input.is_action_pressed("thrust_right"):
		acceleration = (Vector2.DOWN * thrust_strength).rotated(rotation)
		fuel -= fuel_delta
		$LeftThruster.emitting = true
	else:
		$LeftThruster.emitting = false	

func _look() -> void:
	# get looking input values
	var vertical_look := Input.get_action_strength("look_backward") - Input.get_action_strength("look_forward")
	var horizontal_look := Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	var look_direction := Vector2(horizontal_look, vertical_look)
	
	# if right stick is used then look with that, otherwise look with the mouse
	if look_direction.length() > 0:
		rotation = look_direction.angle()
	else:
		look_at(get_global_mouse_position())


# --------------------
# Signals
# --------------------
func _on_ThrusterRebootTimer_timeout() -> void:
	can_thrust = true
