extends AudioStreamPlayer

const ROTATE = preload("res://assets/sfx/rotate.wav")

func play_music(music: AudioStream):
	if stream == music and playing:
		return
	
	stream = music
	play()

func play_rotate_sfx():
	play_music(ROTATE)
