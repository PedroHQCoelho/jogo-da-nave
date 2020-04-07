larguraTela = love.graphics.getWidth ()
alturaTela = love.graphics.getHeight ()

anim = require("anim8")

function love.load()
  --Nave--
  imgNave = love.graphics.newImage ("imagens/Nave.png") 
  nave = {
    posx = larguraTela/2;
    posy = alturaTela/2;
    velocidade = 200
  }
  
  --Tiro--
  atira = true 
  delayTiro = 0.5
  tempoAteatirar = delayTiro
  tiros = {}
  imgTiro = love.graphics.newImage ("imagens/Projetil.png")
  
  --Inimigos--
  delayInimigo = 0.4
  tempoCriarinimigo = delayInimigo
  imgInimigo = love.graphics.newImage ("imagens/Inimigo.png")
  inimigos = {}
  
  --Vidas e Pontuação--
  estavivo = true
  pontuacao = 0
  vidas = 5
  gameOver = false
  transparencia = 0
  imgGameOver = love.graphics.newImage ("imagens/GameOver.png")
  
  --Background--
  fundo = love.graphics.newImage ("imagens/Background.png")
  fundoDois = love.graphics.newImage("imagens/Background.png")
  
  planodefundo = {
    x = 0;
    y = 0;
    y2 = 0 - fundo:getHeight();
    vel = 30
  }
  
  --Fonte--
  fonte = love.graphics.newFont ("imagens/FC Barcelona Font 2013 By HD.ttf", 20)
  fonteDois = love.graphics.newFont ("imagens/FC Barcelona Font 2013 By HD.ttf", 30)
  
  --Sons--
  somDoTiro = love.audio.newSource("sons/Tiro.wav", "static")
  explodeNave = love.audio.newSource("sons/ExplodeNave.wav", "static")
  explodeInimigo = love.audio.newSource("sons/ExplodeInimigo.wav", "static")
  musica = love.audio.newSource("sons/Musica.wav")
  somGameOver = love.audio.newSource("sons/GameOver.ogg")
  musica:play()
  musica:setLooping(true)
  
  --Efeito Pontuação--
  scaleX = 1
  scaleY = 1
  
  --Tela de Título--
  abreTela = false
  telaTitulo = love.graphics.newImage ("imagens/ImagemTitulo.png")
  inOutX = 0
  inOutY = 0
  
  --Pausar--
  pausar = false
  
  --Mega Bomba--
	bombavazia = love.graphics.newImage( "imagens/BombaVazia.png" )
	bombacheia = love.graphics.newImage( "imagens/BombaCheia.png" )
	bombacheiaaviso = love.graphics.newImage( "imagens/BombaCheiaAviso.png" )
	explosao = love.graphics.newImage( "imagens/Explosao.png" )
	somexplosao = love.audio.newSource( "sons/Explosao.mp3" )
	
	explodir = {}
	podeexplodir = false
	carregador = 0
	animaaviso = 0.8
	
	local g = anim.newGrid( 192, 192, explosao:getWidth(), explosao:getHeight() )
	animation = anim.newAnimation( g( '1-5', 2, '1-5', 3, '1-5', 4, '1-4', 5 ), 0.09, destroi )
  
  --Destroi Inimigo--
  expInimigo = {}
  destruicaoInimigo = love.graphics.newImage("imagens/ExplosaoInimigo.png")
  expInimigo.x = 0
  expInimigo.y = 0
  local gride = anim.newGrid( 64, 64, destruicaoInimigo:getWidth(), destruicaoInimigo:getHeight() )
  destroiInimigo = anim.newAnimation( gride( '1-5', 1, '1-5', 2, '1-5', 3, '1-5', 4, '1-3', 5 ), 0.01, destroiDois )
  
  end

function love.update(dt)
  if not pausar then
          movimentos(dt)
          atirar(dt)
          inimigo(dt)
          colisoes()
          reset()
          planodefundoscrolling(dt)
          efeito(dt)
          iniciajogo(dt)
          controlaexplosao(dt)
          bombapronta(dt)
          controlaexplosaoInimigo(dt)
        end
        if gameOver then
          fimdejogo(dt)
        end
end

function atirar(dt)
  tempoAteatirar = tempoAteatirar - (1 * dt)
  if tempoAteatirar < 0 then
    atira = true
  end
  
  if estavivo then
  if love.keyboard.isDown ("space") and atira then
    novoTiro = {x = nave.posx, y = nave.posy, img = imgTiro}
    table.insert (tiros, novoTiro)
    somDoTiro:stop()
    somDoTiro:play()
    atira = false
    tempoAteatirar = delayTiro
  end
