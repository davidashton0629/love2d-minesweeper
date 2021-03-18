local Cell = {}
inGame = require("neon"):new()
local Game
local Board

function Cell:newCell(x,y,g)
	if not Game then Game = g end
	if not Board then Board = g.board end
	local c = inGame:addBox("cell" .. "[" .. x .. "]" .. "[" .. y .. "]")
	c:addImage(Game.images.mine, "mine")
	c:addImage(Game.images.flag, "flag")
	
	c:setData({
		x = x - 24, y = y - 24, z = 1,
		width = 23, height = 23,
		color = {.7,.7,.7,1},
		useBorder=true, borderColor={.2,.2,.2,1},
		keepBackground = true,
	})
	
	c.row = x / 25
	c.col = y / 25
	c.bomb = false
	c.revealed = false
	c.flagged = false
	c.data = 0
	
	function c:getAdjacent()
		local adj = {}
		local lastX = #Board
		local lastY = #Board[1]
		
		if self.row > 1 and self.col > 1 then table.insert(adj, Board[self.row - 1][self.col - 1]) end
		if self.row > 1 then table.insert(adj, Board[self.row - 1][self.col]) end
		if self.row > 1 and self.col < lastY then table.insert(adj, Board[self.row - 1][self.col + 1]) end
		if self.col < lastY then table.insert(adj, Board[self.row][self.col + 1]) end
		if self.row < lastX and self.col < lastY then table.insert(adj, Board[self.row + 1][self.col + 1]) end
		if self.row < lastX then table.insert(adj, Board[self.row + 1][self.col]) end
		if self.row < lastX and self.col > 1 then table.insert(adj, Board[self.row + 1][self.col - 1]) end
		if self.col > 1 then table.insert(adj, Board[self.row][self.col - 1]) end

		return adj
	end
	
	function c:getAdjBombs()
		local bombs = {}
		for _,v in ipairs(self:getAdjacent()) do
			if v.bomb then
				table.insert(bombs, v)
			end
		end
		return bombs
	end
	
	function c:Flag()
		if self.revelead then return self.flagged end
		self.flagged = not self.flagged
		return self.flagged
	end
	
	function c:Uncover()
		if self.revealed or Game.hitBomb then return false end
		if self.flagged then 
			self:unsetImage("blank")
			self.flagged = false 
		end
		self.revealed = true
		Game.selectSound:play()
		self:setColor({1,1,1,1})
		if self.bomb then
			self:setImage("mine"):setImageOffset({3,3})
			Game.hitBomb = true
			Game.bombSound:play()
			return true 
		end
		if #self:getAdjBombs() == 0 then
			for _,v in ipairs(self:getAdjacent()) do
				if not v.revealed then v:Uncover() end
			end
		else
			self.data = #self:getAdjBombs()
			local text = inGame:addText("cell[" .. self.row .. "]" .. "[" .. self.col .. "]")
			text:setData({x = self.pos.x + 7, y = self.pos.y + 5, z = 2, text = tostring(self.data), font = Game.normalFont, color = {0,0,0,1}, hollow = true})
			table.insert(Game.boardText, text)
		end
		Game.score = Game.score + math.max(10, (love.timer.getTime() - Game.time) * (love.timer.getTime() / Game.time))
		inGame:child("score", true):setText("Score: " .. tostring(Game.score))
	
		local gameFinished = true
		for _,v in ipairs(Game.boardText) do
			for _,c in ipairs(v) do
				if not v.revealed and not v.bomb then
					gameFinished = false
				end
			end
		end
		if gameFinished then
			for _,v in ipairs(Game.boardText) do
				for _,c in ipairs(v) do
					v.revealed = true
					v:setImage("mine"):setImageOffset({3,3})
				end
			end
		end
		return false
	end
	
	setmetatable(c,c)
	return c
end

return Cell
