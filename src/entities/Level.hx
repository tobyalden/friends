package entities;

import flash.system.System;
import flash.geom.Point;
import com.haxepunk.Sfx;
import com.haxepunk.Entity;
import com.haxepunk.graphics.*;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.masks.*;
import entities.*;


class Level extends Entity
{

    public static inline var TILE_SIZE = 16;
    public static inline var WORLD_WIDTH = 40;
    public static inline var WORLD_HEIGHT = 30;
    /*public static inline var WORLD_WIDTH = 40 * 7;
    public static inline var WORLD_HEIGHT = 30 * 7;*/

    public static inline var TEMPLE_WIDTH = 40;
    public static inline var TEMPLE_HEIGHT = 30;

    public static inline var LEVEL_SCALE = 8;
    public static inline var TOTAL_SCALE = TILE_SIZE * LEVEL_SCALE;

    public static inline var DECAY_CHANCE = 0.05;
    /*public static inline var DECAY_CHANCE = 1;*/

    private var map:Array<Array<Int>>;
    private var tiles:Tilemap;
    private var collisionMask:Grid;

    public var levelWidth:Int;
    public var levelHeight:Int;

    public var levelType:String;

    public var levelMusic:Sfx;
    public var deathMusic:Sfx;

    public var levelEntities:Array<Entity>;

    public function new(levelWidth:Int, levelHeight:Int, levelType:String)
    {
        super(0, 0);
        this.levelWidth = levelWidth;
        this.levelHeight = levelHeight;
        this.levelType = levelType;
        levelMusic = new Sfx('audio/' + levelType + '-music.wav');
        deathMusic = new Sfx('audio/death-music.wav');
        levelMusic.volume = 0.2;
        levelMusic.play();
        levelEntities = new Array<Entity>();
        map = [for (y in 0...levelHeight) [for (x in 0...levelWidth) 0]];
        generateLevel(levelType);
        finishInitializing();
        layer = -1000;
    }

    public function finishInitializing()
    {
      tiles.scale = LEVEL_SCALE;
      tiles.loadFrom2DArray(map);
      graphic = tiles;

      collisionMask = new Grid(
        LEVEL_SCALE * levelWidth * TILE_SIZE,
        LEVEL_SCALE * levelHeight * TILE_SIZE,
        LEVEL_SCALE * TILE_SIZE,
        LEVEL_SCALE * TILE_SIZE
      );
      collisionMask.loadFrom2DArray(map);
      mask = collisionMask;
      type = "walls";
      layer = 20;
    }

    public override function update()
    {
      var player:Entity = scene.getInstance('player');
      if(cast(player, Player).isDead)
      {
        if(!deathMusic.playing)
        {
          deathMusic.loop();
          levelMusic.stop();
        }
      }
      /*if (Input.pressed(Key.R))
      {
        randomizeMap();
      }
      if (Input.pressed(Key.A))
      {
        cellularAutomata();
      }
      if (Input.pressed(Key.C))
      {
        connectAndContainAllRooms();
      }
      if (Input.pressed(Key.O))
      {
        openRandomSpace();
      }
      if (Input.pressed(Key.I))
      {
        invertMap();
      }
      if (Input.pressed(Key.B))
      {
        createBoundaries();
      }
      if(Input.pressed(Key.ESCAPE))
      {
        System.exit(0);
      }
      tiles.loadFrom2DArray(map);
      collisionMask.loadFrom2DArray(map);*/
      if(Math.random() < DECAY_CHANCE)
      {
        /*randomizeTiles();*/
        switchTiles();
      }
      super.update();
    }

