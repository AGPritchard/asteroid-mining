class_name Asteroid
extends StaticBody2D

signal break_up(pos)

const DEBUG := true
const CONTOUR_LINES = [
	Vector2.ZERO,				# 0
	
	PoolVector2Array([			# 1
		Vector2(0.0, 0.5),
		Vector2(0.5, 1.0),
		Vector2(0.0, 1.0)]),
	
	PoolVector2Array([			# 2
		Vector2(0.5, 1.0),
		Vector2(1.0, 0.5),
		Vector2(1.0, 1.0)]),
	
	PoolVector2Array([			# 3
		Vector2(0.0, 0.5),
		Vector2(1.0, 0.5),
		Vector2(1.0, 1.0),
		Vector2(0.0, 1.0)]),

	PoolVector2Array([			# 4
		Vector2(0.5, 0.0),
		Vector2(1.0, 0.0),
		Vector2(1.0, 0.5)]),
	
	PoolVector2Array([			# 5
		Vector2(0.5, 1.0),
		Vector2(1.0, 0.5),
		Vector2(0.0, 0.5),
		Vector2(0.5, 0.0)]),
						
	PoolVector2Array([			# 6
		Vector2(0.5, 0.0),
		Vector2(1.0, 0.0),
		Vector2(1.0, 1.0),
		Vector2(0.5, 1.0)]),
	
	PoolVector2Array([			# 7
		Vector2(0.5, 0.0),
		Vector2(1.0, 0.0),
		Vector2(1.0, 1.0),
		Vector2(0.0, 1.0),
		Vector2(0.0, 0.5)]),

	PoolVector2Array([			# 8
		Vector2(0.0, 0.0),
		Vector2(0.5, 0.0),
		Vector2(0.0, 0.5)]),
	
	PoolVector2Array([			# 9
		Vector2(0.0, 0.0),
		Vector2(0.5, 0.0),
		Vector2(0.5, 1.0),
		Vector2(0.0, 1.0)]),
	
	PoolVector2Array([			# 10
		Vector2(0.0, 0.5),
		Vector2(0.5, 1.0),
		Vector2(0.5, 0.0),
		Vector2(1.0, 0.5)]),	
					
	PoolVector2Array([			# 11
		Vector2(0.0, 0.0),
		Vector2(0.5, 0.0),
		Vector2(1.0, 0.5),
		Vector2(1.0, 1.0),
		Vector2(0.0, 1.0)]),

	PoolVector2Array([			# 12
		Vector2(0.0, 0.0),
		Vector2(1.0, 0.0),
		Vector2(1.0, 0.5),
		Vector2(0.0, 0.5)]),
	
	PoolVector2Array([			# 13
		Vector2(0.0, 0.0),
		Vector2(1.0, 0.0),
		Vector2(1.0, 0.5),
		Vector2(0.5, 1.0),
		Vector2(0.0, 1.0)]),
	
	PoolVector2Array([			# 14
		Vector2(0.0, 0.0),
		Vector2(1.0, 0.0),
		Vector2(1.0, 1.0),
		Vector2(0.5, 1.0),
		Vector2(0.0, 0.5)]),
	
	PoolVector2Array([			# 15
		Vector2(0.0, 0.0),
		Vector2(1.0, 0.0),
		Vector2(1.0, 1.0),
		Vector2(0.0, 1.0)])]

# shape settings
export(int) var number_of_circles := 5
export(float) var maximum_radius := 96.0
export(float) var minimum_radius := 16.0
export(float) var radius_delta := 16.0

export(int) var width := 64
export(int) var height := 64
export(float) var threshold := 0.01

var scalar_field := PoolIntArray([])
var bit_field := PoolIntArray([])

var circles := []
var radius := maximum_radius

# ----------------------------
# Built-in Function(s)
# ----------------------------
func _ready() -> void:
	# TEMP
	$Camera2D.offset = Vector2(10 * (width / 2), 10 * (height / 2))
	
	randomize()
	
	_create_circles()
	_populate_scalar_field()
	_compose_bit_field()
	_create_polygon()
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.scancode == KEY_SPACE and event.is_pressed():
			scalar_field = PoolIntArray([])
			bit_field = PoolIntArray([])
			circles = []
			radius = maximum_radius
			
			_create_circles()
			_populate_scalar_field()
			_compose_bit_field()
			_create_polygon()
			update()

