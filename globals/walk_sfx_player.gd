extends AudioStreamPlayer

const WALK = preload("res://assets/sfx/walk.wav")

func play_music(music: AudioStream):
	if stream == music and playing:
		return
	
	stream = music
	play()

func play_walk_sfx():
	play_music(WALK)
