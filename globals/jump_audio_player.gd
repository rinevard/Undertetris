extends AudioStreamPlayer

const JUMP = preload("res://assets/sfx/jump.wav")

func play_music(music: AudioStream):
	if stream == music and playing:
		return
	
	stream = music
	play()

func play_jump_sfx():
	play_music(JUMP)
