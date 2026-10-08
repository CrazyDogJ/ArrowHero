extends Label

func _process(delta: float) -> void:
	text = tr("seed") + " : " + RandomGenerator.global_seed
