enum ArrowState
{
	Unhandled,
	Correct,
	Wrong
}

enum ArrowDirection
{
	Invalid,
	Up,
	Right,
	Down,
	Left
}

enum AttributeDisplayType
{
	Float,
	Int
}

static func get_correct_num(states : Array[ArrowState]) -> int:
	var result : int = 0
	for state in states:
		if state == ArrowState.Correct:
			result += 1
	return result
