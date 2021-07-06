package;

import flixel.FlxG;
import flixel.FlxSprite;
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
	public var noteType:Int = 0; // Is it normal or is it a bomb???
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var jumpID:Int = -1;

	public var startsSustain:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var rating:String = "shit";

	public var hasChecked:Bool = false;
	public var originalX:Float = 0.0;
	public var posOrNeg:Float = (FlxG.random.bool() ? -1 : 1);
	public var coefficient:Float = 0.0;
	public var downscroll:Bool = FlxG.save.data.downscroll;
	public var isFinalSustain:Bool = false;

	public function new(strumTime:Float, noteData:Int, ?noteType:Int = 0, ?prevNote:Note, ?sustainNote:Bool = false, ?startx:Int = 50)
	{
		super();

		if (prevNote == null)
			prevNote = this;
		
		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += startx;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime + FlxG.save.data.offset;

		this.noteData = noteData;
		this.noteType = noteType;

		var daStage:String = PlayState.curStage;

		switch (daStage)
		{
			case 'school' | 'schoolEvil':
				loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);

				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);

				if (isSustainNote)
				{
					loadGraphic(Paths.image('weeb/pixelUI/arrowEnds'), true, 7, 6);

					animation.add('purpleholdend', [4]);
					animation.add('greenholdend', [6]);
					animation.add('redholdend', [7]);
					animation.add('blueholdend', [5]);

					animation.add('purplehold', [0]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);
					animation.add('bluehold', [1]);
				}

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();

			default:
				frames = Paths.getSparrowAtlas('NOTE_assets');

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

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = true;
		}
		if(noteType == 0)
		{
			switch (noteData)
			{
				case 0:
					x += swagWidth * 0;
					animation.play('purpleScroll');
				case 1:
					x += swagWidth * 1;
					animation.play('blueScroll');
				case 2:
					x += swagWidth * 2;
					animation.play('greenScroll');
				case 3:
					x += swagWidth * 3;
					animation.play('redScroll');
			}
		}
		else if(noteType == 1)
		{
			switch (noteData)
			{
				case 0:
					x += swagWidth * 0;
				case 1:
					x += swagWidth * 1;
				case 2:
					x += swagWidth * 2;
				case 3:
					x += swagWidth * 3;
			}
			animation.play('bomb');
		}
		// trace(prevNote);

		if (FlxG.save.data.downscroll && isSustainNote)
			flipY = true;
		
		if (isSustainNote && prevNote != null)
		{
			posOrNeg = prevNote.posOrNeg;
			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			switch (noteData)
			{
				case 2:
					animation.play('greenholdend');
					isFinalSustain = true;
					prevNote.isFinalSustain = false;
				case 3:
					animation.play('redholdend');
					isFinalSustain = true;
					prevNote.isFinalSustain = false;
				case 1:
					animation.play('blueholdend');
					isFinalSustain = true;
					prevNote.isFinalSustain = false;
				case 0:
					animation.play('purpleholdend');
					isFinalSustain = true;
					prevNote.isFinalSustain = false;
			}

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school'))
				x += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}

		originalX = x;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(Math.floor(sustainLength) > 0) 
			startsSustain = true;
		else
			startsSustain = false;

		if (mustPress)
		{
			var noteDiff:Float = Math.abs(strumTime - Conductor.songPosition);

			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset 
				&& noteType == 0 && !isSustainNote)
				canBeHit = true;
			else if(strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * (0.5))
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * (0.5))
				&& noteType == 0 && isSustainNote && getRootNote().wasGoodHit)
				canBeHit = true;
			else if(noteDiff < Conductor.safeZoneOffset * 0.25
				&& noteDiff > Conductor.safeZoneOffset * -0.25 && noteType == 1)
				canBeHit = true;
			else
				canBeHit = false;

			if(isSustainNote && (prevNote.tooLate || getRootNote().tooLate))
			{
				tooLate = true;
				canBeHit = false;
			}

			if(isSustainNote && getRootNote().wasGoodHit)
			{
				alpha = 0.6 - 0.5 * Math.abs(1.0 - PlayState.holdArray[noteData].getNormalizedfBool());
			}

			if(canBeHit)
			{
				switch(noteType)
				{
				case 0:
					if(noteDiff > Conductor.safeZoneOffset * 0.8)
						rating = "shit";
					else if(noteDiff < Conductor.safeZoneOffset * -0.8)
						rating = "shit";
					else if(noteDiff > Conductor.safeZoneOffset * 0.6)
						rating = "bad";
					else if(noteDiff < Conductor.safeZoneOffset * -0.6)
						rating = "bad";
					else if(noteDiff > Conductor.safeZoneOffset * 0.25)
						rating = "good";
					else if(noteDiff < Conductor.safeZoneOffset * -0.25)
						rating = "good";
					else
						rating = "sick";
				case 1:
					rating = "boom";
				}
				FlxG.watch.addQuick("Note" + this.ID, rating);
			}

			if(strumTime < Conductor.songPosition - (Conductor.safeZoneOffset * 1.0) && !wasGoodHit)
			{
				tooLate = true;
				rating = "shit";
			}
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition && noteType == 0)
				wasGoodHit = true;

			if(FlxG.save.data.centerArrows || !FlxG.save.data.showLeftArrows)
				alpha = 0;
		}

		if (tooLate)
		{
			if (alpha > 0.1)
				alpha = 0.1;
		}

		if(!hasChecked)
		{
			originalX = x;
			hasChecked = true;
		}
		else
		{
			if(PlayState.noteSillyTime)
			{
				coefficient += elapsed;
				if(coefficient > 1)
					coefficient = 1;
			}
			else
			{
				coefficient -= elapsed;
				if(coefficient < 0)
					coefficient = 0;
			}
			if(coefficient > 0)
				x = originalX + coefficient * swagWidth * posOrNeg * Math.sin(Math.PI * 2.0 * (y - (downscroll ? 555 : 50)) / 720.0) * (0.4);
			if(PlayState.noteGoInsane)
				x = originalX + FlxG.random.float(-1 * swagWidth/2, swagWidth/2);
		}
	}

	public function getRootNote()
	{
		if(!isSustainNote)
			return this;
		return prevNote.getRootNote();
	}
}
