package scenes;

import com.haxepunk.*;
import com.haxepunk.graphics.*;
import entities.*;

class GameScene extends Scene
{

    private var currentLevel:Level;
    private var player:Player;

    public function new()
    {
        super();
    }

    public override function begin()
    {
        add(new Entity(0, 0, new Backdrop("graphics/background.png")));
        add(new Visuals(true));
        add(new Visuals(false));
        currentLevel = new Level(Level.WORLD_WIDTH, Level.WORLD_HEIGHT, "start");
        add(currentLevel);
        for(entity in currentLevel.levelEntities)
        {
          add(entity);
        }
        player = currentLevel.getPlayer();
        add(player);
        add(new HUD(0, 0));
    }

    public function nextLevel(exitDirection:String)
    {
      removeAll();
      currentLevel = new Level(Level.WORLD_WIDTH, Level.WORLD_HEIGHT, "default");
      add(currentLevel);
      for(entity in currentLevel.levelEntities)
      {
        add(entity);
      }
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
      add(player);
    }

}
