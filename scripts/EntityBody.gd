
extends KinematicBody2D

export (int) var HP = 3

var velocity = Vector2()

enum FACE {RIGHT = 1, LEFT = -1}
var face = RIGHT

var _enemy_group = ""

func is_attacking():
	pass

func is_defending():
	pass

func is_breaking_guard():
	pass

func attack():
	pass

func defend():
	pass

func break_guard():
	pass

func combat_process(enemy):
	if enemy.is_in_group(_enemy_group):
		if self.is_attacking():
			if enemy.is_defending():
				print("Enemy Stagger")
				self.stagger()

			elif enemy.is_breaking_guard():
				# vulnerabily
				print("Enemy Vulnerability")
				pass

			else:
				# Apply damage
				print("Apply Damage")
				enemy.stagger()
				pass

		elif self.is_defending():
			if enemy.is_attacking():
				print("Enemy Stagger")
				enemy.stagger()

			elif enemy.is_breaking_guard():
				print("Player Stagger")
				self.stagger()


		elif self.is_breaking_guard():
			if enemy.is_attacking():
				# self.vulnerabily
				# self.Apply damage
				print("Player vulnerability")
				pass

			elif enemy.is_defending():
				print("Enemy Stagger")
				enemy.stagger()

		else:
			print("Apply Damage")
			self.stagger()