class_name Asteroid
extends StaticBody2D

const DEBUG_SETTINGS = {
	"DRAW_CIRCLES": true,
	"DRAW_SCALAR_FIELD": false,
	"DRAW_BIT_FIELD": false,
}

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
const POINT_DISTANCE := 10

# shape settings
export(int) var number_of_circles := 4
export(float) var maximum_radius := 96.0
export(float) var minimum_radius := 16.0
export(float) var radius_delta := 16.0

# field dimensions
export(int) var width := 64
export(int) var height := 64

var circles := []
var radius := maximum_radius

var scalar_field := PoolIntArray([])
var bit_field := PoolIntArray([])

var indices_visited = []
var merged_polygon = [[Vector2.ZERO]]

# ----------------------------
# Built-in Function(s)
# ----------------------------
func _ready() -> void:
	randomize()
	_generate_shape()
	_populate_scalar_field()
	_compose_bit_field()
	_polygon_fill(scalar_field.size() / 2)
	$CollisionPolygon2D.set_polygon(merged_polygon[0])
	$Polygon2D.set_polygon(merged_polygon[0])

func _draw() -> void:
	# draw circles
	if DEBUG_SETTINGS["DRAW_CIRCLES"]:
		for c in circles:
			draw_circle(c["pos"], c["radius"], Color(randf(), randf(), randf(), 0.1))
	
	# draw scalar field
	if DEBUG_SETTINGS["DRAW_SCALAR_FIELD"]:
		for i in scalar_field.size():
			if scalar_field[i] == 1:
				draw_circle(_index_to_coord(i, width, height) * POINT_DISTANCE, 2, Color(1.0, 1.0, 1.0, 0.5))
			else:
				draw_circle(_index_to_coord(i, width, height) * POINT_DISTANCE, 2, Color(0.0, 0.0, 0.0, 0.5))
	
	# draw bit field
	if DEBUG_SETTINGS["DRAW_BIT_FIELD"]:
		for i in bit_field.size():
			var position := (_index_to_coord(i, width-1, height-1) * POINT_DISTANCE) + ((Vector2.ONE * POINT_DISTANCE) / 2)
			match bit_field[i]:
				0:
					draw_circle(position, 1.0, Color.red)
				15:
					draw_circle(position, 1.0, Color.blue)
				_:
					draw_circle(position, 1.0, Color.green)


# ----------------------------
# Public Functions
# ----------------------------
func destruct(pos: Vector2, radius: float) -> void:
	# convert destruct position to scalar field coordinates
	pos = to_local(pos) / POINT_DISTANCE
	
	# set scalar values to 'off' if within destruction circle
	for i in scalar_field.size():
		var point := _index_to_coord(i, width, height)
		if Geometry.is_point_in_circle(point, pos, radius):
			scalar_field[i] = 0
	
	# reset polygon data
	bit_field = PoolIntArray([])
	indices_visited = []
	merged_polygon = [[Vector2.ZERO]]
	
	# recompose bit field
	_compose_bit_field()

	# fill polygon again
	_polygon_fill(scalar_field.size() / 2)
	$CollisionPolygon2D.set_polygon(merged_polygon[0])
	$Polygon2D.set_polygon(merged_polygon[0])

	
# ----------------------------
# Marching Squares Functions
# ----------------------------
func _generate_shape() -> void:
	# get offset
	var offset := Vector2(width / 2.0, height / 2.0) * POINT_DISTANCE
	
	# create main circle
	var circle = {"pos": offset, "radius": radius}
	circles.append(circle)
	radius -= radius_delta
	
	for i in number_of_circles:
		# find point on last circle's circumference
		var last_circle = circles.back()
		var new_pos := Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))
		new_pos *= last_circle["radius"]
		new_pos += last_circle["pos"]
		
		# add circle
		circle = {"pos": new_pos, "radius": radius}
		circles.append(circle)
		
		# decrease radius and exit loop early if radius is smaller than minimum radius
		radius -= radius_delta
		if radius <= minimum_radius:
			break

func _populate_scalar_field() -> void:
	for i in width * height:
		var within_circle := false
		var scalar_position := _index_to_coord(i, width, height) * POINT_DISTANCE
		
		# check to see if the scalar point is within a circle
		for c in circles:
			var distance_to_circle := scalar_position.distance_to(c["pos"])
			if distance_to_circle < c["radius"]:
				scalar_field.append(1)			# 1 indicates 'on'
				within_circle = true
				break
		
		if !within_circle:
			scalar_field.append(0)				# 0 indicates 'off'

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

func _polygon_fill(index: int) -> void:
	if bit_field[index] == 0 || index in indices_visited:
		return
	
	var section := _create_polygon_section(bit_field[index], _index_to_coord(index, width-1, height-1))
	merged_polygon = Geometry.merge_polygons_2d(merged_polygon[0], section)
	indices_visited.append(index)
	
	if index > 0 && index < bit_field.size():
		_polygon_fill(index - 1)
		_polygon_fill(index + 1)
		_polygon_fill(index - width + 1)
		_polygon_fill(index + width - 1)
	
func _create_polygon_section(bit_value: int, offset: Vector2) -> PoolVector2Array:
	var section := PoolVector2Array([])
	
	var points = CONTOUR_LINES[bit_value]
	for p in points:
		section.append((p + offset) * POINT_DISTANCE)
	
	return section


# ----------------------------
# Utility Functions
# ----------------------------
func _index_to_coord(index: int, w: int, h: int) -> Vector2:
	return Vector2(index / w, index % h)

func _coord_to_index(x: int, y: int, w: int) -> int:
	return x * w + y

func _coord_to_index_vector2(coord: Vector2, w: int) -> int:
	return int(coord.x) * w + int(coord.y)
