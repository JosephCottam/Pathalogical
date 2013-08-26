PATH_WIDTH = 4
OUTLINE_WIDTH = 3
TILE_SIZE = 150 
BOARD_SIZE = 4
PLAYER_SIZE = 10
PATH_STRIDE = TILE_SIZE/3
EMPTY_TILE = {1,2,3,4,5,6,7,8}
DIAGONAL_TILE = {4,7,6,1,8,3,2,5}  
TILE2 = {4,5,6,7,8,1,2,3}
X_TILE = {5,6,7,8,1,2,3,4}
H_TILE = {6,5,8,7,2,1,4,3} 
XBAR_TILE = {5,6,8,7,1,2,4,3}
CORNER_TILE = {8,3,2,5,4,7,6,1}
CRESCENT_TILE = {4,3,2,1,8,7,6,5}
FUNNEL_TILE = {4,8,6,1,7,3,5,2}
JOG1_TILE = {5,4,8,2,1,7,6,3}

CIRCLE_TILE = {3,4,5,6,7,8,1,2} --Problem is that the paths aren't symetric but drawign doesn't tell you which is "in" and which is "out"

RED = {200,50,50}
GREEN = {50,200,50}
BLUE = {50,50,200}


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
  game.board = makegrid(BOARD_SIZE, EMPTY_TILE)
  game.ownership = makegrid(BOARD_SIZE, 0)

  --Put a tile in a give place
  function game:place(tile,r,c)
    game.board[r][c] = tile
  end

  --Move players (if possible)
  function game:advance()
    for i=1,#self.players do
      local player = self.players[i]

      if not(isOffBoard(player, self.board)) then 

        local tile = game.board[player.r][player.c]
        if (tile ~= EMPTY_TILE) then 

          local togate  = tile[player.gate]
          local newgate = TILE_GATE[togate]
          local newrow = newgate.dr + player.r
          local newcol = newgate.dc + player.c
          local newplayer = Player(newrow, newcol, newgate.dg, player.color)
          game.ownership[player.r][player.c] = i

          game.players[i] = newplayer
        end
      end
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

TILE_GATE = {Gate(PATH_STRIDE,  0,  -1,0,  6),
             Gate(PATH_STRIDE*2,0,  -1,0,  5),
             Gate(TILE_SIZE, PATH_STRIDE,  0,1,  8), 
             Gate(TILE_SIZE, PATH_STRIDE*2,0,1,  7),
             Gate(PATH_STRIDE*2,TILE_SIZE, 1,0,  2), 
             Gate(PATH_STRIDE, TILE_SIZE,  1,0,  1),
             Gate(0, PATH_STRIDE*2, 0,-1,4), 
             Gate(0, PATH_STRIDE,   0,-1,3)}

function makegrid(size, tile) 
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
  return r 
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

  g.tiles = {}
  for r=1,#board do
    g.tiles[r] = {}
    for c=1,#board[r] do
      xx = (c-1)*TILE_SIZE+feather
      yy = (r-1)*TILE_SIZE+feather
      local tile = drawTile(xx,yy,board[r][c],g)
      g.tiles[r][c] = tile
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

function updateTilesForOwnership(displayBoard, game) 
  for r=1,#game.board do
    for c=1,#game.board do
      local owner = game.ownership[r][c]
      if (owner ~= 0) then
        local tile = displayBoard.tiles[r][c]
        print ("----", tile)
        local color = game.players[owner].color
        tile:setFillColor(color[1]/5, color[2]/5, color[3]/5)
      end
    end
  end
end

function drawGame(game, oldboard) 
  local displayBoard = drawBoard(10,10, game.board,display)
  
  for i=1,#game.players do
    local player = game.players[i]
    drawPlayer(player,game.board,displayBoard) 
  end

  updateTilesForOwnership(displayBoard, game)
  
  if (oldboard ~= nil) then
    oldboard:removeSelf()
    oldboard = nil
  end

  return displayBoard
end

function advanceGame(game, drawnboard, tile, x,y)
  game:place(tile,x,y)
  game:advance()
  return game, drawGame(game, drawnboard)
end

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )
local game = Game()
local db = drawGame(game)

game, db = advanceGame(game, db, DIAGONAL_TILE, 1,1)
game, db = advanceGame(game, db, H_TILE, 4,4)
game, db = advanceGame(game, db, X_TILE, 1,2)
game, db = advanceGame(game, db, X_TILE, 3,4)
game, db = advanceGame(game, db, CRESCENT_TILE, 1,3)
game, db = advanceGame(game, db, JOG1_TILE, 2,4)
game, db = advanceGame(game, db, CORNER_TILE, 2,3)




