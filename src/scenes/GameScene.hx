package scenes;

import com.haxepunk.*;
import com.haxepunk.graphics.*;
import entities.*;
import com.haxepunk.utils.*;

class GameScene extends Scene
{

    private var currentLevel:Level;
    private var player:Player;

    public var screenSequence:Array<String>;
    public var secretSequence:Array<String>;

    public function new()
    {
        super();
        resetSequences();
    }

    private function resetSequences() {
      screenSequence = new Array<String>();
      secretSequence = new Array<String>();
      var options:Array<String> = ["top", "bottom", "right", "left"];
      for (i in 0...4)
      {
        secretSequence.push(
            options[Math.round(Math.random() * (options.length - 1))]
        );
      }
      trace("Today's super sequence is: " + secretSequence);

    }

    public override function update()
    {
      super.update();
      if(Input.pressed(Key.R))
      {
        player.stopAllSfx();
        currentLevel.levelMusic.stop();
        currentLevel.deathMusic.stop();
        removeAll();
        HXP.scene = new GameScene();
        resetSequences();
      }
    }

    public override function begin()
    {
        currentLevel = new Level(Level.WORLD_WIDTH, Level.WORLD_HEIGHT, "start", secretSequence);
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
      currentLevel = new Level(Level.WORLD_WIDTH, Level.WORLD_HEIGHT, levelTypes[Math.round((levelTypes.length - 1) * Math.random())], secretSequence);
      add(new Entity(0, 0, new Backdrop("graphics/" + currentLevel.levelType + "-background.png")));
      add(new Visuals(true));
      add(new Visuals(false));
      add(currentLevel);

      for(entity in currentLevel.levelEntities)
      {
        add(entity);
      }
      add(player);
      screenSequence.push(exitDirection);
      if(screenSequence.length > 4)
      {
        screenSequence.reverse();
        screenSequence.pop();
        screenSequence.reverse();
      }
      if(screenSequence.toString() == secretSequence.toString())
      {
        trace("U win!");
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
      add(new HUD());
    }

}
