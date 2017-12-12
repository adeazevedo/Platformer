
extends KinematicBody2D

export (int) var HP = 3
var current_hp = HP setget set_hp, get_hp

var velocity = Vector2()

enum FACE {RIGHT = 1, LEFT = -1}
var face = RIGHT

var _enemy_group = ""


signal damage_applied
signal die


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

func stagger():
	pass

func idle():
	pass

func die():
	emit_signal("die")
	queue_free()

func apply_dmg(dmg):
	current_hp -= dmg
	emit_signal("damage_applied", dmg)

	if current_hp <= 0:
		die()

func combat_process(enemy):
	if enemy.is_in_group(_enemy_group):
		if self.is_attacking():
			if enemy.is_defending():
				print("Enemy Stagger")
				self.stagger()

			elif enemy.is_breaking_guard():
				# vulnerabily
				print("Enemy Vulnerability")

			else:
				# Apply damage
				print("Apply Damage1")
				var dmg = Combat.calc_dmg(self, enemy)
				enemy.apply_dmg(dmg)
				enemy.stagger()

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
				print("Appley Damage3")
				var dmg = Combat.calc_dmg(enemy, self)
				self.apply_dmg(dmg)
				pass

			elif enemy.is_defending():
				print("Enemy Stagger")
				enemy.stagger()

		else:
			print("Apply Damage2")
			var dmg = Combat.calc_dmg(enemy, self)
			self.apply_dmg(dmg)
			self.stagger()


func get_hp():
	return current_hp

func set_hp(hp):
	current_hp = hp