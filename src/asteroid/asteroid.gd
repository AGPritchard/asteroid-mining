class_name Asteroid
extends StaticBody2D

const DEBUG_SETTINGS = {
	"DRAW_CIRCLES": false,
	"DRAW_SCALAR_FIELD": false,
	"DRAW_BIT_FIELD": false,
	"HIDE_POLYGON": false,
}

const CONTOUR_LINES := [
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
const VALID_NORTH_MOVES := {
	0: [],
	1: [],
	2: [],
	3: [],
	4: [2, 6, 10, 14],
	5: [2, 6, 10, 14],
	6: [2, 10, 14],
	7: [2, 6, 10, 14],
	8: [1, 5, 9, 13],
	9: [1, 5, 13],
	10: [1, 5, 9, 13],
	11: [1, 5, 9, 13],
	12: [3, 7, 11, 15],
	13: [3, 7, 11, 15],
	14: [3, 7, 11, 15],
	15: [3, 7, 11, 15]}
const VALID_EAST_MOVES := {
	0: [],
	1: [],
	2: [1, 3, 5, 7],
	3: [1, 3, 5, 7],
	4: [8, 10, 12, 14],
	5: [8, 10, 12, 14],
	6: [9, 11, 13, 15],
	7: [9, 11, 13, 15],
	8: [],
	9: [],
	10: [1, 3, 5, 7],
	11: [1, 3, 5, 7],
	12: [8, 10, 12, 14],
	13: [8, 10, 12, 14],
	14: [9, 11, 13, 15],
	15: [9, 11, 13, 15]}
const VALID_SOUTH_MOVES := {
	0: [],
	1: [8, 9, 10, 11],
	2: [4, 5, 6, 7],
	3: [12, 13, 14, 15],
	4: [],
	5: [8, 9, 10, 11],
	6: [4, 5, 6, 7],
	7: [12, 13, 14, 15],
	8: [],
	9: [8, 9, 10, 11],
	10: [4, 5, 6, 7],
	11: [12, 13, 14, 15],
	12: [],
	13: [8, 9, 10, 11],
	14: [4, 5, 6, 7],
	15: [12, 13, 14, 15]}
const VALID_WEST_MOVES := {
	0: [],
	1: [2, 3, 10, 11],
	2: [],
	3: [2, 3, 10, 11],
	4: [],
	5: [2, 3, 10, 11],
	6: [],
	7: [2, 3, 10, 11],
	8: [4, 5, 12, 13],
	9: [6, 7, 14, 15],
	10: [4, 5, 12, 13],
	11: [6, 7, 14, 15],
	12: [4, 5, 12, 13],
	13: [6, 7, 14, 15],
	14: [4, 5, 12, 13],
	15: [6, 7, 14, 15]}

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

var polygons := []
var indices_visited := []
var merged_polygon := [[Vector2.ZERO]]

var asteroid_texture := preload("res://assets/asteroids/asteroid_test.png")

# ----------------------------
# Built-in Function(s)
# ----------------------------
func _ready() -> void:
	randomize()
	_generate_shape()
	_populate_scalar_field()
	_compose_bit_field()
	_create_polygons()

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
	
	if DEBUG_SETTINGS["DRAW_SCALAR_FIELD"]:
		update()
	
	# reset polygon data
	bit_field = PoolIntArray([])
	polygons = []
	indices_visited = []
	merged_polygon = [[Vector2.ZERO]]
	
	# recompose bit field
	_compose_bit_field()

	# fill polygon again
	_create_polygons()

	
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

# TODO: convert nested for-loop (x & y) to a single for-loop (i)
# TODO: implement create polygon section functionality for cases 5 and 10
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
			if bit_value == 5 || bit_value == 10:
				# TEMP: removes the need to sort out cases 5 and 10
				bit_field.append(0)
			else:
				bit_field.append(bit_value)

# IDEA: rather than removing polygon nodes
#		  keep track of polygon nodes and only remove polygon nodes if -
#		  polygon_nodes.size() > polygons.size()
func _create_polygons() -> void:
	# remove polygon nodes
	for c in get_children():
		if c is Polygon2D || c is CollisionPolygon2D:
			c.queue_free()
	
	# iterate bit field and fill all polygons
	for i in bit_field.size():
		if bit_field[i] == 0 || i in indices_visited:
			continue
		
		_polygon_fill(i)
		polygons.append(merged_polygon[0])
		merged_polygon = [[Vector2.ZERO]]
	
	# create new polygon nodes and set polygon data
	for p in polygons:
		var polygon_2d := Polygon2D.new()
		var collision_polygon_2d := CollisionPolygon2D.new()
		
		polygon_2d.set_polygon(p)
		collision_polygon_2d.set_polygon(p)
		
		polygon_2d.texture = asteroid_texture
		
		if DEBUG_SETTINGS["HIDE_POLYGON"]:
			polygon_2d.hide()
		
		add_child(polygon_2d)
		add_child(collision_polygon_2d)	

func _polygon_fill(index: int) -> void:
	if bit_field[index] == 0 || index in indices_visited:
		return
	
	var section := _create_polygon_section(bit_field[index], _index_to_coord(index, width-1, height-1))
	merged_polygon = Geometry.merge_polygons_2d(merged_polygon[0], section)
	indices_visited.append(index)
	
	if index > 0 && index < bit_field.size():
		# get valid moves for each direction
		var valid_north_moves = VALID_NORTH_MOVES[bit_field[index]]
		var valid_east_moves = VALID_EAST_MOVES[bit_field[index]]
		var valid_south_moves = VALID_SOUTH_MOVES[bit_field[index]]
		var valid_west_moves = VALID_WEST_MOVES[bit_field[index]]

		# if the next move is in the list of valid moves for the
		# respective direction then continue _polygon_fill in that direction
		if bit_field[index - 1] in valid_north_moves:
			_polygon_fill(index - 1)
		if bit_field[index + 1] in valid_south_moves:
			_polygon_fill(index + 1)
		if bit_field[index - width + 1] in valid_west_moves:
			_polygon_fill(index - width + 1)
		if bit_field[index + width - 1] in valid_east_moves:
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
