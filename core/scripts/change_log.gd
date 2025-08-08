extends Node


func _ready() -> void:
	var markdown_text: String = FileAccess.get_file_as_string("res://CHANGELOG.md")
	var bbcode_text: String = _convert_text_from_markdown_to_bbcode_style(markdown_text)
	$Text.text = bbcode_text


func _convert_text_from_markdown_to_bbcode_style(markdown_text: String) -> String:
	var text: String = markdown_text
	
	# H1 headers: # Header1 -> [font_size=24][b][u]Header1[/u][/b][/font_size]
	var h1_regex: RegEx = RegEx.new()
	h1_regex.compile(r"(?m)^# (.+)$")
	text = h1_regex.sub(text, "[font_size=24][b][u]$1[/u][/b][/font_size]", true)
	
	# H2 headers: ## Header2 -> [font_size=20][b][u]Header2[/u][/b][/font_size]
	var h2_regex: RegEx = RegEx.new()
	h2_regex.compile(r"(?m)^## (.+)$")
	text = h2_regex.sub(text, "[font_size=20][b][u]$1[/u][/b][/font_size]", true)
	
	# H3 headers: ### Header3 -> [font_size=16][b]Header3[/b][/font_size]
	var h3_regex: RegEx = RegEx.new()
	h3_regex.compile(r"(?m)^### (.+)$")
	text = h3_regex.sub(text, "[font_size=16][b]$1[/b][/font_size]", true)
	
	# Bold: **text** -> [b]text[/b]
	var bold_regex: RegEx = RegEx.new()
	bold_regex.compile(r"\*\*(.+?)\*\*")
	text = bold_regex.sub(text, "[b]$1[/b]", true)
	
	# Inline code: `code` -> [code]code[/code]
	var code_regex: RegEx = RegEx.new()
	code_regex.compile(r"`([^`]+)`")
	text = code_regex.sub(text, "[code]$1[/code]", true)
	
	# Links: [title](url) -> [url=url]title[/url]
	var link_regex: RegEx = RegEx.new()
	link_regex.compile(r"\[([^\]]+)\]\(([^)]+)\)")
	text = link_regex.sub(text, "[url=$2]$1[/url]", true)
	
	# Lists: - item -> • item
	var list_regex: RegEx = RegEx.new()
	list_regex.compile(r"(?m)^- ")
	text = list_regex.sub(text, "• ", true)
	
	return text