    public function generateLevel(levelType:String)
    {
      if(levelType == "start")
      {
        createBoundaries();
        randomizeMap();
        cellularAutomata();
        mirrorHorizontally();
        mirrorVertically();
        connectAndContainAllRooms();
        createBoundaries();
        openSides();
        tiles = new Tilemap("graphics/start-tiles.png", levelWidth*TILE_SIZE, levelHeight*TILE_SIZE, TILE_SIZE, TILE_SIZE);
        prettifyMap();
      }
      else if(levelType == "default")
      {
        randomizeMap();
        cellularAutomata();
        connectAndContainAllRooms();
        placeSpikes();
        placeEnemies();
        createBoundaries();
        openSides();
        tiles = new Tilemap("graphics/default-tiles.png", levelWidth*TILE_SIZE, levelHeight*TILE_SIZE, TILE_SIZE, TILE_SIZE);
        prettifyMap();
      }
      else if(levelType == "spa")
      {
        randomizeMap();
        mirrorHorizontally();
        connectAndContainAllRooms();
        placeSpikes();
        placeEnemies();
        tiles = new Tilemap("graphics/spa-tiles.png", levelWidth*TILE_SIZE, levelHeight*TILE_SIZE, TILE_SIZE, TILE_SIZE);
        createBoundaries();
        openSides();
        prettifyMap();
      }
      else if(levelType == "tantrum")
      {
        randomizeMap();
        connectAndContainAllRooms();
        coverFloorWithSpikes();
        placeEnemies();
        tiles = new Tilemap("graphics/tantrum-tiles.png", levelWidth*TILE_SIZE, levelHeight*TILE_SIZE, TILE_SIZE, TILE_SIZE);
        createBoundaries();
        openSides();
        prettifyMap();
      }
    }

    public function getPlayer()
    {
      return new Player(Math.round(levelWidth/2 * TOTAL_SCALE - 12), Math.round(levelHeight/2 * TOTAL_SCALE));
    }

    public function mirrorHorizontally()
    {
      for (x in 0...Math.round(levelWidth/2))
      {
        for (y in 0...levelHeight)
        {
          map[y][(levelWidth-1) - x] = map[y][x];
        }
      }
    }

    public function mirrorVertically()
    {
      for (x in 0...levelWidth)
      {
        for (y in 0...Math.floor(levelHeight/2))
        {
          map[(levelHeight-1) - y][x] = map[y][x];
        }
      }
    }

    public function prettifyMap()
    {
      var count:Int = 0;
      for (x in 0...levelWidth)
      {
        for (y in 0...levelHeight)
        {
          if(map[y][x] != 0)
          {
            /*map[y][x] = Math.floor(Math.random() * tiles.tileCount);*/
            map[y][x] = count;
            count++;
            if(count > tiles.tileCount)
            {
              count = 0;
            }
          }
        }
      }
      tiles.loadFrom2DArray(map);
    }

    public function randomizeTiles()
    {
      for (x in 0...levelWidth)
      {
        for (y in 0...levelHeight)
        {
          if(map[y][x] != 0)
          {
            var tile:Int = Math.floor(Math.random() * tiles.tileCount);
            if(tile == 0)
            {
              /*Math.floor(Math.random() * tiles.tileCount);*/
              tile = 1;
            }
            map[y][x] = tile;
          }
        }
      }
      tiles.loadFrom2DArray(map);
    }

    public function switchTiles()
    {
      var point1:Point = pickRandomPoint();
      var point2:Point = pickRandomPoint();
      map[Math.round(point1.y)][Math.round(point1.x)] = map[Math.round(point2.y)][Math.round(point2.x)];
      map[Math.round(point2.y)][Math.round(point2.x)] = map[Math.round(point1.y)][Math.round(point1.x)];
      tiles.loadFrom2DArray(map);
      collisionMask.loadFrom2DArray(map);
    }

    public function placeEnemies()
    {
      if(levelType == "default")
      {
        for(i in 0...30)
        {
          var openPoint:Point = pickRandomOpenPoint();
          levelEntities.push(new Hopper(openPoint.x * TILE_SIZE * LEVEL_SCALE, openPoint.y * TILE_SIZE * LEVEL_SCALE));
        }
        for(i in 0...10)
        {
          var openPoint:Point = pickRandomOpenPoint();
          levelEntities.push(new Brute(openPoint.x * TILE_SIZE * LEVEL_SCALE, openPoint.y * TILE_SIZE * LEVEL_SCALE));
        }
      }
      else if(levelType == "spa")
      {
        for(i in 0...20)
        {
          var openPoint:Point = pickRandomOpenPoint();
          levelEntities.push(new PinkBrother(openPoint.x * TILE_SIZE * LEVEL_SCALE, openPoint.y * TILE_SIZE * LEVEL_SCALE));
        }
      }
      else if(levelType == "tantrum")
      {
        /*for(i in 0...10)
        {
          var openPoint:Point = pickRandomOpenPoint();
          levelEntities.push(new LustDemon(openPoint.x * TILE_SIZE * LEVEL_SCALE, openPoint.y * TILE_SIZE * LEVEL_SCALE));
        }*/
      }
    }

