package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.Sfx;
import scenes.GameScene;
import entities.Player;

class PinkBrother extends ActiveEntity
{
    public static inline var ACTIVE_RANGE = 250;
    public static inline var SPEED = 0.25;
    public static inline var MAX_VELOCITY = 6;

    private var chasing:Bool;

    public function new(x:Float, y:Float)
    {
        super(x, y-64);
        setHitbox(15, 45, -6, 0);
        chasing = false;
        sprite = new Spritemap("graphics/pink_brother.png", 25, 45);
        sprite.add("idle", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], 10);
        sprite.play("idle");
        graphic = sprite;
        health = 250;
        type = "enemy";
    }

    public override function update()
    {
        super.update();
        var player:Entity = scene.getInstance('player');

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
          if(y < player.y)
          {
            velY += SPEED;
            sprite.flipped = false;
          }
          else
          {
            velY -= SPEED;
          }

          if(velX > MAX_VELOCITY)
          {
            velX = MAX_VELOCITY;
          }
          if(velY > MAX_VELOCITY)
          {
            velY = MAX_VELOCITY;
          }
        }

        moveBy(velX, velY, "none");
    }

}
