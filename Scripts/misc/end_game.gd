extends Node

@export_file var main_menu_scene

func _ready():
	$UI/VBoxContainer/name.text = Global.winner.f_n + " a gagné !"
	$UI/VBoxContainer/icon.texture = Global.winner.ic

	$UI/VBoxContainer/Button.pressed.connect(Callable(self, "main_menu"))

func main_menu():
#	Global.goto_scene(main_menu_scene)
	get_tree().change_scene_to_file(main_menu_scene)
