package;

import Controls.KeyboardScheme;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

class OptionsMenu extends MusicBeatState
{
	//var selector:FlxText;
	var curSelected:Int = 1;

	var controlsStrings:Array<String> = [];

	private var grpControls:FlxTypedGroup<Alphabet>;
	var versionShit:FlxText;

	public static var inSubState:Bool = false;
	
	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		controlsStrings = CoolUtil.coolStringFile(
			"Gameplay Settings" +
			"\nToggle Fullscreen" +
			"\nCustom Keybinds" + 
			"\n" +
			"\nUI Settings" +
			"\n" + (FlxG.save.data.downscroll ? 'Downscroll' : 'Upscroll') + 
			"\nAccuracy " + (!FlxG.save.data.accuracyDisplay ? "off" : "on") + 
			"\nSong Position " + (!FlxG.save.data.songPosition ? "off" : "on") +
			"\nShow Left Arrows " + (!FlxG.save.data.showLeftArrows ? "off" : "on") +
			"\nCenter Arrows " + (!FlxG.save.data.centerArrows ? "off" : "on") +
			"\nFuck You");
		
		#if debug
		trace(controlsStrings);
		#end

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...controlsStrings.length)
		{
				var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, controlsStrings[i], true, false);
				controlLabel.isMenuItem = true;
				controlLabel.targetY = i;
				grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}


		versionShit = new FlxText(5, FlxG.height - 18, 0, "Offset (Left, Right): " + FlxG.save.data.offset, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		super.create();

		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.BACK)
			FlxG.switchState(new MainMenuState());
		if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);
		
		if (controls.RIGHT_P)
		{
			FlxG.save.data.offset++;
			versionShit.text = "Offset (Left, Right): " + FlxG.save.data.offset;
		}

		if (controls.LEFT_P)
			{
				FlxG.save.data.offset--;
				versionShit.text = "Offset (Left, Right): " + FlxG.save.data.offset;
			}


		if (controls.ACCEPT)
		{
			if (curSelected != 7)
				grpControls.remove(grpControls.members[curSelected]);
			switch(curSelected)
			{
				case 1:
					FlxG.fullscreen = !FlxG.fullscreen;
					var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, "Toggle Fullscreen", true, false);
					ctrl.isMenuItem = true;
					ctrl.targetY = curSelected - 1;
					grpControls.add(ctrl);

				case 2:
					var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, "Custom Keybinds", true, false);
					ctrl.isMenuItem = true;
					ctrl.targetY = curSelected - 2;
					grpControls.add(ctrl);
					inSubState = true;
					openSubState(new CustomKeybindSubstate());
					
				case 5:
					FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
					var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, (FlxG.save.data.downscroll ? 'Downscroll' : 'Upscroll'), true, false);
					ctrl.isMenuItem = true;
					ctrl.targetY = curSelected - 5;
					grpControls.add(ctrl);
				case 6:
					FlxG.save.data.accuracyDisplay = !FlxG.save.data.accuracyDisplay;
					var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, "Accuracy " + (!FlxG.save.data.accuracyDisplay ? "off" : "on"), true, false);
					ctrl.isMenuItem = true;
					ctrl.targetY = curSelected - 6;
					grpControls.add(ctrl);
				case 7:
					FlxG.save.data.songPosition = !FlxG.save.data.songPosition;
					var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, "Song Position " + (!FlxG.save.data.songPosition ? "off" : "on"), true, false);
					ctrl.isMenuItem = true;
					ctrl.targetY = curSelected - 7;
					grpControls.add(ctrl);
				case 8:
					FlxG.save.data.showLeftArrows = !FlxG.save.data.showLeftArrows;
					var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, "Show Left Arrows " + (!FlxG.save.data.showLeftArrows ? "off" : "on"), true, false);
					ctrl.isMenuItem = true;
					ctrl.targetY = curSelected - 8;
					grpControls.add(ctrl);
				case 9:
					FlxG.save.data.centerArrows = !FlxG.save.data.centerArrows;
					var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, "Center Arrows " + (!FlxG.save.data.centerArrows ? "off" : "on"), true, false);
					ctrl.isMenuItem = true;
					ctrl.targetY = curSelected - 9;
					grpControls.add(ctrl);
				case 10:
					var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, "Fuck You ", true, false);
					ctrl.isMenuItem = true;
					ctrl.targetY = curSelected - 10;
					grpControls.add(ctrl);
			}
		}

		FlxG.save.flush();
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent('Fresh');
		#end

		if(change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 1)
			curSelected = 10;
		if (curSelected > 10)
			curSelected = 1;

		if(curSelected > 2 && curSelected < 5)
		{
			if(change > 0)
				curSelected = 5;
			else 
				curSelected = 2;
		}

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
