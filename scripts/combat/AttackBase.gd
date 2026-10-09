@abstract class_name AttackBase
extends Node2D

var random: RandomNumberGenerator

func trigger(rng: RandomNumberGenerator) -> void:
	random = rng
	do()

@abstract func do() -> void