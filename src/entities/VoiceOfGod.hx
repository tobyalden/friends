package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Text;

class VoiceOfGod extends Entity
{

    private var text:Text;
    private var sayings:Array<String>;
    private var sayingsIndex:Int;
    private var sayingsTimer:Int;

    public static inline var SAYING_INTERVAL = 100;

    public function new(godType:String)
    {
      super(0, 0);
      if(godType == "angel")
      {
        sayings = ["hehe hey there budy..", "today's super sequence is...", "uhh...i fogtget ", "is that helpful tee hee chuckle"];
      }
      text = new Text();
      text.addStyle("voice", {color: 0xFFFFFF, size: 100, bold: true, font: "Helvetica"});
      text.setTextProperty('richText', true);
      sayingsIndex = 0;
      sayingsTimer = SAYING_INTERVAL;
      text.richText = "<voice>" + sayings[sayingsIndex] + "</voice>";
      graphic = text;
      layer = -99999;
    }

    override public function update()
    {
      super.update();
      var god:Entity = scene.getInstance('god');
      x = god.centerX - text.textWidth/2;
      y = god.y - 5;
      x = god.centerX - text.textWidth/2;
      y = god.y - 5;
      text.richText = "<voice>HI LOL</voice>";
      if(sayingsTimer > 0)
      {
        sayingsTimer -= 1;
      }
      else
      {
        sayingsIndex += 1;
        if(sayingsIndex >= sayings.length)
        {
          sayingsIndex = 0;
        }
        sayingsTimer = SAYING_INTERVAL;
      }
      text.richText = "<voice>" + sayings[sayingsIndex] + "</voice>";
    }
}
