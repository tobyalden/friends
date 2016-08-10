package scenes;

import com.haxepunk.*;
import com.haxepunk.graphics.*;
import entities.*;

class GameScene extends Scene
{

    public function new()
    {
        super();
    }

    public override function begin()
    {
        add(new Entity(0, 0, new Backdrop("graphics/background.png")));
        add(new Visuals(true));
        add(new Visuals(false));
        add(new Level(Level.WORLD_WIDTH, Level.WORLD_HEIGHT, true));
        add(new HUD(0, 0));
    }

}
