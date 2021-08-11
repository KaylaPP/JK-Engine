package;

import flixel.FlxBasic;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

enum ScrollSpeedType
{
	MULTIPLIER;
	OVERRIDE;
}

class FNFSongOptionSubState extends MusicBeatSubstate
{
	private var row:Int = 0;
	private var rowText:FlxText;
	private var maxRow:Int;
	private var rowOptions:Array<Array<FlxText>>;
	private var scrollSpeedType:ScrollSpeedType = MULTIPLIER;
	private var scrollSpeed:Float = 1.0;
	private var scrollSpeedText:FlxText;
	private var doClose:Bool = false;

    public function new()
	{
		super();

		maxRow = 3;

		rowText = new FlxText().setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		rowText.text = '*';
		rowText.updateHitbox();
		add(rowText);
		
		rowOptions = new Array<Array<FlxText>>();
		for(i in 0...maxRow + 1)
		{
			rowOptions.push(new Array<FlxText>());
			switch(i)
			{
				case 0:
					var rowTitle:FlxText = new FlxText(37, 25 + i * 50).setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
					var bpms:Array<SMSong.SMBeat> = PlayState.SMSONG.getSMBeatsSortedAsMinToMax(PlayState.SMSONG.metadata.BPMS);
					if(PlayState.SMSONG != null && PlayState.SMSONG.metadata.BPMS.length > 1)
					{
						rowTitle.text = "(" + bpms[0].VAL + ", " + bpms[bpms.length - 1].VAL + ") ";
					}
					else 
					{
						rowTitle.text = "(" + bpms[0].VAL + ") ";
					}
					rowTitle.text += "Scroll Speed Modifiers: ";
					rowTitle.updateHitbox();
					add(rowTitle);
					rowOptions[i].push(rowTitle);

					var multiplierText:FlxText = new FlxText(rowTitle.x + rowTitle.width + 50, 25).setFormat(Paths.font("vcr.ttf"), 32, FlxColor.YELLOW, RIGHT);
					multiplierText.text = "Multiplier";
					multiplierText.updateHitbox();
					add(multiplierText);
					rowOptions[i].push(multiplierText);

					var overrideText:FlxText = new FlxText(multiplierText.x + multiplierText.width + 50, 25).setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
					overrideText.text = "Override";
					overrideText.updateHitbox();
					add(overrideText);
					rowOptions[i].push(overrideText);
				case 1: 
					var rowTitle:FlxText = new FlxText(37, 25 + i * 50).setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
					rowTitle.text = "Scroll Speed: ";
					rowTitle.updateHitbox();
					add(rowTitle);
					rowOptions[i].push(rowTitle);

					scrollSpeedText = new FlxText(rowTitle.x + rowTitle.width + 50, 25 + i * 50).setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
					scrollSpeedText.text = "" + scrollSpeed;
					scrollSpeedText.updateHitbox();
					add(scrollSpeedText);
					rowOptions[i].push(scrollSpeedText);
				case 2:
					var SMExperiment:FlxText = new FlxText(37, 25 + i * 50).setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
					SMExperiment.text = "EXPERIMENTAL - Play Stepmania version";
					SMExperiment.updateHitbox();
					add(SMExperiment);
					rowOptions[i].push(SMExperiment);
				case maxRow:
					var EXIT:FlxText = new FlxText(37, 25 + i * 50).setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
					EXIT.text = "EXIT";
					EXIT.updateHitbox();
					add(EXIT);
					rowOptions[i].push(EXIT);

			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(doClose)
		{
			close();
		}

		rowText.y = 25 + row * 50;

		if(controls.UP_P)
		{
			row--;
			if(row < 0)
				row = maxRow;
		}
		if(controls.DOWN_P)
		{
			row++;
			if(row > maxRow)
				row = 0;
		}

		var newScrollSpeed:Float = 0.0;
		switch(scrollSpeedType)
		{
			case MULTIPLIER:
				newScrollSpeed = scrollSpeed * PlayState.SONG.speed;
			case OVERRIDE: 
				newScrollSpeed = scrollSpeed;
		}
		scrollSpeedText.text = "" + scrollSpeed + " (Original: " + PlayState.SONG.speed + ", New: " + newScrollSpeed + ")";


		switch(row)
		{
			case 0: // SCROLL SPEED CHANGE TYPE (MULTIPLY OR CHANGETO)
				if(controls.LEFT_P)
				{
					switch(scrollSpeedType)
					{
						case MULTIPLIER:
							scrollSpeedType = OVERRIDE;
							rowOptions[0][2].color = FlxColor.YELLOW;
							rowOptions[0][1].color = FlxColor.WHITE;
						case OVERRIDE:
							scrollSpeedType = MULTIPLIER;
							rowOptions[0][1].color = FlxColor.YELLOW;
							rowOptions[0][2].color = FlxColor.WHITE;
					}
				}
				if(controls.RIGHT_P)
				{
					switch(scrollSpeedType)
					{
						case MULTIPLIER:
							scrollSpeedType = OVERRIDE;
							rowOptions[0][2].color = FlxColor.YELLOW;
							rowOptions[0][1].color = FlxColor.WHITE;
						case OVERRIDE:
							scrollSpeedType = MULTIPLIER;
							rowOptions[0][1].color = FlxColor.YELLOW;
							rowOptions[0][2].color = FlxColor.WHITE;
					}
				}
			case 1: // SCROLL SPEED CHANGE NUMBER SELECTION
				if(controls.LEFT_P)
				{
					scrollSpeed -= 0.1;
				}
				if(controls.RIGHT_P)
				{
					scrollSpeed += 0.1;
				}
				if(scrollSpeed <= 0)
					scrollSpeed = 0.1;
			case 2:
				if(controls.ACCEPT)
				{
					PlayState.isSMSong = true;
					FreeplayState.optionSubstateClosed = true;
					FreeplayState.loadSMSong = true;
					switch(scrollSpeedType)
					{
						case MULTIPLIER:
							PlayState.SONG.speed *= scrollSpeed;
						case OVERRIDE: 
							PlayState.SONG.speed = scrollSpeed;
					}
					doClose = true;
				}
			case maxRow: // EXIT
				if(controls.ACCEPT)
				{
					FreeplayState.optionSubstateClosed = true;
					FreeplayState.loadSMSong = false;
					switch(scrollSpeedType)
					{
						case MULTIPLIER:
							PlayState.SONG.speed *= scrollSpeed;
						case OVERRIDE: 
							PlayState.SONG.speed = scrollSpeed;
					}
					doClose = true;
				}
		}

		if(doClose)
		{
			for(array in rowOptions)
			{
				for(text in array)
				{
					text.alpha = 0;
				}
			}
			PlayState.SMSONG.velocityCoefficient = PlayState.SONG.speed;
			if(PlayState.SMSONG.metadata.TITLE.toLowerCase().indexOf('galaxy') == -1)
				PlayState.SMSONG.loadDifficulty(FreeplayState.SMDifficulties[FreeplayState.curDifficulty + 1]);
			else 
				PlayState.SMSONG.loadDifficulty(FreeplayState.SMGalaxyDifficulties[FreeplayState.curDifficulty - 2]);
			rowText.alpha = 0;
			scrollSpeedText.alpha = 0;
		}
	}

	override function destroy()
	{
		super.destroy();
	}
}
