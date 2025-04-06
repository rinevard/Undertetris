class_name MainMenu
extends Control

signal need_resume()
signal need_restart()
signal need_quit()

var is_paused: bool = false

func _input(event):
	if event.is_action_released("esc"):
		toggle_state()

func toggle_state():
	if is_paused:
		visible = false
		Engine.time_scale = 1
		is_paused = false
	else:
		visible = true
		Engine.time_scale = 0
		is_paused = true

func _on_resume_button_pressed():
	toggle_state()
	need_resume.emit()

func _on_quit_button_pressed():
	toggle_state()
	need_quit.emit()

func _on_restart_button_pressed():
	toggle_state()
	need_restart.emit()
