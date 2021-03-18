local lg = love.graphics
local sw,sh = 550,550
local Neon = require("neon")
local cell = require("cell")

local Game = {}
Game.board = {}
Game.startGame = Neon:new():setZ(1)
Game.gameOver = Neon:new():setZ(3)
Game.boardText = {}
Game.hitBomb = false
Game.colors = {
	{1,1,1,1},
	{1,1,0,1},
	{1,0,0,1},
	{1,0,1,1},
	{0,1,1,1},
	{0,0,1,1},
	{0,1,0,1},
	{0,0,0,1},
	{1,0,0,1}
}
Game.images = {
	mine = love.graphics.newImage("/res/mine.png"),
	flag = love.graphics.newImage("/res/flag.png")
}
Game.bombSound = love.audio.newSource("/res/mine.mp3", "static")
Game.selectSound = love.audio.newSource("/res/cell.mp3", "static")
Game.score = 0
Game.bigFont = love.graphics.newFont(18)
Game.normalFont = love.graphics.newFont(12)
Game.time = 0

function love.load()
	Game.startGame:addBox("background"):addImage(love.graphics.newImage("/res/background.png"), "background", true):setData({w = 540, h = 540, x = 0, y = 0, z = 0, clickable = false})
	
	Game.startGame:addBox("start"):setData({x = 180, y = 190, z = 1, w = 200, h = 50, round = true, radius = 3, color = {.15,.42,1,.6}, useBorder = true, borderColor = {.25,.1,.5,1}})
	Game.startGame:addText("startgame"):setData({x = 226, y = 205, z = 1, color = {.8,.8,.8,1}, clickable = false, font = Game.bigFont, text = "Start Game"})
	Game.startGame:child("start"):registerEvent("onClick", function(self)
		inGame:enable():setZ(2)
		MakeTiles()
		MakeBombs()
		self:getParent():disable()
		Game.time = love.timer.getTime()
	end)
	
	Game.startGame:addBox("quit"):setData({x = 180, y = 290, w = 200, z = 1, h = 50, round = true, radius = 7, color = {.15,.42,1,.6}, useBorder = true, borderColor = {.25,.1,.5,1}})
	Game.startGame:addText("quitgame"):setData({x = 228, y = 305, z = 1, color = {.8,.8,.8,1}, clickable = false, font = Game.bigFont, text = "Quit Game"})
	Game.startGame:child("quit"):registerEvent("onClick", function()
		love.event.quit()
	end)
	
	Game.gameOver:addBox("scoreBox"):setData({x = 195, y = 60, w = 160, h = 40, color = {.85,.35,.35,.87}, useBorder = true, borderColor = {0,0,0,1}})
	Game.gameOver:addText("score"):setData({x = 205, y = 62, w = 140, text = "Score: 0", color = {1,1,1,1}, font = Game.bigFont})
	Game.gameOver:addText("playAgain"):setData({x = 210, y = 83, color = {1,1,1,1}, text = "Press 'R' To Play Again", shadow = true})
	Game.gameOver:disable()
	
	Neon:registerGlobalEvent("onClick", "box", function(self)
		if self.name ~= "start" and self.name ~= "quit" then
			self:Uncover()
		else
			Game.selectSound:play()
		end
	end)
	
	Neon:registerGlobalEvent("onHoverEnter", "box", function(self)
		if self.name == "start" or self.name == "quit" then
			self:animateToColor({.15,.8,1,1}, 2)
			if self.name == "start" then
				Neon:child("startgame"):animateToColor({1,1,1,1})
			else
				Neon:child("quitgame"):animateToColor({1,1,1,1})
			end
		end
	end)
	
	Neon:registerGlobalEvent("onHoverExit", "box", function(self)
		if self.name == "start" or self.name == "quit" then
			self:animateToColor({.15,.42,1,.6}, 2)
			if self.name == "start" then
				Neon:child("startgame"):animateToColor({.8,.8,.8,1}, 2)
			else
				Neon:child("quitgame"):animateToColor({.8,.8,.8,1}, 2)
			end
		end
	end)
	
	Neon:registerGlobalEvent("onRightClick", "box", function(self)
		if self.name ~= "start" and self.name ~= "quit" then
			if not Game.hitBomb then
				self:setImage("flag"):setImageOffset({5,1})
				self.flagged = true
			end
		end
	end)
	inGame:disable()
end

function MakeTiles()
	for x = 25, sw, 25 do
		if not Game.board[x / 25] then Game.board[x / 25] = {} end
		for y = 25, sh, 25 do
			Game.board[x / 25][y / 25] = cell:newCell(x,y,Game)
		end
	end
end

function MakeBombs()
	local bombs = 60
	while (bombs > 0) do
		local row = love.math.random(1, #Game.board)
		local col = love.math.random(1, #Game.board[row])
		local cell = Game.board[row][col]
		if not cell.bomb then
			cell.bomb = true
			bombs = bombs - 1
		end
	end
end

-- Use a single source for love callbacks
function love.update(dt)
	Neon:update(dt)
end

function love.draw()
	lg.setColor(.5,.5,.5,1)
	Neon:draw()
end

function love.keypressed(key,scancode,isrepeat)
	Neon:keypressed(key,scancode,isrepeat)
	if not Game.startGame.enabled then
		if key == "r" then -- reset game
			for k,r in ipairs(Game.board) do
				for i,v in ipairs(r) do -- reset tiles
					Game.board[k][i].revealed = false
					Game.board[k][i].bomb = false
					Game.board[k][i].flagged = false
					Game.board[k][i].image = nil
					Game.board[k][i].data = 0
					Game.board[k][i]:setColor({.7,.7,.7,1})
				end
			end
			for k,r in ipairs(Game.boardText) do -- erase text
				r:disable()
			end
			Game.boardText = {}
			Game.time = love.timer.getTime()
			Game.hitBomb = false
			if not inGame.enabled then
				inGame:enable():setZ(2)
			end
			MakeBombs()
			Game.gameOver:disable()
		end
	end
end

function love.keyreleased(key, scancode)
	Neon:keyreleased(key, scancode)
end

function love.mousepressed(x, y, button, istouch, presses)
	Neon:mousepressed(x, y, button, istouch, presses)
	if Game.hitBomb then
		Game.gameOver:enable()
	end
end

function love.mousereleased(x, y, button, istouch, presses)
	Neon:mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
	Neon:mousemoved(x, y, dx, dy, istouch)
end

-- For mobile
function love.touchpressed(id, x, y, dx, dy, pressure)
	Neon:touchpressed(id, x, y, dx, dy, pressure)
end

function love.touchmoved(id, x, y, dx, dy, pressure)
	Neon:touchmoved(id, x, y, dx, dy, pressure)
end
