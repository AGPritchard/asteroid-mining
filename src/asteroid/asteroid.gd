class_name Asteroid
extends StaticBody2D

signal break_up(pos)

var size := 4

func _ready() -> void:
	# temp
	match size:
		1:
			$Sprite.scale = Vector2.ONE * 0.25
		2:
			$Sprite.scale = Vector2.ONE * 0.50
		3:
			$Sprite.scale = Vector2.ONE * 0.75
		4:
			$Sprite.scale = Vector2.ONE
	
	$CollisionShape2D.shape.extents = (Vector2.ONE * 32) * $Sprite.scale

func mine() -> void:
	if size > 1:
		emit_signal("break_up", global_position)
		size -= 1
		
		# temp
		match size:
			1:
				$Sprite.scale = Vector2.ONE * 0.25
			2:
				$Sprite.scale = Vector2.ONE * 0.50
			3:
				$Sprite.scale = Vector2.ONE * 0.75
			4:
				$Sprite.scale = Vector2.ONE
		
		$CollisionShape2D.shape.extents = (Vector2.ONE * 32) * $Sprite.scale
	else:
		queue_free()
