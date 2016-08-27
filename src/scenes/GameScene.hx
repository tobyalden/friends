package scenes;

import com.haxepunk.*;
import com.haxepunk.graphics.*;
import entities.*;
import com.haxepunk.utils.*;

class GameScene extends Scene
{

    private var currentLevel:Level;
    private var player:Player;

    public function new()
    {
        super();
    }

    public override function update()
    {
      super.update();
      if(Input.pressed(Key.R))
      {
        player.stopAllSfx();
        currentLevel.levelMusic.stop();
        removeAll();
        HXP.scene = new GameScene();
      }
    }

    public override function begin()
    {
        currentLevel = new Level(Level.WORLD_WIDTH, Level.WORLD_HEIGHT, "start");
        add(new Entity(0, 0, new Backdrop("graphics/" + currentLevel.levelType + "-background.png")));
        add(new Visuals(true));
        add(new Visuals(false));
        add(currentLevel);
        for(entity in currentLevel.levelEntities)
        {
          add(entity);
        }
        player = currentLevel.getPlayer();
        add(player);
        add(new HUD());
        add(new ResetFlash());
    }

    public function nextLevel(exitDirection:String)
    {
      currentLevel.levelMusic.stop();
      removeAll();
      var levelTypes:Array<String> = ["default", "spa", "tantrum"];
      currentLevel = new Level(Level.WORLD_WIDTH, Level.WORLD_HEIGHT, levelTypes[Math.round((levelTypes.length - 1) * Math.random())]);
      add(new Entity(0, 0, new Backdrop("graphics/" + currentLevel.levelType + "-background.png")));
      add(new Visuals(true));
      add(new Visuals(false));
      add(currentLevel);
      for(entity in currentLevel.levelEntities)
      {
        add(entity);
      }
      add(player);
      if(exitDirection == "left")
      {
        player.x = Math.round(currentLevel.levelWidth * Level.TOTAL_SCALE - player.width * 2);
      }
      else if(exitDirection == "right")
      {
        player.x = 0;
      }
      else if(exitDirection == "top")
      {
        player.y = Math.round(currentLevel.levelHeight * Level.TOTAL_SCALE - player.height * 2);
      }
      else if(exitDirection == "bottom")
      {
        player.y = 0;
      }
      add(new HUD());
    }

}
