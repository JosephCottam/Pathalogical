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
PATH_WIDTH = 4
OUTLINE_WIDTH = 3
TILE_SIZE = 150 
BOARD_SIZE = 4
PLAYER_SIZE = 10
PATH_STRIDE = TILE_SIZE/3
TILE_GATE = {{PATH_STRIDE,0},{PATH_STRIDE*2,0},
               {TILE_SIZE, PATH_STRIDE}, {TILE_SIZE, PATH_STRIDE*2},
               {PATH_STRIDE*2,TILE_SIZE}, {PATH_STRIDE, TILE_SIZE},
               {0, PATH_STRIDE*2}, {0, PATH_STRIDE}}
EMPTY_TILE = {1,2,3,4,5,6,7,8}
TILE1 = {3,4,5,6,7,8,1,2}
TILE2 = {4,5,6,7,8,1,2,3}
TILE3 = {5,6,7,8,1,2,3,4}

RED = {200,50,50}
GREEN = {50,200,50}
BLUE = {50,50,200}

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

function Player(r,c,gate,color) 
  local player = {}
  player.r = r
  player.c = c
  player.gate = gate
  player.color = color
  return player
end

function Game(players)
  local game = {}
  game.player = Player(2,2,5,BLUE)
  game.board = makeboard(BOARD_SIZE, EMPTY_TILE)
  return game
end

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
  p1 = TILE_GATE[i1]
  p2 = TILE_GATE[i2]
  return p1[1],p1[2],p2[1],p2[2]
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
      xx = (r-1)*TILE_SIZE+feather
      yy = (c-1)*TILE_SIZE+feather
      drawTile(xx,yy,board[r][c],g)
    end
  end
  return g
end

function drawPlayer(player, board, context)
  local gateloc = TILE_GATE[player.gate]
  local x = ((player.r-1)*TILE_SIZE)+gateloc[1]
  local y = ((player.c-1)*TILE_SIZE)+gateloc[2]

  local c = display.newCircle(x,y,PLAYER_SIZE)
  c:setFillColor(player.color[1], player.color[2], player.color[3])
  if (context ~= display) then
    context:insert(c)
  end
end
--drawTile(10,10, TILE1, display)
--drawTile(10,500, TILE2, display)
--drawTile(10,200, EMPTY_TILE, display)

function drawGame(game) 
  local displayBoard = drawBoard(10,10, game.board,display)
  drawPlayer(game.player,board,displayBoard)
end

drawGame(Game())
