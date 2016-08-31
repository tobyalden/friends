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
import scenes.GameScene;

class Player extends ActiveEntity
{
    public static inline var NIGHTCORE = 1.1;

    public static inline var GRAVITY = 0.3 * NIGHTCORE;
    public static inline var TERMINAL_VELOCITY = 6 * NIGHTCORE;
    public static inline var RUN_SPEED = 3.5 * NIGHTCORE;
    public static inline var JUMP_POWER = 6.3 * NIGHTCORE;
    public static inline var JUMP_CANCEL_POWER = JUMP_POWER/2;
    public static inline var WALL_JUMP_POWER = 6 / 1.414 * NIGHTCORE;
    public static inline var STANDING_JUMP_SPEED_PERCENTAGE = 0.92 * NIGHTCORE;

    public static inline var CLIMB_UP_SPEED = 3.5 * NIGHTCORE;
    public static inline var SLIDE_DOWN_SPEED = 4 * NIGHTCORE;
    public static inline var CEILING_CLIMB_SPEED = 3.5 * NIGHTCORE;


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
    private var ceilingClimbSfx:Sfx;
    private var wallClimbSfx:Sfx;
    private var damageSfx:Sfx;

    private var canDoubleJump:Bool;

    private var invincibleTimer:Int;

    private var stunned:Bool;
    private var lostInThought:Bool;
    public var isDead:Bool;

    public function new(x:Int, y:Int)
    {
        this.x = x;
        this.y = y;
        super(x, y);
        setHitbox(12, 32, -10, -16);
        velX = 0;
        velY = 0;
        health = 100;
        onGround = false;
        isDead = false;
        isSpinJumping = false;
        canDoubleJump = false;
        invincibleTimer = 0;
        stunned = false;
        sprite = new Spritemap("graphics/player.png", 32, 48);
        sprite.add("idle", [0]);
        sprite.add("walk", [6, 7, 8], 12);
        sprite.add("jump", [9]);
        sprite.add("spinjump", [2, 3, 4, 5], 12);
        sprite.add("hit", [2]);
        sprite.add("hang", [10]);
        sprite.add("climb", [10, 11], 8);
        sprite.add("ceiling-hang", [12]);
        sprite.add("ceiling-climb", [12, 13], 8);
        sprite.add("dead", [14]);
        sprite.play("idle");
        graphic = sprite;
        layer = -2550;
        walkSfx = new Sfx("audio/walk.wav");
        jumpSfx = new Sfx("audio/jump.wav");
        spinJumpSfx = new Sfx("audio/spinjump.wav");
        landSfx = new Sfx("audio/land.wav");
        wallClimbSfx = new Sfx("audio/wallclimb.wav");
        ceilingClimbSfx = new Sfx("audio/ceilingclimb.wav");
        damageSfx = new Sfx("audio/damage.wav");
        name = "player";
    }

    public override function moveCollideY(e:Entity)
    {
      velY = -0.1;
      return true;
    }

    public function stopAllSfx()
    {
      walkSfx.stop();
      spinJumpSfx.stop();
      ceilingClimbSfx.stop();
      wallClimbSfx.stop();
    }

    public override function update()
    {

        if(Input.pressed(Key.ESCAPE))
        {
          System.exit(0);
        }

        if(isDead)
        {
          stopAllSfx();
          sprite.play('dead');
          return;
        }
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

        var exit = collide('exit', x, y);
        if(exit != null)
        {
          cast(HXP.scene, GameScene).nextLevel(cast(exit, Exit).exitDirection);
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

      // JUMPING

      if(!onGround && canDoubleJump)
      {
        if(Input.pressed(Key.Z))
        {
          velY = -JUMP_POWER;
          jumpSfx.play();
          canDoubleJump = false;
        }
      }
      if(onGround)
      {
        canDoubleJump = true;
        velY = 0;
        isSpinJumping = false;
        if(Input.pressed(Key.Z))
        {
          velY = -JUMP_POWER;
          jumpSfx.play();
          if((Input.check(Key.RIGHT) || Input.check(Key.LEFT)))
          {
            isSpinJumping = true;
          }
        }
      }
      else if(isOnWall())
      {
        canDoubleJump = true;
        isSpinJumping = false;
        if(Input.pressed(Key.Z))
        {
          var direction:Int = (isOnRightWall())? -1: 1;
          velX = WALL_JUMP_POWER * direction;
          velY = -WALL_JUMP_POWER;
          isSpinJumping = true;
          sprite.flipped = !sprite.flipped;
        }
        else if(Input.check(Key.UP))
        {
          velY = -CLIMB_UP_SPEED;
        }
        else if(Input.check(Key.DOWN))
        {
          velY = SLIDE_DOWN_SPEED;
        }
        else
        {
          velY = 0;
        }
      }
      else if(isOnCeiling() && Input.check(Key.Z))
      {
        canDoubleJump = true;
        isSpinJumping = false;
        if(!Input.check(Key.Z))
        {
          y += 1;
        }
        else if(Input.check(Key.LEFT))
        {
          if(collide("walls", x - CEILING_CLIMB_SPEED, y - 1) != null)
          {
            velX = -CEILING_CLIMB_SPEED;
          }
          else
          {
            velX = 0;
          }
        }
        else if(Input.check(Key.RIGHT))
        {
          if(collide("walls", x + CEILING_CLIMB_SPEED, y - 1) != null)
          {
            velX = CEILING_CLIMB_SPEED;
          }
          else
          {
            velX = 0;
          }
        }
        else
        {
          velX = 0;
        }
      }
      else
      {
        if(Input.released(Key.Z) && !isSpinJumping)
        {
          if(velY < -JUMP_CANCEL_POWER)
          {
            velY = -JUMP_CANCEL_POWER;
          }
        }
        if(!isSpinJumping)
        {
          velX *= STANDING_JUMP_SPEED_PERCENTAGE;
        }
        velY += GRAVITY;
        velY = Math.min(velY, TERMINAL_VELOCITY);
        velY = Math.max(velY, -TERMINAL_VELOCITY);
      }
    }

    private function hit(damageAmount:Int, enemy:Entity, hitFactor:Int)
    {
      if(invincibleTimer == 0)
      {
        invincibleTimer = INVINCIBLITY_DURATION;
        damage(damageAmount);
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

    override public function damage(damage:Int)
    {
      if(!invincible)
      {
        health -= damage;
        damageSfx.play();
        if(health <= 0)
        {
          isDead = true;
        }
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

        if(isOnWall())
        {
          if(velY < 0)
          {
            sprite.play('climb');
            if(!wallClimbSfx.playing)
            {
              wallClimbSfx.loop();
            }
          }
          else
          {
            sprite.play('hang');
          }
        }
        else if(isOnCeiling())
        {
          if(velX != 0)
          {
            sprite.play('ceiling-climb');
            if(!ceilingClimbSfx.playing)
            {
              ceilingClimbSfx.loop();
            }
          }
          else
          {
            sprite.play('ceiling-hang');
          }
        }
        else if(isSpinJumping)
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
      if(!isSpinJumping)
      {
        spinJumpSfx.stop();
      }
      if(!isOnCeiling() || velX == 0)
      {
        ceilingClimbSfx.stop();
      }
      if(!isOnWall() || velY == 0)
      {
        wallClimbSfx.stop();
      }
    }

}
