package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.Sfx;
import scenes.GameScene;
import entities.Player;

class Hopper extends ActiveEntity
{
    public static inline var ACTIVE_RANGE = 250;
    public static inline var JUMP_VEL_X = 3;
    public static inline var JUMP_VEL_Y = 6;
    public static inline var JUMP_COOLDOWN = 60;

    // health should be 25 hits

    private var cooldownTimer:Int;

    public function new(x:Float, y:Float)
    {
        super(x, y-64);
        setHitbox(48, 36, -8, -28);
        cooldownTimer = 0;
        sprite = new Spritemap("graphics/hopper.png", 64, 64);
        sprite.add("idle", [0]);
        sprite.add("jump", [1, 2], 2);
        sprite.play("idle");
        graphic = sprite;
        health = 250;
        type = "enemy";
    }

    // If player is within range
      // If you're not on a cooldown timer
        // Jump towards player (set X & Y velocity at a diagonal and apply gravity)
      // The moment you land, start a cooldown timer

    public override function update()
    {
        super.update();
        var player:Entity = scene.getInstance('player');

        if(isOnGround())
        {
          velX = 0;
          velY = 0;
          /*if(cooldownTimer <= 0)*/
          if(cooldownTimer <= 0 && distanceFrom(player) < ACTIVE_RANGE)
          {
            jump(player.x);
          }
          else if(cooldownTimer > 0)
          {
            cooldownTimer--;
          }
        }
        else
        {
          velY += Player.GRAVITY;
        }

        moveBy(velX, velY, "walls");
    }

    private function jump(playerX:Float)
    {
      if(x < playerX)
      {
        velX = JUMP_VEL_X;
      }
      else
      {
        velX = -JUMP_VEL_X;
      }
      velY = -JUMP_VEL_Y;
      cooldownTimer = JUMP_COOLDOWN;
      sprite.play('jump');
    }
}
