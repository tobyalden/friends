import com.haxepunk.Engine;
import com.haxepunk.*;
import com.haxepunk.utils.*;

class Main extends Engine
{

	override public function init()
	{
#if debug
		HXP.console.enable();
#end
		HXP.scene = new scenes.GameScene();
	}

	public static function main() { new Main(); }

}
