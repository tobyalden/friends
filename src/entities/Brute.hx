package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.Sfx;
import scenes.GameScene;
import entities.Player;

class Brute extends ActiveEntity
{
    public static inline var ACTIVE_RANGE = 450;
    public static inline var JUMP_VEL_X = 2;
    public static inline var JUMP_VEL_Y = 10;
    public static inline var JUMP_COOLDOWN = 4;

    private var cooldownTimer:Int;

    public function new(x:Float, y:Float)
    {
        super(x, y-64);
        setHitbox(47, 77, -14, -3);
        cooldownTimer = 0;
        sprite = new Spritemap("graphics/brute.png", 75, 80);
        sprite.add("idle", [0]);
        sprite.add("jump", [1, 2, 3], 12);
        sprite.play("idle");
        graphic = sprite;
        health = 400;
        type = "enemy";
    }

    public override function update()
    {
        super.update();
        var player:Entity = scene.getInstance('player');

        if(isOnGround())
        {
          velX = 0;
          velY = 0;
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
        sprite.flipped = true;
      }
      else
      {
        velX = -JUMP_VEL_X;
        sprite.flipped = false;
      }
      velY = -JUMP_VEL_Y * Math.random();
      cooldownTimer = JUMP_COOLDOWN;
      sprite.play("jump");
    }
}
