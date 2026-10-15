extends Label

@export var round_time : RoundTime

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(round_time):
		var crt = round_time.asc.get_attribute("current_round_time").current_value
		var cd : int = int(round_time.asc.get_attribute("current_day").current_value)
		text = "%s : %s, %s : %s" % [tr("day"),str(cd),tr("round_time"),str(snapped(crt, 0.1))]