    public function connectAndContainAllRooms()
    {
      createBoundaries();
      var rooms:Array<Array<Int>> = getRooms();
      connectRooms(rooms);
    }

    public function placeSpikes()
    {
      var spikeChance:Float = 1;
      var spikes:Array<Spike> = new Array<Spike>();
      for (x in 0...levelWidth)
      {
        for (y in 0...levelHeight)
        {
          if(map[y][x] == 1 && Math.random() < 0.5 * spikeChance)
          {
            if(isWithinMap(x + 1, y) && map[y][x + 1] == 0 && Math.random() < 0.5 * spikeChance)
            {
              spikes.push(new Spike((x + 1) * TILE_SIZE * LEVEL_SCALE, y * TILE_SIZE * LEVEL_SCALE, "leftwall"));
            }
            if(isWithinMap(x - 1, y) && map[y][x - 1] == 0 && Math.random() < 0.5 * spikeChance)
            {
              spikes.push(new Spike((x - 1) * TILE_SIZE * LEVEL_SCALE, y * TILE_SIZE * LEVEL_SCALE, "rightwall"));
            }
            if(isWithinMap(x, y - 1) && map[y - 1][x] == 0 && Math.random() < 0.75 * spikeChance)
            {
              spikes.push(new Spike(x * TILE_SIZE * LEVEL_SCALE, (y - 1) * TILE_SIZE * LEVEL_SCALE, "floor"));
            }
            if(isWithinMap(x, y + 1) && map[y + 1][x] == 0 && Math.random() < 0.25 * spikeChance)
            {
              spikes.push(new Spike(x * TILE_SIZE * LEVEL_SCALE, (y + 1) * TILE_SIZE * LEVEL_SCALE, "ceiling"));
            }
          }
        }
      }

      for(spike in spikes)
      {
        // Prevent there from being impassable ceiling/floor combos
        for(spike2 in spikes)
        {
          if(spike.x == spike2.x && spike.y == spike2.y && spike.orientation == "floor" && spike2.orientation == "ceiling")
          {
              spikes.remove(spike);
          }
        }
      }

      for(spike in spikes)
      {
        levelEntities.push(spike);
      }

    }

    public function coverFloorWithSpikes()
    {
      for (x in 0...levelWidth)
      {
        for (y in 0...levelHeight)
        {
          if(map[y][x] == 1 && isWithinMap(x, y - 1) && map[y - 1][x] == 0)
          {
            levelEntities.push(new Spike(x * TILE_SIZE * LEVEL_SCALE, (y - 1) * TILE_SIZE * LEVEL_SCALE, "floor"));
          }
        }
      }
    }

    public function emptyMap()
    {
      map = [for (y in 0...levelHeight) [for (x in 0...levelWidth) 0]];
    }

    public function randomizeMap()
    {
      for (x in 0...levelWidth)
      {
        for (y in 0...levelHeight)
        {
          map[y][x] = Math.round(Math.random() * 0.7);
        }
      }
    }

    public function invertMap()
    {
      for (x in 0...levelWidth)
      {
        for (y in 0...levelHeight)
        {
          if (map[y][x] == 1) {
            map[y][x] = 0;
          } else {
            map[y][x] = 1;
          }
        }
      }
    }

    public function cellularAutomata()
    {
      for (x in 0...levelWidth)
      {
        for (y in 0...levelHeight)
        {
          if (emptyNeighbors(x, y, 1) >= 6 + Math.round(Math.random())) {
            map[y][x] = 1;
          } else {
            map[y][x] = 0;
          }
        }
      }
    }

