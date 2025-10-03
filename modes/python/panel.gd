extends TextForgePanel


func _on_button_pressed() -> void:
	var output: Array
	OS.execute("python", [Global.get_file_path()], output)
	await get_tree().process_frame
	$MarginContainer/VBoxContainer/Output.text = "\n\n".join(output)
