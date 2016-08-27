package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;
import scenes.GameScene;
import entities.Player;

class ResetFlash extends Entity
{
    private var image:Image;
    private var resetSfx:Sfx;

    public function new()
    {
      super(HXP.scene.camera.x, HXP.scene.camera.y);
      image = Image.createRect(HXP.width, HXP.height, 0xFFFFFF);
      layer = -9999999;
      graphic = image;
      resetSfx = new Sfx("audio/reset.wav");
      resetSfx.play();
    }

    override public function update()
    {
      x = HXP.scene.camera.x;
      y = HXP.scene.camera.y;
      if(image.alpha > 0)
      {
        image.alpha -= 0.01;
      }
    }
}