    public function emptyNeighbors(tileX:Int, tileY:Int, radius:Int)
    {
      var emptyNeighbors:Int = 0;
      var x:Int = tileX - radius;
      while (x <= tileX + radius)
      {
        var y:Int = tileY - radius;
        while (y <= tileY + radius)
        {
          if (isWithinMap(x, y) && map[y][x] == 0) {
            emptyNeighbors += 1;
          }
          y += 1;
        }
        x += 1;
      }
      return emptyNeighbors;
    }

    public function isWithinMap(x:Int, y:Int)
    {
      return x >= 0 && y >= 0 && x < levelWidth && y < levelHeight;
    }

    public function countRooms()
    {
      var roomCount:Int = 0;
      var rooms:Array<Array<Int>> = [for (y in 0...levelHeight) [for (x in 0...levelWidth) 0]];
      for (x in 0...levelWidth)
      {
        for (y in 0...levelHeight)
        {
          if (map[y][x] == 0 && rooms[y][x] == 0) {
            roomCount += 1;
            floodFill(x, y, rooms, roomCount);
          }
        }
      }
      return roomCount;
    }

    public function openSides()
    {
      for (x in 0...levelWidth)
      {
        for (y in 0...levelHeight)
        {
          if ((x == 0 || x == levelWidth-1) && y == levelHeight/2)
          {
            var digX:Int = x;
            while(map[y][digX] != 0)
            {
              map[y][digX] = 0;
              if(x == 0)
              {
                digX++;
              }
              else if (x == levelWidth-1) {
                digX--;
              }
            }
          }
          else if ((y == 0 || y == levelHeight-1) && x == levelWidth/2)
          {
            var digY:Int = y;
            while(map[digY][x] != 0)
            {
              map[digY][x] = 0;
              if(y == 0)
              {
                digY++;
              }
              else if (y == levelHeight-1) {
                digY--;
              }
            }
          }
        }
      }
      placeExits();
    }

    private function placeExits()
    {
      // ((x == 0 || x == levelWidth-1) && y == levelHeight/2
      var leftExit:Exit = new Exit(-TOTAL_SCALE, levelHeight/2 * TOTAL_SCALE, "left");
      var rightExit:Exit = new Exit((levelWidth-1) * TOTAL_SCALE + TOTAL_SCALE, levelHeight/2 * TOTAL_SCALE, "right");
      var topExit:Exit = new Exit(levelWidth/2 * TOTAL_SCALE, -TOTAL_SCALE, "top");
      var bottomExit:Exit = new Exit(levelWidth/2 * TOTAL_SCALE, (levelHeight-1) * TOTAL_SCALE + TOTAL_SCALE, "bottom");
      levelEntities.push(leftExit);
      levelEntities.push(rightExit);
      levelEntities.push(topExit);
      levelEntities.push(bottomExit);
    }

    public function getRooms()
    {
      var roomCount:Int = 0;
      var rooms:Array<Array<Int>> = [for (y in 0...levelHeight) [for (x in 0...levelWidth) 0]];
      for (x in 0...levelWidth)
      {
        for (y in 0...levelHeight)
        {
          if (map[y][x] == 0 && rooms[y][x] == 0) {
            roomCount += 1;
            floodFill(x, y, rooms, roomCount);
          }
        }
      }
      return rooms;
    }

    public function openRandomSpace()
    {
      var randomPoint:Point = pickRandomPoint();
      var rooms:Array<Array<Int>> = getRooms();
      while (map[Math.round(randomPoint.y)][Math.round(randomPoint.x)] == 0) {
        randomPoint = pickRandomPoint();
      }
      openRandomSpaceHelper(Math.round(randomPoint.x), Math.round(randomPoint.y));
    }

    public function openRandomSpaceHelper(x:Int, y:Int)
    {
      if (isWithinMap(x, y) && map[y][x] == 1) {
        map[y][x] = 0;
        openRandomSpaceHelper(x + 1, y);
        openRandomSpaceHelper(x - 1, y);
        openRandomSpaceHelper(x, y + 1);
        openRandomSpaceHelper(x, y - 1);
      }
    }

