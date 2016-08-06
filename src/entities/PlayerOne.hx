package entities;

import com.haxepunk.Entity;
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
            moveBy(-2, 0);
        }
        if (Input.check(Key.RIGHT))
        {
            moveBy(2, 0);
        }
        super.update();
    }
}
