extends Label

@export var round_time : RoundTime

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(round_time):
		var crt = round_time.asc.get_attribute("current_round_time").current_value
		text = "%s : %s" % [tr("round_time"),str(snapped(crt, 0.1))]