end

  for i, tiro in ipairs (tiros) do
  tiro.y = tiro.y - (500 * dt)
  if tiro.y < 0 then
    table.remove (tiros, i)
    end
  end
  end

function movimentos(dt)
  if love.keyboard.isDown("right") then
    if nave.posx < (larguraTela - imgNave:getWidth()/2) then
    nave.posx = nave.posx + nave.velocidade * dt
  end
  end
  
  if love.keyboard.isDown("left") then
    if nave.posx > ( 0 + imgNave:getWidth()/2) then
    nave.posx = nave.posx - nave.velocidade * dt
  end
  end
  
  if love.keyboard.isDown("up") then
    if nave.posy > ( 0 + imgNave:getHeight()/2) then
    nave.posy = nave.posy - nave.velocidade * dt
  end
  end
  
  if love.keyboard.isDown("down") then
    if nave.posy < (alturaTela - imgNave:getHeight()/2) then
    nave.posy = nave.posy + nave.velocidade * dt
  end
  end
end


function inimigo(dt)
  tempoCriarinimigo = tempoCriarinimigo - (1 * dt)
  if tempoCriarinimigo < 0 then
    tempoCriarinimigo = delayInimigo
    numeroAleatorio = math.random (10, love.graphics.getWidth() - ((imgInimigo:getWidth()/2) + 10))
    novoInimigo = {x = numeroAleatorio, y = -imgInimigo:getWidth(), img = imgInimigo}
    table.insert (inimigos, novoInimigo)
  end
  
  for i, inimigo in ipairs (inimigos) do
    inimigo.y = inimigo.y + (200 * dt)
    if inimigo.y > 850 then
      table.remove (inimigos, i)
    end
  end
end

function colisoes()
  for i, inimigo in ipairs (inimigos) do
    for j, tiro in ipairs (tiros) do
      if checacolisao (inimigo.x, inimigo.y, imgInimigo:getWidth(), imgInimigo:getHeight(), tiro.x, tiro.y, imgTiro:getWidth(), imgTiro:getHeight()) then
        table.remove (tiros, j)
        expInimigo.x = inimigo.x
        expInimigo.y = inimigo.y
        table.insert(expInimigo, destroiInimigo)
        table.remove (inimigos, i)
        explodeInimigo:stop()
        explodeInimigo:play()
        scaleX = 2;
        scaleY = 2;
        pontuacao = pontuacao + 1
        carregador = carregador + 0.1
        if carregador >= 1 then
          carregador = 1
          podeexplodir = true
        end
      end
    end
    if checacolisao (inimigo.x, inimigo.y, imgInimigo:getWidth(), imgInimigo:getHeight(), nave.posx - (imgNave:getWidth()/2), nave.posy, imgNave:getWidth(), imgNave:getHeight() ) and estavivo then
      table.remove (inimigos, i)
      explodeNave:stop()
      explodeNave:play()
      estavivo = false
      abreTela = false
      vidas = vidas - 1
      if vidas < 0 then
        gameOver = true
        somGameOver:play()
        somGameOver:setLooping(false)
      end
  end
end
end


