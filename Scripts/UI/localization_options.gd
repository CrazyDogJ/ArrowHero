extends OptionButton

# 可选：让语言显示为自己的名称。
# 这里只控制显示文字，不决定有哪些可选语言。
const LANGUAGE_NAMES := {
	"en": "English",
	"en_US": "English (US)",
	"zh_CN": "简体中文",
	"zh_TW": "繁體中文",
	"ja": "日本語",
	"ko": "한국어",
}

func _ready() -> void:
	item_selected.connect(_on_language_selected)
	refresh_languages()

# 如果运行时动态加载了新的翻译资源，再调用一次这个方法。
func refresh_languages() -> void:
	clear()
	var locales := TranslationServer.get_loaded_locales()
	locales.sort()

	for locale in locales:
		var display_name: String = LANGUAGE_NAMES.get(
			locale,
			TranslationServer.get_locale_name(locale)
		)
		add_item(display_name)
		# 将语言代码保存在选项中，切换时直接读取。
		set_item_metadata(item_count - 1, locale)
	disabled = locales.is_empty()
	_sync_selection()

func _sync_selection() -> void:
	var current_locale := TranslationServer.get_locale()
	var best_index := -1
	var best_score := 0
	for index in range(item_count):
		var locale: String = get_item_metadata(index)
		var score := TranslationServer.compare_locales(
			current_locale, locale
		)
		# 优先完全匹配，也兼容 en_US 对应 en 等情况。
		if score > best_score:
			best_score = score
			best_index = index
	# 没有匹配语言时不选中任何项。
	# select() 不会触发 item_selected 信号。
	select(best_index)

func _on_language_selected(index: int) -> void:
	var locale: String = get_item_metadata(index)
	TranslationServer.set_locale(locale)

func _notification(what: int) -> void:
	# 如果其他脚本切换了语言，也同步更新这个下拉框。
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_sync_selection()
