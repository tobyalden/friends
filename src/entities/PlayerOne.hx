package entities;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.graphics.Image;

class PlayerOne extends Entity
{
    public function new(x:Int, y:Int)
    {
        super(x, y);
        graphic = new Image("graphics/player_one.png");
    }

    public override function update()
    {
        if (Input.check(Key.LEFT))
        {
            moveBy(-5, 0);
        }
        if (Input.check(Key.RIGHT))
        {
            moveBy(5, 0);
        }
        if (Input.check(Key.UP))
        {
            moveBy(0, -5);
        }
        if (Input.check(Key.DOWN))
        {
            moveBy(0, 5);
        }
        HXP.camera.x = x - HXP.screen.width/2;
        HXP.camera.y = y - HXP.screen.height/2;
        super.update();
    }
}
