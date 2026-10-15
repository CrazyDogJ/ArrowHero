@tool
class_name TresPotSupport
extends EditorTranslationParserPlugin

func _parse_file(path) -> Array[PackedStringArray]:
	var ret: Array[PackedStringArray] = []
	var res: Resource = load(path)
	if not res:
		return ret

	if res is UpgradeCards: #UnitType is a specific resource type I have
		var cards : UpgradeCards = res
		for card in cards.cards:
			var pack:= PackedStringArray()
			pack.append(card.card_name) #default_name is the specific string property I want to translate
			ret.append(pack)
			pack = PackedStringArray()
			pack.append(card.card_desc)
			ret.append(pack)
	return ret


func _get_recognized_extensions():
	return ["tres"]
