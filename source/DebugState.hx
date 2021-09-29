import flixel.FlxG;
import flixel.FlxState;

class DebugState extends FlxState
{
    public function new()
    {
        super();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        FlxG.switchState(new TitleState());
    }
}