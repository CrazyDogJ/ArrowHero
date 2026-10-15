extends AudioStreamPlayer2D

class_name RandomAudioStreamPlayer

func play_random_sound(audios : Array[AudioStream]):
	var index = RandomGenerator.get_rng_safe("sound").randi_range(0, audios.size() - 1)
	stream = audios.get(index)
	play()
