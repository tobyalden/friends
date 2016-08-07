package entities;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.graphics.Image;

class PlayerOne extends Entity
{

    public static inline var GRAVITY = 2;

    private var velX:Int;
    private var velY:Int;

    public function new(x:Int, y:Int)
    {
        super(x, y);
        graphic = new Image("graphics/player_one.png");
        layer = 10;
        velX = 0;
        velY = 0;
        setHitboxTo(graphic);
    }

    public override function update()
    {
        if (Input.check(Key.LEFT))
        {
            velX = -5;
        }
        else if (Input.check(Key.RIGHT))
        {
            velX = 5;
        }
        else
        {
          velX = 0;
        }

        velY = GRAVITY;

        moveBy(velX, velY, "walls");

        HXP.camera.x = x - HXP.screen.width/2;
        HXP.camera.y = y - HXP.screen.height/2;
        super.update();
    }
}