    public function floodFill(x:Int, y:Int, rooms:Array<Array<Int>>, fill:Int)
    {
      if (isWithinMap(x, y) && map[y][x] == 0 && rooms[y][x] == 0) {
        rooms[y][x] = fill;
        floodFill(x + 1, y, rooms, fill);
        floodFill(x - 1, y, rooms, fill);
        floodFill(x, y + 1, rooms, fill);
        floodFill(x, y - 1, rooms, fill);
      }
    }

    public function connectRooms(rooms:Array<Array<Int>>)
    {
      // I should make it so it just picks all the points in one go...!
      var p1:Point = null;
      var p2:Point = null;

      for (x in 0...levelWidth)
      {
        if(p1 != null)
        {
          break;
        }
        for (y in 0...levelHeight)
        {
          if(rooms[y][x] != 0)
          {
            p1 = new Point(x, y);
            break;
          }
        }
      }

      if(p1 == null)
      {
          return;
      }

      for (x in 0...levelWidth)
      {
        if(p2 != null)
        {
          break;
        }
        for (y in 0...levelHeight)
        {
          if(rooms[y][x] != 0 && rooms[y][x] != rooms[Math.round(p1.y)][Math.round(p1.x)])
          {
            p2 = new Point(x, y);
            break;
          }
        }
      }

      if(p2 == null)
      {
          return;
      }

      var p1Start:Point = p1.clone();
      var p2Start:Point = p2.clone();

      // Get P2 and P2 as close as possible to each other as possible without leaving the rooms they're in
      for (x in 0...levelWidth)
      {
        for (y in 0...levelHeight)
        {
          if (rooms[y][x] == rooms[Math.round(p1.y)][Math.round(p1.x)]) {
            if (Point.distance(p1, p2) > Point.distance(p2, new Point(x, y))) {
              p1 = new Point(x, y);
            }
          }
        }
      }

      for (x in 0...levelWidth)
      {
        for (y in 0...levelHeight)
        {
          if (rooms[y][x] == rooms[Math.round(p2.y)][Math.round(p2.x)]) {
            if (Point.distance(p1, p2) > Point.distance(p1, new Point(x, y))) {
              p2 = new Point(x, y);
            }
          }
        }
      }

      // Dig a tunnel between the two points
      var pDig:Point = new Point(p1.x, p1.y);
      pDig = movePointTowardsPoint(pDig, p2);
      while (!pDig.equals(p2))
      {
        map[Math.round(pDig.y)][Math.round(pDig.x)] = 0;
        pDig = movePointTowardsPoint(pDig, p2);
      }

      for (x in 0...levelWidth)
      {
        for (y in 0...levelHeight)
        {
          if(rooms[y][x] == rooms[Math.round(p2Start.y)][Math.round(p2Start.x)])
          {
            rooms[y][x] = rooms[Math.round(p1Start.y)][Math.round(p1Start.x)];
          }
        }
      }

      connectRooms(rooms);
    }

    public function movePointTowardsPoint(movePoint:Point, towardsPoint:Point)
    {
      if (movePoint.x < towardsPoint.x) {
        movePoint.x = movePoint.x + 1;
      } else if (movePoint.x > towardsPoint.x) {
        movePoint.x = movePoint.x - 1;
      } else if (movePoint.y < towardsPoint.y) {
        movePoint.y = movePoint.y + 1;
      } else if (movePoint.y > towardsPoint.y) {
        movePoint.y = movePoint.y - 1;
      }
      return movePoint;
    }

    public function pickRandomPoint()
    {
      var randomPoint = new Point(Math.floor(Math.random()*levelWidth), Math.floor(Math.random()*levelHeight));
      return randomPoint;
    }

    public function pickRandomOpenPoint()
    {
      var randomOpenPoint:Point = pickRandomPoint();
      while(map[Math.round(randomOpenPoint.y)][Math.round(randomOpenPoint.x)] != 0)
      {
        randomOpenPoint = pickRandomPoint();
      }
      return randomOpenPoint;
    }

    public function createBoundaries()
    {
      for (x in 0...levelWidth)
      {
        for (y in 0...levelHeight)
        {
          if (x == 0 || y == 0 || x == (levelWidth)-1 || y == (levelHeight)-1) {
            map[y][x] = 1;
          }
        }
      }
    }

    public function getMap()
    {
      return map;
    }

}
