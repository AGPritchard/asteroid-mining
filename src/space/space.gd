extends Node2D

# TODO: add cargo functionality
# TODO: add drop off zone
# TODO: add conversion of dropped off cargo to credit

var asteroid_scene := preload("res://src/asteroid/asteroid.tscn")

func _ready() -> void:
	VisualServer.set_default_clear_color(Color8(4, 0, 20, 255))
	
	# connect signals
	$Ship.connect("update_fuel", self, "_on_ship_update_fuel")
	$Asteroid.connect("break_up", self, "_on_asteroid_break_up")

func _process(_delta: float) -> void:
	$FuelBar.set_global_position($Ship.global_position - Vector2(24, 50))

func _on_ship_update_fuel(fuel: float) -> void:
	$FuelBar.value = fuel

func _on_asteroid_break_up(pos: Vector2) -> void:
	var asteroid = asteroid_scene.instance()
	asteroid.global_position = pos + (Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0)) * 100.0)
	asteroid.size = 1
	add_child(asteroid)
