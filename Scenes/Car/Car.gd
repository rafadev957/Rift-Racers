extends Area2D


# definindo o nome de classe para Car
class_name Car 


# definindo valores base
@export var max_speed: float = 380.0 # velocidade maxima base
@export var friction: float = 300.0 # friccao base
@export var aceleration: float = 150.0 # aceleracao maxima base
@export var steer_strength: float = 6.0 # forca de estercamento
@export var min_steer_factor: float = 0.5 # fator de estercamento minimo(ao chegarmos proximo da velocidade maxima)
@export var bounce_time: float = 0.8 # tempo de batida (usuario nao consegue realizar acoes ao bater na pista)
@export var bounce_force: float = 30.0 # forca da batida (forca com que o usuario e lancado para tras ao bater na pista)


# variaveis
var _throttle: float = 0.0 # forca do acelerador
var _steer: float = 0.0 # estercamento (virar para a direita ou esquerda)
var _velocity: float = 0.0 # velocidade total
var _bounce_tween: Tween # interpolacao de salto para animacao dinamica 
var _bounce_target: Vector2 = Vector2.ZERO # alvo de salto (vetor que representa a direcao para onde iremos deslizar ao bater na parede)


# chamado quando o nó entra na árvore de cenas pela primeira vez.
func _ready() -> void:
	pass # Replace with function body.


# chamado a cada frame. 'delta' e o tempo decorrido entre o frame atual e o anterior
func _process(delta: float) -> void:
	_throttle = Input.get_action_strength("ui_up") # pega a forca aplicada pelo usuario na tecla "up"
	_steer = Input.get_axis("ui_left", "ui_right") # pega duas entradas do usuario para o valor positivo e outra para o negativo
	# se as duas telclas estiveres presionadas ((-(1) + 1) = 0) nao aplica forca de rotacao nas rodas


# funcao que calcula a fisica do jogo
func _physics_process(delta: float) -> void:
	aply_throttle(delta)
	aply_rotation(delta)
	position += transform.x * _velocity * delta # calculo para a transforacao do eixo x do carro (move ele em X pixels para frente)


# funcao que valida se estamos precionando o acelerador
func aply_throttle(delta: float) -> void:
	if _throttle > 0.0:
		_velocity += aceleration * delta # se sim: acelera o carro
	else:
		_velocity -= friction * delta # senao: desacelera o carro
	# aplicando funcao de velocidade minima e maxima
	_velocity = clampf(_velocity, 0.0, max_speed) # sem ela nao teria um bloqueio tanto para frente ou para tras


# funcao que calcula o fator de rotacao do carro levando em conta a velocidade dele (gira menos em alta velocidade)
func get_steer_factor() -> float:
	return clampf(
		1.0 - pow(_velocity / max_speed, 2.0),
		min_steer_factor,
		1.0
	) * steer_strength


# funcao que aplica o valor da rotacao ao carro
func aply_rotation(delta: float) -> void:
	rotate(get_steer_factor() * delta * _steer)


func bounce_done() -> void:
		set_physics_process(true) # reabilita o jogador ao carro
		_bounce_tween = null # transforma em nulo / sem valor


# funcao que desabilita modificacoes ao carro
func bounce() -> void:
	set_physics_process(false) # funcao recebe falso -> desabilita
	_velocity = 0.0 # zera a velocidade
	_bounce_target = position + (-transform.x * bounce_force)
	
	if _bounce_tween and _bounce_tween.is_running():
		_bounce_tween.kill() # se a funcao estiver fazendo algo, "mata" ela (para seu funcionamento)
	
	rotation_degrees = fmod(rotation_degrees, 360.0) # pegamos os graus de rotacao atual e o deslocaremos ate 360 graus
	# fmod() -> obtem o resto da divisao de X por Y (X % Y) - 16 % 2 = 0 (resto)
	# o motivo e que estamos prestes a girar na interpolacao
	_bounce_tween = create_tween()
	_bounce_tween.set_parallel() # definicao das coisas em paralelo, ou seja, todas as propriedades do tween funcionaram em paralelo e nao uma a uma
	_bounce_tween.tween_property(self, "position", _bounce_target, bounce_time) # self - proprio NO, estamos modificando a nossa posicao, para ir ao nosso target, por um determinado tempo
	_bounce_tween.tween_property(self, "rotation_degrees", rotation_degrees + 360.0, bounce_time) # self - proprio NO, estamos modificando os nossos graus de rotacao, graus de rotacao + graus extras, por um determinado tempo
	_bounce_tween.set_parallel(false) # setamos o paralelismo para falso, deixando a validacao do termino separado da modificacao
	_bounce_tween.finished.connect(bounce_done) # apos o termino da funcao _bounce_tween, invoca (conecta) a funcao bounce_done (reabilita o jogador ao carro)
	#position += -transform.x * bounce_force # forca o carro a ir para tras
	#await get_tree().create_timer(bounce_time).timeout # await diz ao codigo para parar e guardar este sinal nesta linha, mas nao bloquear o resto do programa
	#set_physics_process(true) # depois de parar aguardar o tempo do bounce_time, voltamos a modificar a fisica do jogo


#
func hit_boundary() -> void:
	bounce()
