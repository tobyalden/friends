package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.Sfx;
import scenes.GameScene;
import entities.Player;

class Spike extends ActiveEntity
{

  public static inline var SPIKE_HEIGHT = 32;

    public var orientation:String;

    public function new(x:Float, y:Float, orientation:String)
    {
        super(x, y);
        this.orientation = orientation;
        sprite = new Spritemap("graphics/spikes.png", 128, 128);
        sprite.add("floor", [0]);
        sprite.add("leftwall", [1]);
        sprite.add("ceiling", [2]);
        sprite.add("rightwall", [3]);
        if(orientation == "floor")
        {
          sprite.play("floor");
          setHitbox(128, 32, 0, -96);
        }
        else if(orientation == "leftwall")
        {
          sprite.play("leftwall");
          setHitbox(32, 128, 0, 0);
        }
        else if(orientation == "ceiling")
        {
          sprite.play("ceiling");
          setHitbox(128, 32, 0, 0);
        }
        else if(orientation == "rightwall")
        {
          sprite.play("rightwall");
          setHitbox(32, 128, -96, 0);
        }
        graphic = sprite;
        invincible = true;
        layer = -2550;
        type = "enemy";
    }
}
