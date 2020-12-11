extends Node2D

var asteroid_scene := preload("res://src/asteroid/asteroid.tscn")

var samples := PoolVector2Array([])

# TEMP: load background asteroid textures
var background_asteroid_texture_1 := preload("res://assets/asteroids/asteroid_test.png")
var background_asteroid_texture_2 := preload("res://assets/asteroids/asteroid_test_2.png")
var background_asteroid_texture_3 := preload("res://assets/asteroids/asteroid_test_3.png")
var background_asteroid_texture_4 := preload("res://assets/asteroids/asteroid_test_4.png")

# TEMP: load background planet textures
var background_planet_texture_1 := preload("res://assets/planets/planet_test.png")
var background_planet_texture_2 := preload("res://assets/planets/planet_test_2.png")
var background_planet_texture_3 := preload("res://assets/planets/planet_test_3.png")
var background_planet_texture_4 := preload("res://assets/planets/planet_test_4.png")

# ----------------------------
# Built-in Function(s)
# ----------------------------
func _ready() -> void:
	randomize()
	VisualServer.set_default_clear_color(Color8(4, 0, 20, 255))
	
	# TEMP: set nebulae colours
	$ParallaxBackground/Nebulae/Dust.material.set_shader_param("color_1", Vector3(randf(), randf(), randf()))
	$ParallaxBackground/Nebulae/Dust.material.set_shader_param("color_2", Vector3(randf(), randf(), randf()))
	$ParallaxBackground/Nebulae/Dust.material.set_shader_param("color_3", Vector3(randf(), randf(), randf()))
	$ParallaxBackground/Nebulae/Dust.material.set_shader_param("color_4", Vector3(randf(), randf(), randf()))
	
	# TEMP: spawn background asteroids
	var background_asteroid_samples := Sampling.poisson_disk_sampling(400.0, Vector2(2000, 2000), 30)
	for s in background_asteroid_samples:
		var background_asteroid := Sprite.new()
		
		var choice := randi() % 4
		match choice:
			1:
				background_asteroid.texture = background_asteroid_texture_1
			2:
				background_asteroid.texture = background_asteroid_texture_2
			3:
				background_asteroid.texture = background_asteroid_texture_3
			4:
				background_asteroid.texture = background_asteroid_texture_4
		
		background_asteroid.global_position = s
		background_asteroid.rotation = rand_range(0, 2*PI)
		background_asteroid.scale = Vector2.ONE * rand_range(0.8, 1.0)
		
		$ParallaxBackground/Asteroids.add_child(background_asteroid)
	
	# TEMP: spawn background planets
	var background_planet_samples := Sampling.poisson_disk_sampling(800.0, Vector2(2000, 2000), 30)
	for s in background_planet_samples:
		var background_planet := Sprite.new()
		
		var choice := randi() % 4
		match choice:
			1:
				background_planet.texture = background_planet_texture_1
			2:
				background_planet.texture = background_planet_texture_2
			3:
				background_planet.texture = background_planet_texture_3
			4:
				background_planet.texture = background_planet_texture_4
		
		background_planet.global_position = s
		background_planet.rotation = rand_range(0, 2*PI)
		background_planet.scale = Vector2.ONE * rand_range(0.4, 0.8)
		
		$ParallaxBackground/Planets.add_child(background_planet)
	
	# place asteroids
	samples = Sampling.poisson_disk_sampling(800.0, Vector2(2000, 2000), 30)
	for s in samples:
		var asteroid = asteroid_scene.instance()
		asteroid.global_position = s
		asteroid.add_to_group("asteroids")
		add_child(asteroid)
	
	# connect signals
	$Ship.connect("update_fuel", self, "_on_ship_update_fuel")

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		# TEMP: update nebulae colours
		if event.scancode == KEY_SPACE and event.pressed:
			$ParallaxBackground/Nebulae/Dust.material.set_shader_param("color_1", Vector3(randf(), randf(), randf()))
			$ParallaxBackground/Nebulae/Dust.material.set_shader_param("color_2", Vector3(randf(), randf(), randf()))
			$ParallaxBackground/Nebulae/Dust.material.set_shader_param("color_3", Vector3(randf(), randf(), randf()))
			$ParallaxBackground/Nebulae/Dust.material.set_shader_param("color_4", Vector3(randf(), randf(), randf()))

func _process(_delta: float) -> void:
	$FuelBar.set_global_position($Ship.global_position - Vector2(24, 50))

# ----------------------------
# Signal Funcions
# ----------------------------
func _on_ship_update_fuel(fuel: float) -> void:
	$FuelBar.value = fuel
