extends RichTextLabel

func _convert_text_from_markdown_to_bbcode_style(markdown_text: String) -> String:
	var _text := markdown_text

	# H1 headers: # Header1 -> [font_size=24][b]Header1[/b][/font_size]
	var h1_regex := RegEx.new()
	h1_regex.compile(r"(?m)^# (.+)$")
	_text = h1_regex.sub(_text, "[font_size=24][b]$1[/b][/font_size]", true)

	# H2 headers: ## Header2 -> [font_size=20][b]Header2[/b][/font_size]
	var h2_regex := RegEx.new()
	h2_regex.compile(r"(?m)^## (.+)$")
	_text = h2_regex.sub(_text, "[font_size=20][b]$1[/b][/font_size]", true)

	# H3 headers: ### Header3 -> [font_size=16][b]Header3[/b][/font_size]
	var h3_regex := RegEx.new()
	h3_regex.compile(r"(?m)^### (.+)$")
	_text = h3_regex.sub(_text, "[font_size=16][b]$1[/b][/font_size]", true)

	# Bold: **text** -> [b]text[/b]
	var bold_regex := RegEx.new()
	bold_regex.compile(r"\*\*(.+?)\*\*")
	_text = bold_regex.sub(_text, "[b]$1[/b]", true)

	# Inline code: `code` -> [code]code[/code]
	var code_regex := RegEx.new()
	code_regex.compile(r"`([^`]+)`")
	_text = code_regex.sub(_text, "[code]$1[/code]", true)

	# Links: [title](url) -> [url=url]title[/url]
	var link_regex := RegEx.new()
	link_regex.compile(r"\[([^\]]+)\]\(([^)]+)\)")
	_text = link_regex.sub(_text, "[url=$2]$1[/url]", true)

	# Commit SHA: ([SHA]()) -> ([code]SHA[/code])
	var sha_regex := RegEx.new()
	sha_regex.compile(r"\(\[([0-9a-f]{7})\]\(\)\)")
	_text = sha_regex.sub(_text, "([code]$1[/code])", true)

	# Lists: - item -> • item
	var list_regex := RegEx.new()
	list_regex.compile(r"(?m)^- ")
	_text = list_regex.sub(_text, "• ", true)

	# Version links: [label]: url -> [url=url]label[/url]
	var version_link_regex := RegEx.new()
	version_link_regex.compile(r"^\[([^\]]+)\]:\s*(https?://[^\s]+)$")
	var version_link_dict: Dictionary[String, String] = {}
	for line in _text.split("\n"):
		var matched_string: RegExMatch = version_link_regex.search(line)
		if matched_string:
			version_link_dict[matched_string.get_string(1)] = matched_string.get_string(2)
			_text = _text.replace(line + "\n", "")

	for version in version_link_dict.keys():
		_text = _text.replace("[%s]" % version, "[url=%s]%s[/url]" % [version_link_dict[version], version])

	return _text


func _on_about_about_to_popup() -> void:
	var markdown_text := FileAccess.get_file_as_string(S.globalize_path("res://CHANGELOG.md"))
	var bbcode_text := _convert_text_from_markdown_to_bbcode_style(markdown_text)
	text = bbcode_text