function checacolisao(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

function reset()
  if not estavivo and inOutY ==0 and love.keyboard.isDown ("return") then
            atira = tempoAteatirar
            tempoCriarinimigo = delayInimigo
            
            nave.posx = larguraTela/2
            nave.posy = alturaTela/2
            
            abreTela = true
          end
end

function planodefundoscrolling(dt)
  planodefundo.y = planodefundo.y + planodefundo.vel * dt
  planodefundo.y2 = planodefundo.y2 + planodefundo.vel * dt
  
  if planodefundo.y > alturaTela then
    planodefundo.y = planodefundo.y2 - fundoDois:getHeight()
  end
  if planodefundo.y2 > alturaTela then
    planodefundo.y2 = planodefundo.y - fundoDois:getHeight()
    end
end

function efeito(dt)
  scaleX = scaleX - 3*dt
  scaleY = scaleY - 3*dt
  
  if scaleX < 1 then
    scaleX = 1
    scaleY = 1
  end
end

function iniciajogo(dt)
  if abreTela and not estavivo then
    inOutX = inOutX + 600 * dt
    if inOutX > 481 then
      inOutY = -701
      inOutX = 0
      estavivo = true
    end
  elseif not abreTela then
    estavivo = false
    inOutY = inOutY + 600* dt
    if inOutY > 0 then
      inOutY = 0
      end
  end
  end
  
  function love.keyreleased(key)
    if key == "p" and abreTela then
      pausar = not pausar
    end
    if pausar then
      love.graphics.setFont(fonte)
      love.graphics.print("PAUSE", larguraTela/2, alturaTela/2)
      musica:pause()
    else
      love.audio.resume(musica)
    end
    if key == "e" and estavivo and not gameOver and podeexplodir then
      novaexplosao = {}
      table.insert(explodir, novaexplosao)
      somexplosao:play()
      carregador = 0
      for i, _ in ipairs(inimigos) do
        pontuacao = pontuacao + 1
      end
      inimigos = {}
      podeexplodir = false
    end
    end
    
    function fimdejogo(dt)
      pausar = true
      musica:stop()
      transparencia = transparencia + 100 * dt
      if love.keyboard.isDown("escape") then
        love.event.quit()
        end
    end
    
    function controlaexplosao(dt)
      for i, _ in ipairs(explodir) do
        animation:update(dt)
      end
    end
    
    function bombapronta(dt)
      animaaviso = animaaviso + 0,5 * dt
      if animaaviso >= 1 then
        animaaviso = 0.8
      end
    end
    
    function destroi()
      for i, _ in ipairs(explodir) do
        table.remove(explodir, i)
      end
    end
    

function love.draw()
  if not gameOver then
  love.graphics.draw (fundo, planodefundo.x, planodefundo.y)
  love.graphics.draw (fundoDois, planodefundo.x, planodefundo.y2)
  
  for i, tiro in ipairs (tiros) do
    love.graphics.draw (tiro.img, tiro.x, tiro.y, 0, 1, 1, imgTiro:getWidth()/2, imgTiro:getHeight())
    if pontuacao > 20 then
        love.graphics.draw (tiro.img, tiro.x - 10, tiro.y + 15, 0, 1, 1, imgTiro:getWidth()/2, imgTiro:getHeight())
        love.graphics.draw (tiro.img, tiro.x + 10, tiro.y + 15, 0, 1, 1, imgTiro:getWidth()/2, imgTiro:getHeight())
        delayTiro = 0.4
        if pontuacao > 50 then
          love.graphics.draw (tiro.img, tiro.x - 20, tiro.y + 30, 0, 1, 1, imgTiro:getWidth()/2, imgTiro:getHeight())
        love.graphics.draw (tiro.img, tiro.x + 20, tiro.y + 30, 0, 1, 1, imgTiro:getWidth()/2, imgTiro:getHeight())
        delayTiro = 0.3
        if pontuacao > 100 then
          delayTiro = 0.2
        end
        end
    end
  end
  
  for i, inimigo in ipairs (inimigos) do
    love.graphics.draw (inimigo.img, inimigo.x, inimigo.y)
  end
  
  for i, _ in ipairs(expInimigo) do
      destroiInimigo:draw(destruicaoInimigo, expInimigo.x, expInimigo.y)
  end
  
  love.graphics.setFont(fonte)
  love.graphics.print("Pontuação:", 10, 10, 0, 1, 1, 0, 2, 0, 0)
  love.graphics.print(pontuacao, 105, 15, 0, scaleX, scaleY, 5, 5, 0, 0)
  love.graphics.print("Vidas:" ..vidas, 400, 15)
  
  		for i, _ in ipairs( explodir ) do
			animation:draw( explosao, larguraTela / 2, alturaTela / 2, 0, 4, 4, 96, 96 )
		end
		love.graphics.draw( bombavazia, larguraTela / 2, 50, 0, 1, 1, bombavazia:getWidth() / 2, bombavazia:getHeight() / 2 )
		love.graphics.draw( bombacheia, larguraTela / 2, 50, 0, carregador, carregador, bombacheia:getWidth() / 2, bombacheia:getHeight() / 2 )
		if podeexplodir then
			love.graphics.draw( bombacheiaaviso, larguraTela / 2, 50, 0, animaaviso, animaaviso, bombacheiaaviso:getWidth() / 2, bombacheiaaviso:getHeight() / 2 )
		end
end
  
  if estavivo then
    love.graphics.draw(imgNave, nave.posx, nave.posy, 0, 1, 1, imgNave:getWidth()/2, imgNave:getHeight()/2)
  elseif gameOver then
    love.graphics.setColor (255, 255, 255, transparencia)
    love.graphics.draw (imgGameOver, 0, 0)
    love.graphics.setFont (fonteDois)
    love.graphics.print("PONTUAÇÃO TOTAL:".. pontuacao, larguraTela/4, 50)
  else
    love.graphics.draw(telaTitulo, inOutX, inOutY)
end
end

function controlaexplosaoInimigo(dt)
    for i, _ in ipairs(expInimigo) do
        destroiInimigo:update(dt)
      end
    end
    
function destroiDois()
    for i, _ in ipairs(expInimigo) do
        table.remove(expInimigo, i)
      end
    end