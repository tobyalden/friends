package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;
import scenes.GameScene;
import entities.Player;

class Visuals extends Entity
{

    private var sprite:Spritemap;

    public function new(offset:Bool)
    {
      super(HXP.scene.camera.x, HXP.scene.camera.y);
      sprite = new Spritemap("graphics/visuals.png", 640, 480);
      if(offset)
      {
        sprite.add("idle", [9, 8, 7, 6, 5, 4, 3, 2, 1, 0, 1, 2, 3, 4, 5, 6, 7, 8], 14);
      }
      else
      {
        sprite.add("idle", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 8, 7, 6, 5, 4, 3, 2, 1], 12);
      }
      sprite.play("idle");
      sprite.scale = 4;
      sprite.alpha = 0.5;
      graphic = sprite;
    }

    override public function update()
    {
      x = HXP.scene.camera.x;
      y = HXP.scene.camera.y;
    }
}
