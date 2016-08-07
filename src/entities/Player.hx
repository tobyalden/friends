package entities;

import flash.system.System;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.Sfx;
import entities.Level;

class Player extends ActiveEntity
{
    public static inline var GRAVITY = 0.25;
    public static inline var TERMINAL_VELOCITY = 6;
    public static inline var RUN_SPEED = 3.5;
    public static inline var JUMP_POWER = 6;
    public static inline var STANDING_JUMP_SPEED_PERCENTAGE = 0.92;

    public static inline var GAME_START_X = 0;
    public static inline var GAME_START_Y = 0;

    public static inline var HIT_VEL_X = 4;
    public static inline var HIT_VEL_Y = 3;
    public static inline var INVINCIBLITY_DURATION = 50;

    public static inline var MOTHER_VISITATION_TIME= 100;

    public static inline var DEBUG = true;

    private var onGround:Bool;
    private var isSpinJumping:Bool;

    private var walkSfx:Sfx;
    private var jumpSfx:Sfx;
    private var spinJumpSfx:Sfx;
    private var landSfx:Sfx;

    private var invincibleTimer:Int;
    private var stunned:Bool;
    private var isHoldingJump:Bool;

    private var lostInThought:Bool;
    public var motherTimer:Float;

    public function new(x:Int, y:Int)
    {
        this.x = x;
        this.y = y;
        super(x, y);
        setHitbox(12, 32, -10, -16);
        velX = 0;
        velY = 0;
        health = 1;
        onGround = false;
        isSpinJumping = false;
        invincibleTimer = 0;
        stunned = false;
        isHoldingJump = false;
        lostInThought = false;
        motherTimer = 0;
        sprite = new Spritemap("graphics/player.png", 32, 48);
        sprite.add("idle", [0]);
        sprite.add("walk", [6, 7, 8], 12);
        sprite.add("jump", [9]);
        sprite.add("spinjump", [2, 3, 4, 5], 12);
        sprite.add("hit", [2]);
        sprite.add("lost_in_thought", [17]);
        sprite.play("idle");
        graphic = sprite;
        layer = -2550;
        walkSfx = new Sfx("audio/walk.wav");
        jumpSfx = new Sfx("audio/jump.wav");
        spinJumpSfx = new Sfx("audio/spinjump.wav");
        landSfx = new Sfx("audio/land.wav");
        name = "player";
    }

    public override function moveCollideY(e:Entity)
    {
      velY = -0.1;
      return true;
    }

    public override function update()
    {

        if(onGround != isOnGround())
        {
          onGround = isOnGround();
          landSfx.play();
        }

        var enemy = collide('enemy', x, y);

        if(invincibleTimer > 0)
        {
          invincibleTimer -= 1;
          graphic.visible = invincibleTimer % 2 == 0;
        }
        if(!stunned || (invincibleTimer < INVINCIBLITY_DURATION/2 && onGround))
        {
          stunned = false;
          movement();
        }
        else
        {
            velY += GRAVITY;
        }

        moveBy(velX, velY, "walls");

        if(enemy != null)
        {
          hit(10, enemy, 1);
        }

        animate();

        // CAMERA
        scene.camera.x = centerX - HXP.screen.width/2;
        scene.camera.y = centerY - HXP.screen.height/2;

        // SAVING
        if(Input.pressed(Key.ESCAPE))
        {
          System.exit(0);
        }

        // DEBUG
        if(DEBUG)
        {
          if(Input.pressed(Key.W))
          {
            moveBy(0, -HXP.screen.height);
          }
          if(Input.pressed(Key.A))
          {
            moveBy(-HXP.screen.height, 0);
          }
          if(Input.pressed(Key.S))
          {
            moveBy(0, HXP.screen.height);
          }
          if(Input.pressed(Key.D))
          {
            moveBy(HXP.screen.height, 0);
          }
          if(Input.pressed(Key.R))
          {
            x = GAME_START_X;
            y = GAME_START_Y;
          }
          if(Input.pressed(Key.P))
          {
            trace(x + ' ' + y);
          }
          unstuck();
        }

        super.update();
    }

    private function movement()
    {
      // RUNNING
      if (Input.check(Key.LEFT))
      {
        velX = -RUN_SPEED;
        sprite.flipped = true;
      }
      else if (Input.check(Key.RIGHT))
      {
        velX = RUN_SPEED;
        sprite.flipped = false;
      }
      else if(!isSpinJumping)
      {
        velX = 0;
      }

      if(Input.check(Key.RIGHT) || Input.check(Key.LEFT) || !Input.check(Key.DOWN) || !onGround)
      {
        lostInThought = false;
        if(motherTimer > 0)
        {
          motherTimer -= 1;
        }
        if(velX != 0 || velY != 0)
        {
          motherTimer = Math.max(0, motherTimer - 10);
        }
      }
      else
      {
        lostInThought = true;
        isSpinJumping = false;
        spinJumpSfx.stop();
        walkSfx.stop();
        velX = 0;
        if(motherTimer < MOTHER_VISITATION_TIME)
        {
          motherTimer += 1;
        }
      }

      // JUMPING

      if(Input.released(Key.Z))
      {
        isHoldingJump = false;
      }
      if(onGround)
      {
        velY = 0;
        isSpinJumping = false;
        if(Input.pressed(Key.Z))
        {
          isHoldingJump = true;
          velY = -JUMP_POWER;
          jumpSfx.play();
          if((Input.check(Key.RIGHT) || Input.check(Key.LEFT)))
          {
            isSpinJumping = true;
          }
        }
      }
      else
      {

        if(!isSpinJumping)
        {
          velX *= STANDING_JUMP_SPEED_PERCENTAGE;
        }
        velY += GRAVITY;
        velY = Math.min(velY, TERMINAL_VELOCITY);
        velY = Math.max(velY, -TERMINAL_VELOCITY);
      }
    }

    private function hit(damage:Int, enemy:Entity, hitFactor:Int)
    {
      if(invincibleTimer == 0)
      {
        invincibleTimer = INVINCIBLITY_DURATION;
        health -= damage;
        stunned = true;
        if(x < enemy.x)
        {
          velX = -HIT_VEL_X*hitFactor;
        }
        else
        {
          velX = HIT_VEL_X*hitFactor;
        }
        velY = -HIT_VEL_Y*hitFactor;
      }
    }

    private function animate()
    {
      if(invincibleTimer > INVINCIBLITY_DURATION/2)
      {
        sprite.play('hit');
      }
      else if(lostInThought)
      {
        sprite.play('lost_in_thought');
      }
      else if(!onGround)
      {
        walkSfx.stop();
        if(isSpinJumping)
        {
          sprite.play('spinjump');
          if(!spinJumpSfx.playing)
          {
            spinJumpSfx.loop();
          }
        }
        else
        {
          spinJumpSfx.stop();
          sprite.play('jump');
        }
      }
      else if(onGround)
      {
        spinJumpSfx.stop();
        if (velX != 0)
        {
          sprite.play('walk');
          if(!walkSfx.playing)
          {
            walkSfx.loop();
          }
        }
        else
        {
          sprite.play('idle');
          walkSfx.stop();
        }
      }
    }

}
