import flixel.input.keyboard.FlxKey;
import flixel.FlxG;

class JKEngineData
{
    public static function initSave()
    {
		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;
			
		if (FlxG.save.data.accuracyDisplay == null)
			FlxG.save.data.accuracyDisplay = true;

		if (FlxG.save.data.offset == null)
			FlxG.save.data.offset = 0;

		if (FlxG.save.data.songPosition == null)
			FlxG.save.data.songPosition = false;
		
		if (FlxG.save.data.showLeftArrows == null)
			FlxG.save.data.showLeftArrows = true;
		
		if (FlxG.save.data.centerArrows == null)
			FlxG.save.data.centerArrows = false;

		if (FlxG.save.data.KEY_UP == null)
			FlxG.save.data.KEY_UP = FlxKey.W;

		if (FlxG.save.data.KEY_LEFT == null)
			FlxG.save.data.KEY_LEFT = FlxKey.A;

		if (FlxG.save.data.KEY_DOWN == null)
			FlxG.save.data.KEY_DOWN = FlxKey.S;

		if (FlxG.save.data.KEY_RIGHT == null)
			FlxG.save.data.KEY_RIGHT = FlxKey.D;

		if (FlxG.save.data.KEY_ACCEPT == null)
			FlxG.save.data.KEY_ACCEPT = FlxKey.ENTER;

		if (FlxG.save.data.KEY_BACK == null)
			FlxG.save.data.KEY_BACK = FlxKey.ESCAPE;

		if (FlxG.save.data.KEY_RESET == null)
			FlxG.save.data.KEY_RESET = FlxKey.R;

		if (FlxG.save.data.NOTE_THEME == null)
			FlxG.save.data.NOTE_THEME = "vanilla";
	}
}
