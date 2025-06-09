extends bosses

var attack1 = true
var attack2 = true
var attack1cd: int = 5
var attack2cd: int = 5
enum boss_attacks {idle, attack1, attack2}
var next_attack = 1
#var next_attack = boss_attacks.attack2

func _physics_process(delta: float) -> void:
	super(delta)
	print("next_attack ", current_state)
	if direction == 1:
		$Attacks/Attack1/CollisionShape2D.position = Vector2(32.5, 12.5)
	else:
		$Attacks/Attack1/CollisionShape2D.position = Vector2(-32.5, 12.5)

func handle_attack():
	
	match next_attack:
		boss_attacks.idle:
			print("idle")
		boss_attacks.attack1:
			if !attack1:
				current_state = boss_state.approach
			else:
				velocity.x = 300 * direction
				if $Attack1Duration.is_stopped():
					$Attack1Duration.start(2)
				$Attacks/Attack1/CollisionShape2D.disabled = false
				
		boss_attacks.attack2:
			if !attack2:
				current_state = boss_state.approach
			else: 
				velocity.x = 300 * direction
				if $Attack2Duration.is_stopped():
					$Attack2Duration.start(0.5)
					print("attack2")

		#boss_attacks.attack3:
			##pangphase 2 siguro
			#print("phase2")

func _on_attack_1_duration_timeout() -> void:
	attack1 = false
	current_state = boss_state.approach
	if $NextAttackTimer.is_stopped():
		$NextAttackTimer.start(2)
	$Attacks/Attack1/CollisionShape2D.disabled = true
	if $Attack1Cooldown.is_stopped():
		$Attack1Cooldown.start(attack1cd)


func _on_attack_1_cooldown_timeout() -> void:
	attack1 = true

func _on_attack_2_duration_timeout() -> void:
	attack2 = false
	current_state = boss_state.approach
	if $NextAttackTimer.is_stopped():
		$NextAttackTimer.start(2)
	if $Attack2Cooldown.is_stopped():
		$Attack2Cooldown.start(attack2cd)

func _on_attack_2_cooldown_timeout() -> void:
	attack2 = true
	
	
	
func get_random_attack():
	var attack_list = boss_attacks.values()
	attack_list.remove_at(0)  # Remove 'idle'
	return attack_list[randi() % attack_list.size()]


func _on_next_attack_timer_timeout() -> void:
	next_attack = get_random_attack()
