package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;

class ActiveEntity extends Entity
{
  private var velX:Float;
  private var velY:Float;

  public var health:Int;
  public var invincible:Bool;

  private var sprite:Spritemap;

  public function new(x:Float, y:Float)
  {
    super(x, y);
    velX = 0;
    velY = 0;
    invincible = false;
  }

  public function damage(damage:Int)
  {
    if(!invincible)
    {
      health -= damage;
      if(health <= 0)
      {
        scene.remove(this);
      }
    }
  }

  private function unstuck()
  {
    while(collide('walls', x, y) != null)
    {
      moveBy(0, -32);
    }
  }

  private function isOnGround()
  {
    return collide("walls", x, y + 1) != null;
  }

}
