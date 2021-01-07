extends Node2D

var samples := PoolVector2Array([])

var asteroid_scene := preload("res://src/asteroid/asteroid.tscn")


# ----------------------------
# Built-in Function(s)
# ----------------------------
func _ready() -> void:
	randomize()
	VisualServer.set_default_clear_color(Color8(4, 0, 20, 255))
	
	# place asteroids
	samples = Sampling.poisson_disk_sampling(800.0, Vector2(2000, 2000), 30)
	for s in samples:
		var asteroid = asteroid_scene.instance()
		asteroid.global_position = s
		asteroid.add_to_group("asteroids")
		add_child(asteroid)
	
	# connect signals
	$Ship.connect("update_fuel", self, "_on_ship_update_fuel")

func _process(_delta: float) -> void:
	$FuelBar.set_global_position($Ship.global_position - Vector2(24, 50))

# ----------------------------
# Signal Funcions
# ----------------------------
func _on_ship_update_fuel(fuel: float) -> void:
	$FuelBar.value = fuel
