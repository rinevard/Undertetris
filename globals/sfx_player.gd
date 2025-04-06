extends AudioStreamPlayer

const REMOVE = preload("res://assets/sfx/remove.wav")

func play_music(music: AudioStream):
	if stream == music:
		return
	
	stream = music
	play()

func play_remove():
	play_music(REMOVE)
