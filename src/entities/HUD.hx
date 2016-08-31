package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Text;

class HUD extends Entity
{

    private var text:Text;

    public function new()
    {
      super(0, 0);
      text = new Text();
      text.addStyle("health", {color: 0xFFFFFF, size: text.size, bold: true});
      text.addStyle("sequence", {color: 0x000000, size: text.size, bold: false});
      /*text.addStyle("red", {color: 0xFF0000, size: text.size * 2, bold: true});*/
      text.setTextProperty('richText', true);
      text.richText = "<health>100</health>";
      graphic = text;
    }

    override public function update()
    {
      super.update();
      var player:Entity = scene.getInstance('player');
      if(cast(player, Player).isDead)
      {
        graphic.visible = false;
        return;
      }
      x = player.centerX - text.textWidth/2;
      y = player.y - 5;
      x = player.centerX - text.textWidth/2;
      y = player.y - 5;
      text.richText = "<health>" + cast(player, Player).health + " + </health>\n\n\n\n<sequence>" + cast(scene, scenes.GameScene).screenSequence + "</sequence>";
    }
}
