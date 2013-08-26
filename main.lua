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

function isOffBoard(player, board) 
  return 
    (player.r <= 0) or (player.r > #board) --NOTE: Assumes a square board
    or (player.c <=0) or (player.c > #board)
end

function Game(players)
  local game = {}
  game.players = {Player(1,1,1,BLUE), Player(BOARD_SIZE, BOARD_SIZE, 5, RED)}
  game.board = makeboard(BOARD_SIZE, EMPTY_TILE)

  --Put a tile in a give place
  function game:place(tile,r,c)
    game.board[r][c] = tile
  end

  --Move players (if possible)
  function game:advance()
    for i=1,#self.players do
      local player = self.players[i]

      if (isOffBoard(player, self.board)) then return end

      local tile = game.board[player.r][player.c]
      if (tile == EMPTY_TILE) then return end

      local togate  = tile[player.gate]
      local newgate = TILE_GATE[togate]
      local newrow = newgate.dr + player.r
      local newcol = newgate.dc + player.c
      local newplayer = Player(newrow, newcol, newgate.dg, player.color)
      print (i, newrow, newcol)

      game.players[i] = newplayer
    end
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
DIAGONAL_TILE = {4,7,6,1,8,3,2,5}  
TILE2 = {4,5,6,7,8,1,2,3}
X_TILE = {5,6,7,8,1,2,3,4}
H_TILE = {6,5,8,7,2,1,4,3} 

CIRCLE_TILE = {3,4,5,6,7,8,1,2} --Problem is that the paths aren't symetric but drawign doesn't tell you which is "in" and which is "out"

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
    local g1 = TILE_GATE[i]
    local g2 = TILE_GATE[tile[i]]
    l1 = display.newLine(g,g1.x,g1.y,g2.x,g2.y)
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

  local fill = player.color
  if (isOffBoard(player,board)) then
    fill = {180,180,180}
  end



  local c = display.newCircle(x,y,PLAYER_SIZE)
  c:setFillColor(fill[1], fill[2], fill[3])
  if (context ~= display) then
    context:insert(c)
  end
end

function drawGame(game) 
  local displayBoard = drawBoard(10,10, game.board,display)
  for i=1,#game.players do
    local player = game.players[i]
    drawPlayer(player,game.board,displayBoard) 
  end
  return displayBoard
end

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )
local game = Game()
drawGame(game)
game:place(H_TILE, 4,4)

game:place(DIAGONAL_TILE,1,1)
game:place(DIAGONAL_TILE,1,2)
game:place(H_TILE,2,1)
local db = drawGame(game)
game:advance()
game:advance()
--game:advance()
db:removeSelf()
db = nil
db = drawGame(game)


