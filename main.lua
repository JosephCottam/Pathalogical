-----------------------------------------------------------------------------------------
--
-- main.lua
--
-- A Tile is a list of mappings
-- Each entry/exit gets an index value
-- and the value tells it which other point to connect to
--
-- A board is a 2D table of tiles (some of which may be nil)
--
-- A player is a 3D coordinate: R,C,gate
--
-----------------------------------------------------------------------------------------
--local pieces = require("pieces")
function Gate(x,y,dr,dc,dg)
  local gate={}
  gate.x = x
  gate.y = y
  gate.dr = dr --delta row (which row direction does this gate connect with)
  gate.dc = dc --delta col (which column direction does this gate connect with)
  gate.dg = dg --delta GATE (which gate does this gate connect with on another tile)
  return gate
end

function Game(players)
  local game = {}
  game.player = Player(4,2,1,BLUE)
  game.board = makeboard(BOARD_SIZE, EMPTY_TILE)

  --Put a tile in a give place
  function game:place(tile,r,c)
    game.board[r][c] = tile
  end

  --Move players (if possible)
  function game:advance()
    local player = self.player
    local gate = TILE_GATE[player.gate]
    local newrow = gate.dr + player.r
    local newcol = gate.dc + player.c

    local offBoard = (newrow <= 0) or (newcol >= #game.board)
                      or (newcol <=0) or (newcol >= #game.board)
    if (offBoard) then return end
    local newtile = game.board[newrow][newcol]
    print("---", newrow, newcol, newtile == EMPTY_TILE)
    if (newtile == EMPTY_TILE) then return end
    print("---", player.r, player.c, newrow, newcol, newtile == EMPTY_TILE)
    
    local newgate = newtile[gate.dg]
    local newplayer = Player(newrow, newcol, newgate, player.color)
    game.player = newplayer
  end

  return game
end

function Player(r,c,gate,color) 
  local player = {}
  player.r = r
  player.c = c
  player.gate = gate
  player.color = color
  return player
end

PATH_WIDTH = 4
OUTLINE_WIDTH = 3
TILE_SIZE = 150 
BOARD_SIZE = 4
PLAYER_SIZE = 10
PATH_STRIDE = TILE_SIZE/3
TILE_GATE = {Gate(PATH_STRIDE,  0,  -1,0,  6),
             Gate(PATH_STRIDE*2,0,  -1,0,  5),
             Gate(TILE_SIZE, PATH_STRIDE,  0,1,  8), 
             Gate(TILE_SIZE, PATH_STRIDE*2,0,1,  7),
             Gate(PATH_STRIDE*2,TILE_SIZE, 1,0,  2), 
             Gate(PATH_STRIDE, TILE_SIZE,  1,0,  1),
             Gate(0, PATH_STRIDE*2, 0,-1,4), 
             Gate(0, PATH_STRIDE,   0,-1,3)}
EMPTY_TILE = {1,2,3,4,5,6,7,8}
CIRCLE_TILE = {3,4,5,6,7,8,1,2}  
TILE2 = {4,5,6,7,8,1,2,3}
X_TILE = {5,6,7,8,1,2,3,4}
H_TILE = {6,5,8,7,2,1,4,3} 

RED = {200,50,50}
GREEN = {50,200,50}
BLUE = {50,50,200}


function makeboard(size, tile) 
  if (tile == nil) then
    tile = EMPTY_TILE
  end

  local board = {}
  for i=1,size do
    board[i] = {}
    for j=1,size do
      board[i][j] = tile
    end
  end
  return board
end

function lineEnds(i1, i2) 
  g1 = TILE_GATE[i1]
  g2 = TILE_GATE[i2]
  return g1.x, g1.y, g2.x, g2.y 
  --return p1,p2
end


function drawTile(x,y, tile, context) 
  local g = display.newGroup()
  if (context ~= display) then
    context:insert(g)
  end

  g.xOrigin =x
  g.yOrigin =y

  local r = display.newRect(g,0,0,TILE_SIZE,TILE_SIZE)
  if (tile == EMPTY_TILE) then
    r.strokeWidth = OUTLINE_WIDTH
    r:setFillColor(40,40,40)
    r:setStrokeColor(60,60,60)
  else 
    r.strokeWidth = OUTLINE_WIDTH
    r:setFillColor(0,0,0)
    r:setStrokeColor(75,20,20)
  end

  for i=1,#tile do
    local a,b,c,d = lineEnds(i,tile[i])
    l1 = display.newLine(g,a,b,c,d)
    l1.width = PATH_WIDTH
  end
end

function drawBoard(x,y,board, context)
  local g = display.newGroup()
  if (context ~= display) then 
    context:insert(g)
  end

  local feather = OUTLINE_WIDTH
  local outline = (TILE_SIZE*#board)+(2*feather)
  local r = display.newRect(x,y,outline,outline)
  r.strokeWidth = OUTLINE_WIDTH*2
  r:setFillColor(0,0,0)
  r:setStrokeColor(100,100,100)
  g.xOrigin = x
  g.yOrigin = y
  r:toBack()

  for r=1,#board do
    for c=1,#board[r] do
      xx = (c-1)*TILE_SIZE+feather
      yy = (r-1)*TILE_SIZE+feather
      drawTile(xx,yy,board[r][c],g)
    end
  end
  return g
end

function drawPlayer(player, board, context)
  local gateloc = TILE_GATE[player.gate]
  local x = ((player.c-1)*TILE_SIZE)+gateloc.x
  local y = ((player.r-1)*TILE_SIZE)+gateloc.y

  local c = display.newCircle(x,y,PLAYER_SIZE)
  c:setFillColor(player.color[1], player.color[2], player.color[3])
  if (context ~= display) then
    context:insert(c)
  end
end

function drawGame(game) 
  local displayBoard = drawBoard(10,10, game.board,display)
  drawPlayer(game.player,board,displayBoard)
end

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )
local game = Game()
drawGame(game)
game:place(H_TILE,1,2)
game:place(H_TILE,2,2)
game:place(H_TILE,3,2)
drawGame(game)
game:advance()
game:advance()
game:advance()
drawGame(game)


