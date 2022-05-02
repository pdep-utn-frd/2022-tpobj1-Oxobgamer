import wollok.game.*
    
const velocidad = 250

object juego{

	method configurar(){
		game.cellSize(25)
		game.width(24)
		game.height(16)
		game.title("Dino Game")
		game.addVisual(suelo)
		game.addVisual(cactus)
		game.addVisual(dino)
		game.addVisual(reloj)
		game.addVisual(fuego)
		
		keyboard.space().onPressDo{ self.jugar()}
		
		game.onCollideDo(dino,{ obstaculo => obstaculo.chocar(dino.estado())})
		
	} 
	
	method    iniciar(){
		dino.iniciar()
		reloj.iniciar()
		cactus.iniciar()
		fuego.iniciar()
	}
	
	method jugar(){
		if (dino.estaVivo()) 
			cactus.saltar()
		else {
			game.removeVisual(gameOver)
			self.iniciar()
		}
		
	}
	
	method terminar(){
		game.addVisual(gameOver)
		cactus.detener()
		reloj.detener()
		fuego.detener()
		dino.morir()
	}
	
}

object gameOver {
	method position() = game.center()
	method text() = "GAME OVER"
	

}

object reloj {
	
	var tiempo = 0
	
	method text() = tiempo.toString()
	method position() = game.at(1, game.height()-2)
	
	method pasarTiempo() {
		tiempo = tiempo +1
	}
	method iniciar(){
		tiempo = 0
		game.onTick(100,"tiempo",{self.pasarTiempo()})
	}
	method detener(){
		game.removeTickEvent("tiempo")
	}
}

object cactus {
	 
	const posicionInicial = game.at(game.width()-1,suelo.position().y())
	var position = posicionInicial

	method image() = "cactus.png"
	method position() = position
	
	method iniciar(){
		position = posicionInicial
		game.onTick(velocidad/2,"moverCactus",{self.mover()})
	}
	
	method mover(){
		position = position.left(1)
		if (position.x() == -1)
			position = posicionInicial
	}
	method saltar(){
		if(position.y() == suelo.position().y()) {
			self.subir()
			game.schedule(velocidad*3,{self.bajar()})
		}
	}
	method subir(){
		position = position.up(2)
	}
	
	method bajar(){
		if (position.y() > suelo.position().y()) position = position.down(2)
	}
	method chocar(estado){
		if (estado == 1) {
			juego.terminar()	
		}
		else if (estado == 2 || estado == 3) {
			position = posicionInicial
		}
	}
    method detener(){
		game.removeTickEvent("moverCactus")
	}
}

object suelo{
	
	method position() = game.origin().up(1)
	
	method image() = "suelo.png"
}

object fuego {
	const posicionInicial = game.at(game.width()+100,suelo.position().y())
	var position = posicionInicial
	method image() = "fuego.png"
	method chocar(valor){
		dino.cambiarEstado(2)
		game.schedule(velocidad*45,{
			dino.cambiarEstado(3)
			game.schedule(velocidad*5,{
				dino.cambiarEstado(1)
			})
		})
	}
	method position() = position
	method iniciar(){
		position = posicionInicial
		game.onTick(velocidad,"moverFuego",{self.mover()})
	}
	
	method mover(){
		position = position.left(1)
		if (position.x() == -1)
			position = posicionInicial
	}
	method detener(){
		game.removeTickEvent("moverFuego")
	}
}

object dino {
	var vivo = true
	var estado = 1
	var position = game.at(6,suelo.position().y())
	var imagen = "dino.png"
	
	method image() = imagen
	method position() = position
	method estado() = estado
	method cambiarEstado(valor) {
		estado = valor
		if (valor == 1) imagen = "dino.png"
		else if (valor == 2) imagen = "dino2.png"
		else if (valor == 3) imagen = "dino3.png"
	}
	
	method morir(){
		game.say(self,"¡Auch!")
		vivo = false
	}
	method iniciar() {
		vivo = true
	}
	method estaVivo() {
		return vivo
	}
}