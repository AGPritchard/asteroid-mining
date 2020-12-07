extends Node


func poisson_disk_sampling(minimum_distance: float, sample_region: Vector2, sample_limit: int = 30) -> PoolVector2Array:
	# calculate cell_size - minimum_distance is the diagonal of the cell -> 
	#	apply Pythagoras' rule and simplifiy to get the following
	var cell_size := minimum_distance / sqrt(2.0)
	
	# initialize a 2-dimensional background grid for storing sample indices and accelerating spatial searches
	var grid := PoolIntArray([])
	var grid_width: int = ceil(sample_region.x / cell_size)
	var grid_height: int = ceil(sample_region.y / cell_size)
	for i in grid_width * grid_height:
		grid.append(-1)					# -1 indicates no sample
	
	var points := PoolVector2Array([])
	var active_list := PoolVector2Array([])
	
	active_list.append(sample_region / 2.0)
	
	while !active_list.empty():
		var random_index := randi() % active_list.size()
		var random_sample := active_list[random_index]
		
		var is_found := false
		for i in sample_limit:
			var new_sample := Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))
			var magnitude := rand_range(minimum_distance, 2*minimum_distance)
			new_sample *= magnitude
			new_sample += random_sample
			
			var is_sample_valid := false
			
			# within sample region check
			if (new_sample.x >= 0 and new_sample.x < sample_region.x and 
				new_sample.y >= 0 and new_sample.y < sample_region.y):
				is_sample_valid = true
			
			# within minimum distance of neighbours check
			var cell_x: int = new_sample.x / cell_size
			var cell_y: int = new_sample.y / cell_size
			var search_start_x := max(0, cell_x - 1)
			var search_end_x := min(cell_x + 1, grid_width)
			var search_start_y := max(0, cell_y - 1)
			var search_end_y := min(cell_y + 1, grid_height)
			
			for x in range(search_start_x, search_end_x, 1):
				for y in range(search_start_y, search_end_y, 1):
					var index := grid[_coord_to_index(Vector2(x, y), grid_width)]
					if index != -1:
						var distance := new_sample.distance_to(points[index - 1])
						if distance < minimum_distance:
							is_sample_valid = false
							break
			
			if is_sample_valid:
				points.append(new_sample)
				active_list.append(new_sample)
				grid[_coord_to_index(new_sample / cell_size, grid_width)] = points.size()
				is_found = true
				break
		
		if !is_found:
			active_list.remove(random_index)
	
	return points


# ----------------------------
# Utility Functions
# ----------------------------
func _coord_to_index(coord: Vector2, width: int) -> int:
	return int(coord.x) * width + int(coord.y)
