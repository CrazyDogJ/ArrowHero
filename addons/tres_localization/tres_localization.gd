@tool
extends EditorPlugin

var parser_plugin:TresPotSupport


func _enter_tree() -> void:
	parser_plugin = TresPotSupport.new()
	add_translation_parser_plugin(parser_plugin)


func _exit_tree() -> void:
	remove_translation_parser_plugin(parser_plugin)
	parser_plugin = null
