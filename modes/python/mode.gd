extends TextForgeMode

var keyword_colors: Dictionary[Color, Array] = {
	U.get_syntax_color(U.SyntaxColors.KEYWORD_1): ["def", "class", "lambda", "return", "yield", "try", "except", "finally", "raise"],
	U.get_syntax_color(U.SyntaxColors.KEYWORD_2): ["if", "elif", "else", "for", "while", "break", "continue", "pass", "with", "as", "assert"],
	U.get_syntax_color(U.SyntaxColors.KEYWORD_3): ["import", "from", "global", "nonlocal", "del", "and", "or", "not", "in", "is"],
	U.get_syntax_color(U.SyntaxColors.BUILTIN): ["True", "False", "None"],
}
var code_regions: Array[Array] = [
	[U.get_syntax_color(U.SyntaxColors.STRING), '"', '"', false],
	[U.get_syntax_color(U.SyntaxColors.STRING), "'", "'", false],
	[U.get_syntax_color(U.SyntaxColors.STRING), "'''", "'''", false],
	[U.get_syntax_color(U.SyntaxColors.STRING), '"""', '"""', false],
	[U.get_syntax_color(U.SyntaxColors.COMMENT), "#", "", true],
]

func _initialize_mode() -> Error:
	_initialize_highlighter()
	panel = U.load_resource("user://modes/python/panel.tscn").instantiate()
	comment_delimiters.append({
		"start_key": "#",
		"end_key": "",
		"line_only": true,
	})
	string_delimiters.append({
		"start_key": '"',
		"end_key": '"',
		"line_only": false,
	})
	string_delimiters.append({
		"start_key": "'",
		"end_key": "'",
		"line_only": false,
	})
	string_delimiters.append({
		"start_key": '"""',
		"end_key": '"""',
		"line_only": false,
	})
	string_delimiters.append({
		"start_key": "'''",
		"end_key": "'''",
		"line_only": false,
	})
	_enable_auto_format_feature()

	return OK


func _auto_format(text: String) -> String:
	var lines := text.split("\n")
	var cleaned := []
	var spacing_re := RegEx.new()
	spacing_re.compile("\\s*([=+\\-*/%<>&|^~!]=?|==|!=|<=|>=|\\*\\*|//)\\s*")

	for raw_line in lines:
		var indent_len := raw_line.length() - raw_line.lstrip(" \t").length()
		var indent := raw_line.substr(0, indent_len)
		var code := raw_line.lstrip(" \t")

		code = spacing_re.sub(code, " $1 ", true)
		code = code.replace(", ", ",")
		code = code.replace(",", ", ")
		code = code.replace("( ", "(")
		code = code.replace(" )", ")")
		code = code.replace(" :", ":")
		while code.find("  ") != -1:
			code = code.replace("  ", " ")

		cleaned.append(indent + code)

	return "\n".join(cleaned)


func _update_code_completion_options(text: String) -> void:
	for color in keyword_colors:
		for keyword in keyword_colors[color]:
			Global.get_editor().add_code_completion_option(CodeEdit.KIND_CLASS, keyword, keyword, color)


func _generate_outline(text: String) -> Array:
	var outline := Array()
	for l in text.split("\n").size():
		var line := text.split("\n")[l]
		if line.begins_with("def "):
			outline.append([line.substr(4, line.find("(") - 4),l])
	return outline


# TODO
func _lint_file(text: String) -> Array[Dictionary]:
	return Array([], TYPE_DICTIONARY, "", null)


func _initialize_highlighter() -> void:
	syntax_highlighter = CodeHighlighter.new()
	syntax_highlighter.number_color = U.get_syntax_color(U.SyntaxColors.NUMBER)
	syntax_highlighter.symbol_color = U.get_syntax_color(U.SyntaxColors.SYMBOL)
	syntax_highlighter.function_color = U.get_syntax_color(U.SyntaxColors.FUNCTION)
	syntax_highlighter.member_variable_color = U.get_syntax_color(U.SyntaxColors.MEMBER)
	for color in keyword_colors:
		for keyword in keyword_colors[color]:
			syntax_highlighter.add_keyword_color(keyword, color)

	for region in code_regions:
		syntax_highlighter.add_color_region(region[1], region[2], region[0], region[3])

