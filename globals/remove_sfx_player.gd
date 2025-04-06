extends AudioStreamPlayer

const REMOVE = preload("res://assets/sfx/remove.wav")

func play_music(music: AudioStream):
	if stream == music and playing:
		return
	
	stream = music
	play()

func play_remove():
	play_music(REMOVE)
