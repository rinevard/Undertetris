extends AudioStreamPlayer

const BGM = preload("res://assets/music/origin_1.wav")

func play_music(music: AudioStream):
	if stream == music:
		return
	
	stream = music
	play()

func play_music_start():
	play_music(BGM)
