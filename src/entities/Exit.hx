package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.Sfx;
import scenes.GameScene;
import entities.Player;

class Exit extends ActiveEntity
{

  public var exitDirection:String;
  public function new(x:Float, y:Float, exitDirection:String)
  {
    super(x, y);
    this.exitDirection = exitDirection;
    setHitbox(Level.TOTAL_SCALE, Level.TOTAL_SCALE);
    type = "exit";
  }
}
