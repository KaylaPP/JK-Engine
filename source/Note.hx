package;

import flixel.effects.postprocess.PostProcess;
import sys.io.File;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

using StringTools;

class Note extends FlxSprite
{
	public static var usedIDs:Array<Int> = [-1];
	public static var hitIDs:Array<Int> = [-1];

	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var noteType:String = '1'; // Is it normal or is it a bomb???
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;

	public var jumpID:Int = -1;

	public var startY:Float = 0.0;

	public static var swagWidth:Float = 160 * 0.7;

	public var rating:String = "shit";

	// for bombs
	public var prevY:Float;
	public var strumY:Float;

	// for explosion animation
	public var exploding:Bool = false;
	public var boomElapsed:Float = 0.0;

	public var alwaysFullAlpha:Bool = false;

	public var rootNote:Note;
	public var sustainPiece:Note;
	public var sustainEnd:Note;

	public var sustainLength:Float = 0;

	// for sustain ends that are inside the rootnote
	public var insideRoot:Bool = false;

	public function new(strumTime:Float, sustainLength:Float, noteData:Int, useOldJKJSON:Bool = true, noteType:String = '1', ?rootNote:Note = null, ?sustainPiece:Note = null, ?sustainEnd:Note = null)
	{
		super();
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime + FlxG.save.data.offset;
		this.sustainLength = sustainLength;
		this.noteData = noteData;
		if(useOldJKJSON)
		{
			switch(noteType)
			{
				case '0':
					if(sustainLength > 0)
						noteType = '2';
					else
						noteType = '1';
				case '1':
					noteType = 'M';
			}
		}

		if(sustainLength <= 0 && noteType == '2')
		{
			noteType == '1';
		}

		this.noteType = noteType;

		if(noteType == '2')
		{
			#if debug
			trace('generating sustains');
			#end
			this.rootNote = this;
			this.sustainPiece = new Note(strumTime, 0, noteData, false, '0', this.rootNote);
			this.sustainEnd = new Note(strumTime + sustainLength, 0, noteData, false, '3', this.rootNote, this.sustainPiece);

		}
		if(noteType == '0')
		{
			#if debug
			trace('sustain piece');
			#end
			this.rootNote = rootNote;
			this.sustainPiece = this;
		}
		if(noteType == '3')
		{
			#if debug
			trace('sustain end');
			#end
			this.rootNote = rootNote;
			this.sustainPiece = sustainPiece;
			this.sustainPiece.sustainEnd = this;
			this.sustainEnd = this;
		}

		#if debug
		trace(rootNote == null);
		trace(sustainPiece == null);
		trace(sustainEnd == null);
		#end

		//var daStage:String = PlayState.curStage;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(exploding)
		{
			boomElapsed += elapsed;
			return;
		}

		if (mustPress)
		{
			var noteDiff:Float = Math.abs(strumTime - Conductor.songPosition);

			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset 
				&& (noteType == '1' || noteType == '2'))
				canBeHit = true;
			else if(noteType == '0' && rootNote.wasGoodHit)
				canBeHit = true;
			else if(((prevY >= strumY && y < strumY) || (prevY <= strumY && y > strumY)) && (noteType == 'M'))
				canBeHit = true;
			else if(y < 100 && noteType == '3')
				canBeHit = true;
			else
				canBeHit = false;

			if((noteType == '0' || noteType == '3') && rootNote.tooLate)
			{
				tooLate = true;
				canBeHit = false;
			}

			if((noteType == '0' || noteType == '3') && rootNote.wasGoodHit)
			{
				color = 0xFFFFFF -
					0x10000 * Std.int(0xE5 * Math.abs(1.0 - PlayState.holdArray[noteData].getNormalizedfBool())) -
					0x100 * Std.int(0xE5 * Math.abs(1.0 - PlayState.holdArray[noteData].getNormalizedfBool())) -
					Std.int(0xE5 * Math.abs(1.0 - PlayState.holdArray[noteData].getNormalizedfBool()));
			}

			if(canBeHit)
			{
				switch(noteType)
				{
				case '1', '2', '4':
					if(noteDiff > 150)
						rating = "shit";
					else if(noteDiff > 120)
						rating = "crap"
					else if(noteDiff > 80)
						rating = "bad";
					else if(noteDiff > 55)
						rating = "good";
					else if(noteDiff > 30)
						rating = "cool";
					else
						rating = "sick";
				case '3': 
					rating = "sick";
				case 'M':
					rating = "boom";
				}
			}

			if(strumTime < Conductor.songPosition - (Conductor.safeZoneOffset * 1.0) && !wasGoodHit && noteType != '0')
			{
				tooLate = true;
				rating = "shit";
			}
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition && (noteType == '1' || noteType == '2' || noteType == '4'))
				wasGoodHit = true;
			if(y < 100 && noteType == '3')
				wasGoodHit = true;

			if((FlxG.save.data.centerArrows || !FlxG.save.data.showLeftArrows) && !alwaysFullAlpha)
				alpha = 0;
		}

		if (tooLate && noteType != 'M')
		{
			if (color != 0x1A1A1A)
				color = 0x1A1A1A;
		}

		if(insideRoot && noteType == '0')
		{
			alpha = 0;
		}
		else 
		{
			alpha = 1;
		}
	}

	public function generateSprite():Void
	{
		frames = Paths.getSparrowAtlas('NOTE_assets', 'shared');

		animation.addByPrefix('bomb', 'bomb');

		animation.addByPrefix('greenScroll', 'green0');
		animation.addByPrefix('redScroll', 'red0');
		animation.addByPrefix('blueScroll', 'blue0');
		animation.addByPrefix('purpleScroll', 'purple0');

		animation.addByPrefix('purpleholdend', 'pruple end hold');
		animation.addByPrefix('greenholdend', 'green hold end');
		animation.addByPrefix('redholdend', 'red hold end');
		animation.addByPrefix('blueholdend', 'blue hold end');

		animation.addByPrefix('purplehold', 'purple hold piece');
		animation.addByPrefix('greenhold', 'green hold piece');
		animation.addByPrefix('redhold', 'red hold piece');
		animation.addByPrefix('bluehold', 'blue hold piece');

		if(noteType == 'M')
		{
			animation.play('bomb');
		}
		if(noteType == '1' || noteType == '2' || noteType == '4')
		{
			switch(noteData)
			{
				case 0:
					animation.play('purpleScroll');
				case 1:
					animation.play('blueScroll');
				case 2:
					animation.play('greenScroll');
				case 3:
					animation.play('redScroll');
			}
		}
		if(noteType == '0')
		{
			switch(noteData)
			{
				case 0:
					animation.play('purplehold');
				case 1:
					animation.play('bluehold');
				case 2:
					animation.play('greenhold');
				case 3:
					animation.play('redhold');
			}
		}
		if(noteType == '3')
		{
			switch(noteData)
			{
				case 0:
					animation.play('purpleholdend');
				case 1:
					animation.play('blueholdend');
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
			}
		}

		updateHitbox();
		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		antialiasing = true;

		x = 417 + 160 * noteData * 0.7;

		if(noteType == '0' || noteType == '3')
		{
			x += 35;
		}
		if(noteType == '0')
		{
			flipY = true;
			startY += rootNote.height / 2;
		}
		if(noteType == '3')
		{
			startY += rootNote.height - height;
		}

		y = -2000;

		if (FlxG.save.data.downscroll && sustainLength > 0)
			flipY = true;

		if(!FlxG.save.data.centerArrows)
			x -= 367;

		if(mustPress)
			x += FlxG.width / 2;
	}
}
