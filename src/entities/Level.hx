package entities;

import flash.system.System;
import flash.geom.Point;
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
    public static inline var LEVEL_WIDTH = 40;
    public static inline var LEVEL_HEIGHT = 30;
    public static inline var LEVEL_SCALE = 8;

    private var map:Array<Array<Int>>;
    private var tiles:Tilemap;
    
    public function new()
    {
        super(0, 0);
        map = [for (y in 0...LEVEL_HEIGHT) [for (x in 0...LEVEL_WIDTH) 0]];
        randomizeMap();
        tiles = new Tilemap("graphics/tiles.png", LEVEL_WIDTH*TILE_SIZE, LEVEL_HEIGHT*TILE_SIZE, TILE_SIZE, TILE_SIZE);
        tiles.scale = LEVEL_SCALE;
        /*generateMap();*/
        tiles.loadFrom2DArray(map);
        graphic = tiles;

        var collisionMask:Grid = new Grid(
          LEVEL_SCALE * LEVEL_WIDTH * TILE_SIZE,
          LEVEL_SCALE * LEVEL_HEIGHT * TILE_SIZE,
          LEVEL_SCALE * TILE_SIZE,
          LEVEL_SCALE * TILE_SIZE
        );
        collisionMask.loadFrom2DArray(map);
        mask = collisionMask;
        type = "walls";

        var playerStart:Point = pickRandomOpenPoint();
        HXP.scene.add(new PlayerOne(Math.floor(playerStart.x), Math.floor(playerStart.y)));
        layer = 20;
    }

    public override function update()
    {
      if (Input.pressed(Key.G))
      {
        generateMap();
      }
      if (Input.pressed(Key.R))
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
      super.update();
    }

    public function generateMap()
    {
      randomizeMap();
      cellularAutomata();
      connectAndContainAllRooms();
      while (map[0][0] == 1) {
        openRandomSpace();
      }
      invertMap();
      connectAndContainAllRooms();
      while (map[0][0] == 1) {
        openRandomSpace();
      }
      invertMap();
      connectAndContainAllRooms();
    }

    private function connectAndContainAllRooms()
    {
      createBoundaries();
      var rooms:Array<Array<Int>> = getRooms();
      connectRooms(rooms);
    }

    private function randomizeMap()
    {
      for (x in 0...LEVEL_WIDTH)
      {
        for (y in 0...LEVEL_HEIGHT)
        {
          map[y][x] = Math.round(Math.random() * 0.7);
        }
      }
    }

    private function invertMap()
    {
      for (x in 0...LEVEL_WIDTH)
      {
        for (y in 0...LEVEL_HEIGHT)
        {
          if (map[y][x] == 1) {
            map[y][x] = 0;
          } else {
            map[y][x] = 1;
          }
        }
      }
    }

    private function cellularAutomata()
    {
      for (x in 0...LEVEL_WIDTH)
      {
        for (y in 0...LEVEL_HEIGHT)
        {
          if (emptyNeighbors(x, y, 1) >= 6 + Math.round(Math.random())) {
            map[y][x] = 1;
          } else {
            map[y][x] = 0;
          }
        }
      }
    }

    private function emptyNeighbors(tileX:Int, tileY:Int, radius:Int)
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

    private function isWithinMap(x:Int, y:Int)
    {
      return x >= 0 && y >= 0 && x < LEVEL_WIDTH && y < LEVEL_HEIGHT;
    }

    private function countRooms()
    {
      var roomCount:Int = 0;
      var rooms:Array<Array<Int>> = [for (y in 0...LEVEL_HEIGHT) [for (x in 0...LEVEL_WIDTH) 0]];
      for (x in 0...LEVEL_WIDTH)
      {
        for (y in 0...LEVEL_HEIGHT)
        {
          if (map[y][x] == 0 && rooms[y][x] == 0) {
            roomCount += 1;
            floodFill(x, y, rooms, roomCount);
          }
        }
      }
      return roomCount;
    }

    private function getRooms()
    {
      var roomCount:Int = 0;
      var rooms:Array<Array<Int>> = [for (y in 0...LEVEL_HEIGHT) [for (x in 0...LEVEL_WIDTH) 0]];
      for (x in 0...LEVEL_WIDTH)
      {
        for (y in 0...LEVEL_HEIGHT)
        {
          if (map[y][x] == 0 && rooms[y][x] == 0) {
            roomCount += 1;
            floodFill(x, y, rooms, roomCount);
          }
        }
      }
      return rooms;
    }

    private function openRandomSpace()
    {
      var randomPoint:Point = pickRandomPoint();
      var rooms:Array<Array<Int>> = getRooms();
      while (map[Math.round(randomPoint.y)][Math.round(randomPoint.x)] == 0) {
        randomPoint = pickRandomPoint();
      }
      openRandomSpaceHelper(Math.round(randomPoint.x), Math.round(randomPoint.y));
    }

    private function openRandomSpaceHelper(x:Int, y:Int)
    {
      if (isWithinMap(x, y) && map[y][x] == 1) {
        map[y][x] = 0;
        openRandomSpaceHelper(x + 1, y);
        openRandomSpaceHelper(x - 1, y);
        openRandomSpaceHelper(x, y + 1);
        openRandomSpaceHelper(x, y - 1);
      }
    }

    private function floodFill(x:Int, y:Int, rooms:Array<Array<Int>>, fill:Int)
    {
      if (isWithinMap(x, y) && map[y][x] == 0 && rooms[y][x] == 0) {
        rooms[y][x] = fill;
        floodFill(x + 1, y, rooms, fill);
        floodFill(x - 1, y, rooms, fill);
        floodFill(x, y + 1, rooms, fill);
        floodFill(x, y - 1, rooms, fill);
      }
    }

    private function connectRooms(rooms:Array<Array<Int>>)
    {
      // I should make it so it just picks all the points in one go...!
      var p1:Point = null;
      var p2:Point = null;

      for (x in 0...LEVEL_WIDTH)
      {
        if(p1 != null)
        {
          break;
        }
        for (y in 0...LEVEL_HEIGHT)
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

      for (x in 0...LEVEL_WIDTH)
      {
        if(p2 != null)
        {
          break;
        }
        for (y in 0...LEVEL_HEIGHT)
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
      for (x in 0...LEVEL_WIDTH)
      {
        for (y in 0...LEVEL_HEIGHT)
        {
          if (rooms[y][x] == rooms[Math.round(p1.y)][Math.round(p1.x)]) {
            if (Point.distance(p1, p2) > Point.distance(p2, new Point(x, y))) {
              p1 = new Point(x, y);
            }
          }
        }
      }

      for (x in 0...LEVEL_WIDTH)
      {
        for (y in 0...LEVEL_HEIGHT)
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

      for (x in 0...LEVEL_WIDTH)
      {
        for (y in 0...LEVEL_HEIGHT)
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
      var randomPoint = new Point(Math.floor(Math.random()*LEVEL_WIDTH), Math.floor(Math.random()*LEVEL_HEIGHT));
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
      for (x in 0...LEVEL_WIDTH)
      {
        for (y in 0...LEVEL_HEIGHT)
        {
          if (x == 0 || y == 0 || x == (LEVEL_WIDTH)-1 || y == (LEVEL_HEIGHT)-1) {
            map[y][x] = 1;
          }
        }
      }
    }

}
