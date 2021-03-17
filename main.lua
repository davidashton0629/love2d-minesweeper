local lg = love.graphics
local sw,sh = 550,550
local Neon = require("neon")
local gameOver = Neon:new()
local cell = require("cell")

local Game = {}
Game.board = {}
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
Game.score = 0

function love.load()
	local board = Game.board
	gameOver:addBox("scoreBox"):setData({x = 195, y = 60, w = 160, h = 40, color = {.85,.35,.35,.87}, useBorder = true, borderColor = {0,0,0,1}})
	gameOver:addText("score"):setData({x = 205, y = 70, text = "Score: 0", color = {1,1,1,1}, font = love.graphics.newFont(18)})
	gameOver:disable()
	for x = 25, sw, 25 do
		if not board[x / 25] then Game.board[x / 25] = {} end
		for y = 25, sh, 25 do
			Game.board[x / 25][y / 25] = cell:newCell(x,y,Game)
		end
	end
	
	Neon:registerGlobalEvent("onClick", "box", function(self, target, event)
		self:Uncover()
	end)
	
	Neon:registerGlobalEvent("onRightClick", "box", function(self, target, event)
		if not Game.hitBomb then
			self:setImage("flag"):setImageOffset({5,1})
			self.flagged = true
		end
	end)
	
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
end

function love.keyreleased(key, scancode)
	Neon:keyreleased(key, scancode)
end

function love.mousepressed(x, y, button, istouch, presses)
	Neon:mousepressed(x, y, button, istouch, presses)
	if Game.hitBomb then
		gameOver:enable()
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