func _draw() -> void:
	if DEBUG:
		# debug - draw scalar field points
		for i in scalar_field.size():
			if scalar_field[i] == 1:
				draw_circle(_index_to_coord_full(i) * 10, 2, Color.white)
			else:
				draw_circle(_index_to_coord_full(i) * 10, 2, Color.black)
		
		# debug - draw asteroid circles
		for c in circles:
			draw_circle(c["pos"], c["radius"], Color(randf(), randf(), randf(), 0.5))


# ----------------------------
# Marching Squares Functions
# ----------------------------
func _create_circles() -> void:
	var offset = Vector2(10 * (width / 2), 10 * (height / 2))
	
	# create main circle
	var circle = {"pos": offset, "radius": radius}
	circles.append(circle)
	radius -= radius_delta
	
	for i in number_of_circles:
		# find point on last circle's circumference
		var pos := Vector2.ZERO
		var random_circle = circles.back()
		var angle := rand_range(0, 2 * PI)
		var x: float = random_circle["pos"].x + random_circle["radius"] * cos(angle)
		var y: float = random_circle["pos"].y + random_circle["radius"] * sin(angle)
		pos = Vector2(x, y)
		
		# create circle
		circle = {"pos": pos, "radius": radius}
		circles.append(circle)
		
		# decrease radius and exit loop early if radius is smaller than minimum radius
		radius -= radius_delta
		if radius <= minimum_radius:
			break

func _populate_scalar_field() -> void:
	for x in width:
		for y in height:
			var within_circle := false
			for c in circles:
				var distance_to_circle = (Vector2(x, y) * 10).distance_to(c["pos"])
				if distance_to_circle < c["radius"]:
					scalar_field.append(1)
					within_circle = true
					break
			if !within_circle:
				scalar_field.append(0)

func _compose_bit_field() -> void:
	for x in width - 1:
		for y in height - 1:
			# get scalar field vertices
			var top_left_vertex := scalar_field[_coord_to_index(x, y, width)]
			var top_right_vertex := scalar_field[_coord_to_index(x + 1, y, width)]
			var bottom_right_vertex := scalar_field[_coord_to_index(x + 1, y + 1, width)]
			var bottom_left_vertex := scalar_field[_coord_to_index(x, y + 1, width)]
			
			# determine bit value from vertices
			var bit_value := (8 * top_left_vertex) + (4 * top_right_vertex) + (2 * bottom_right_vertex) + (1 * bottom_left_vertex)
			
			# set bit value in bit field
			bit_field.append(bit_value)

# TODO: fix issue where during iteration a polygon section can't be connected to the main merged polygon - however,
#	that polygon section is part of the main polygon
#	maybe use a flood-fill inspired algorithm?
#	need to think about when an asteroid is split up (flood fill to determine the different asteroid parts? -> then
#		create as many CollisionPolygon2Ds and Polygon2Ds as needed?)
func _create_polygon() -> void:
	var merged_polygon := [_create_polygon_section(bit_field[0], _index_to_coord(0))]
	for i in range(1, bit_field.size(), 1):
		if bit_field[i] == 0 or bit_field[i] == 5 or bit_field[i] == 10:
			continue

		var polygon := _create_polygon_section(bit_field[i], _index_to_coord(i))
		merged_polygon = Geometry.merge_polygons_2d(merged_polygon[0], polygon)

	$CollisionPolygon2D.polygon = merged_polygon[0]
	$Polygon2D.polygon = merged_polygon[0]


func _create_polygon_section(bit_value: int, offset: Vector2) -> PoolVector2Array:
	var polygon := PoolVector2Array([])
	
	var points = CONTOUR_LINES[bit_value]
	for p in points:
		polygon.append((p + offset) * 10)
	
	return polygon


# ----------------------------
# Utility Functions
# ----------------------------
func _coord_to_index(x: int, y: int, w: int) -> int:
	return x * w + y

func _index_to_coord(index: int) -> Vector2:
	return Vector2(index / (width - 1), index % (height - 1))

func _index_to_coord_full(index: int) -> Vector2:
	return Vector2(index / width, index % height)

func _print_2d_array(array: Array, row_size: int, col_size: int) -> void:
	for i in col_size:
		var row := []
		for j in row_size:
			row.append(array[_coord_to_index(j, i, row_size)])
		print(row)


# ----------------------------
# Signal Funcions
# ----------------------------
func mine() -> void:
	pass
