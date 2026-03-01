extends CharacterBody3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rotate_x(1.8 * delta)
	#print(0.18 * delta)
