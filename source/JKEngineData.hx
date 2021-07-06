import flixel.FlxG;

class JKEngineData
{
    public static function initSave()
    {
	if (FlxG.save.data.downscroll == null)
		FlxG.save.data.downscroll = false;

	if (FlxG.save.data.dfjk == null)
		FlxG.save.data.dfjk = false;
		
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
	}
}
