package scenes;

import com.haxepunk.Scene;
import entities.*;

class GameScene extends Scene
{

    public function new()
    {
        super();
    }

    public override function begin()
    {
        add(new Level());
        add(new PlayerOne(320, 240));
    }

}
