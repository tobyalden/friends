package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.Sfx;
import scenes.GameScene;
import entities.Player;

class God extends Entity
{

    private var sprite:Spritemap;
    public var godType:String;

    public function new(x:Float, y:Float, godType:String)
    {
        super(x, y);
        this.godType = godType;
        sprite = new Spritemap("graphics/" + godType + "-god.png", 1080, 720);
        if(godType == "angel")
        {
          sprite.add("idle", [0, 1, 2, 3, 4, 5], 9);
        }
        sprite.play("idle");
        graphic = sprite;
        name = "god";
    }

    public override function update()
    {
        super.update();
    }
}
