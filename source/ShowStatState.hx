//ShowStatState
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

#if desktop
import Discord.DiscordClient;
#end

using StringTools;

class ShowStatState extends MusicBeatState
{
    var pauseMusic:FlxSound;

    var showPrompt:Bool = true;
    var maxElapsed:Float = 1.0;
    var promptElapsed:Float = 0.0;
    var promptStr:String = "";

    var songName:String = "";
    var initStatTxt:String;

    var statTxt:FlxText;

    public function new(sicks:Int, cools:Int, goods:Int, bads:Int, shits:Int, misses:Int, bombs:Int, score:Int, gotHighScore:Bool, accuracy:Float, initSongName:String, songDifficulty:String, rank:String)
    {
        super();

        for(i in 0...initSongName.length)
        {
            if(initSongName.charAt(i) == '-')
                songName += ' ';
            else
                songName += initSongName.charAt(i);
        }

        initStatTxt = "Rank:   " + rank + "\n" + songName + " " + songDifficulty + "\nScore:    " + score + (gotHighScore ? " NEW HIGH SCORE" : "") + "\nAccuracy: " + truncateFloat(accuracy, 2) + "%\nSicks:    " + sicks + "\nCools:    " + cools + "\nGoods:    " + goods + "\nBads:     " + bads + "\nShits:    " + shits + "\nMisses:   " + misses + "\nBombs:    " + bombs;
    }

	override public function create():Void
	{
		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

        statTxt = new FlxText(0, 10, 0, "", 30);
		statTxt.setFormat(Paths.font("vcr.ttf"), 50, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		statTxt.scrollFactor.set();
        statTxt.text = initStatTxt;
		add(statTxt);

		super.create();
	}

	override function update(elapsed:Float)
	{
        if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

        promptElapsed += elapsed;
        if(promptElapsed >= maxElapsed)
        {
            promptElapsed = 0.0;
            showPrompt = !showPrompt;
        }

        if(showPrompt)
            promptStr = "\nPress ENTER to return to Freeplay";
        else
            promptStr = "\n";

        statTxt.text = initStatTxt + promptStr + "\n";

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter)
		{
            FlxG.switchState(new FreeplayState());
            pauseMusic.destroy();
		}

		super.update(elapsed);
	}

	function truncateFloat( number : Float, precision : Int): Float 
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
	}

}
