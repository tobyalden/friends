package entities;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.graphics.*;
import flash.geom.Point;

class PlayerOne extends Entity
{

  public static inline var RUN_SPEED = 0.3 * 1000 * 0.32;
  public static inline var MAX_RUN_SPEED = 0.37 * 1000;
  public static inline var AIR_RUN_SPEED = 0.7 * 1000 * 0.32 / 2;
  public static inline var CLIMB_UP_SPEED = 0.14 * 1000 * 2;
  public static inline var SLIDE_DOWN_SPEED = 0.14 * 1000 * 1.1 * 2;
  public static inline var GRAVITY = 0.0033 * 1000 * 1000 * 1.21;
  public static inline var MAX_FALL_SPEED = 0.18 * 1000 * 2.8;
  public static inline var JUMP_POWER = 0.75 * 1000 * 1.1;
  public static inline var WALL_JUMP_POWER = 0.49 * 1000 * 1;
  public static inline var JUMP_CANCEL_POWER = 0.08 * 1000;

    private var velocity:Point;

    private var sprite:Spritemap;

    public function new(x:Int, y:Int)
    {
        super(x, y);
        sprite = new Spritemap("graphics/player_one.png", 27, 38);
        sprite.add("idle", [0]);
        sprite.play("idle");
        graphic = sprite;
        layer = 10;
        velocity = new Point(0, 0);
        setHitboxTo(graphic);
    }

    public override function update()
    {
        super.update();

        if(Input.check(Key.LEFT))
        {
          if(!isOnGround())
          {
            velocity.x = Math.max(velocity.x - AIR_RUN_SPEED, -MAX_RUN_SPEED);
          }
          else
          {
            velocity.x = Math.max(velocity.x - RUN_SPEED, -MAX_RUN_SPEED);
          }
          sprite.flipped = true;
        }
        else if(Input.check(Key.RIGHT))
        {
          if(!isOnGround())
          {
            velocity.x = Math.min(velocity.x + AIR_RUN_SPEED, MAX_RUN_SPEED);
          }
          else
          {
            velocity.x = Math.min(velocity.x + RUN_SPEED, MAX_RUN_SPEED);
          }
          sprite.flipped = false;
        }
        else
        {
          if(isOnGround())
          {
            velocity.x = 0;
          }
          else
          {
            // TODO: deceleration
          }
        }

        if(isOnWall())
        {
          if(Input.pressed(Key.Z))
          {
              var direction:Int = (isOnRightWall())? -1: 1;
              velocity.x = JUMP_POWER * direction / Math.sqrt(2);
              velocity.y = -JUMP_POWER;
          }
          else if(Input.check(Key.UP))
          {
            velocity.y = -CLIMB_UP_SPEED;
          }
          else if(Input.check(Key.DOWN))
          {
            velocity.y = SLIDE_DOWN_SPEED;
          }
          else
          {
            velocity.y = 0;
          }
        }
        else if(isOnGround())
        {
          velocity.y = 0;
        }
        else
        {
          if(isOnCeiling() && !isOnWall())
          {
            velocity.y = JUMP_CANCEL_POWER/5;
          }
          velocity.y = Math.min(velocity.y + GRAVITY * HXP.elapsed, MAX_FALL_SPEED);
        }

        if(Input.pressed(Key.Z) && isOnGround())
        {
            velocity.y = -JUMP_POWER;
            velocity.x *= 1.2;
        }
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");

        animate();
        playSfx();

        HXP.camera.x = centerX - HXP.width / 2;
        HXP.camera.y = centerY - HXP.height / 2;

        debug();
    }

    private function debug()
    {
      if(Input.pressed(Key.W))
      {
        y -= HXP.screen.height;
      }
      if(Input.pressed(Key.A))
      {
        x -= HXP.screen.width;
      }
      if(Input.pressed(Key.S))
      {
        y += HXP.screen.height;
      }
      if(Input.pressed(Key.D))
      {
        x += HXP.screen.width;
      }
    }

    private function animate()
    {
        /*if(isOnWall() && !isOnGround())
        {
          if(Input.check(Key.UP))
          {
            sprite.play("climb");
          }
          else
          {
            if(sprite.currentAnim != "climb") {
              sprite.play("climb");
            }
              sprite.stop();
          }
        }
        else if(!isOnGround())
        {
            sprite.play("jump");
        }
        else if(velocity.x != 0)
        {
            sprite.play("run");
        }
        else
        {
            sprite.play("idle");
        }*/
    }

    private function playSfx()
    {
      /*if(isInWater && !wasInWater)
      {
        sfx.get("waterland").play();
      }
      if(!wasOnGround && isOnGround() && !isInWater)
      {
        // TODO: If I end up having more than two surface types, refactor into state-machine function
        sfx.get("land").play();
      }
      else if(!wasOnWall && isOnWall() && !isOnGround())
      {
        sfx.get("climbland").play();
      }

      if((Input.check(Key.LEFT) || Input.check(Key.RIGHT)) && isOnGround())
      {
        if(isInWater)
        {
          sfx.get("run").stop();
          if(!sfx.get("waterrun").playing)
          {
            sfx.get("waterrun").loop();
          }
        }
        else if(!sfx.get("run").playing)
        {
          sfx.get("run").loop();
        }
      }
      else
      {
        sfx.get("run").stop();
        sfx.get("waterrun").stop();
      }

      if(Input.check(Key.UP) && isOnWall())
      {
        sfx.get("slide").stop();
        if(!sfx.get("climb").playing)
        {
          sfx.get("climb").loop();
        }
      }
      else if(Input.check(Key.DOWN) && isOnWall() && !isOnGround())
      {
        sfx.get("climb").stop();
        if(!sfx.get("slide").playing)
        {
          sfx.get("slide").loop();
        }
      }
      else
      {
        sfx.get("climb").stop();
        sfx.get("slide").stop();
      }*/
    }

    private function isOnEdge()
    {
      if(isOnWall())
      {
        var tempY = y;
        moveBy(0, -height/2, "walls");
        if(!isOnWall())
        {
          y = tempY;
          return true;
        }
        y = tempY;
      }
      return false;
    }

    /*public override function update()
    {
        if (Input.check(Key.LEFT))
        {
            velX = -5;
        }
        else if (Input.check(Key.RIGHT))
        {
            velX = 5;
        }
        else
        {
          velX = 0;
        }


        if(isOnGround())
        {
          velY = 0;
        }
        else
        {
          velY = Math.min(velY + GRAVITY, TERMINAL_VELOCITY);
        }

        if(Input.pressed(Key.Z))
        {
          if(isOnGround())
          {
            velY -= JUMP_STRENGTH;
          }
        }

        moveBy(velX, velY, "walls");

        HXP.camera.x = x - HXP.screen.width/2;
        HXP.camera.y = y - HXP.screen.height/2;

        super.update();
        unstuck();
    }*/

    public function getPositionOnScreen()
    {
      return new Point(x % HXP.screen.width, y % HXP.screen.height);
    }

    private function unstuck()
    {
        while(collide('walls', x, y) != null)
        {
          moveBy(0, -10);
        }
    }

    private function isOnGround()
    {
        return collide("walls", x, y + 1) != null;
    }

    private function isOnCeiling()
    {
        return collide("walls", x, y - 1) != null;
    }

    private function isOnWall()
    {
        return collide("walls", x - 1, y) != null || collide("walls", x + 1, y) != null;
    }

    private function isOnRightWall()
    {
        return collide("walls", x + 1, y) != null;
    }

    private function isOnLeftWall()
    {
        return collide("walls", x - 1, y) != null;
    }

}
