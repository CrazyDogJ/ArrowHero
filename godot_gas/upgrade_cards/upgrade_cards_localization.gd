class_name UpgradeCards extends Resource

@export var cards : Array[UpgradeCard]

func get_cards_weights() -> Array[float]:
	var result : Array[float]
	for card in cards:
		result.push_back(card.card_store_weight)
	return result
