extends Node2D

# TODO: add asteroids
# TODO: add mining of asteroids
# TODO: add cargo functionality
# TODO: add drop off zone
# TODO: add conversion of dropped off cargo to credit

func _ready() -> void:
	VisualServer.set_default_clear_color(Color8(4, 0, 20, 255))
	
	# connect signals
	$Ship.connect("update_fuel", self, "_on_ship_update_fuel")

func _process(_delta: float) -> void:
	$FuelBar.set_global_position($Ship.global_position - Vector2(24, 50))

func _on_ship_update_fuel(fuel: float) -> void:
	$FuelBar.value = fuel
