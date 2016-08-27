package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.Sfx;
import scenes.GameScene;
import entities.Player;

class LustDemon extends ActiveEntity
{
    public static inline var ACTIVE_RANGE = 250000000;
    public static inline var SPEED = 0.025;
    public static inline var MAX_VELOCITY = 0.6;

    private var chasing:Bool;

    public static inline var BOB_SPEED = 0.025;

    private var bob:Float;

    public function new(x:Float, y:Float)
    {
        super(x, y-64);
        setHitbox(100, 100, 0, 0);
        chasing = false;
        sprite = new Spritemap("graphics/lust_demon.png", 100, 100);
        sprite.add("idle", [
          0, 1, 2, 3, 4,
          5, 6, 7, 8, 9,
          10, 11, 12, 13, 14,
          15, 16, 17, 18, 19,
          20, 21, 22, 23, 24
        ], 10);
        sprite.play("idle");
        graphic = sprite;
        health = 600;
        bob = 0;
        type = "enemy";
    }

    public override function update()
    {
        super.update();
        var player:Entity = scene.getInstance('player');
        bob += BOB_SPEED;
        if(bob > Math.PI*2)
        {
          bob -= Math.PI*2;
        }

        if(chasing || distanceFrom(player) < ACTIVE_RANGE)
        {
          chasing = true;
          if(centerX < player.centerX)
          {
            velX += SPEED;
          }
          else
          {
            velX -= SPEED;
            sprite.flipped = true;
          }

          y += Math.sin(bob) * 2;

        }

        moveBy(velX, velY, "none");
    }

}
