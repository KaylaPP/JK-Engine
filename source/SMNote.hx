import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.system.FlxSound;

enum SMNoteColor
{
    RED;
    BLUE;
    PURPLE;
    GREEN;
    ORANGE;
    PINK;
    CYAN;
    GRAY;
}

class SMNote extends FlxSprite
{
    public static var colors:Array<String> = ['orange', 'magenta', 'gray', 'purple', 'red', 'blue', 'green', 'cyan'];
	public static var anim:Array<String> = ['left arrow', 'up arrow', 'down arrow', 'right arrow', 'hold end', 'hold piece'];

    public var direction:Int;
    public var numerator:Int;
    public var denominator:Int;
    public var section:Int;
    public var smcolor:SMNoteColor = GRAY;
    public var strumTime:Float;
    public var noteType:String;

    public var rootNote:SMNote;
    public var sustainPiece:SMNote;
    public var sustainEnd:SMNote;

    public var timeProcessed = false;

    public var wasGoodHit:Bool = false;
    public var couldHaveBeenHit:Bool = false;
    public var dead:Bool = false;
    public var canBeHit:Bool = false;

    public var jumpID:Int = -1;

    public var startY:Float = 0.0;

    public var currentSong:SMSong;

    public function new(currentSong:SMSong, direction:Int, numerator:Int, denominator:Int, section:Int, noteType:String, ?rootNote:SMNote = null, ?sustainPiece:SMNote = null, ?sustainEnd:SMNote = null)
    {
        super();

        this.currentSong = currentSong;
        this.direction = direction;
        this.numerator = numerator;
        this.denominator = denominator;
        this.section = section;
        this.noteType = noteType;
        this.rootNote = rootNote;
        this.sustainPiece = sustainPiece;
        this.sustainEnd = sustainEnd;
        #if debug
        if(numerator == denominator)
        {
            trace('big bad');
        }
        #end
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        var noteDiff:Float = Math.abs(strumTime - currentSong.elapsedTime);
        if(noteType == '0' && sustainEnd.wasGoodHit)
        {
            visible = false;
            dead = true;
            wasGoodHit = true;
            this.kill();
        }

        if(noteType == '3' && !sustainPiece.alive)
        {
            visible = false;
            dead = true;
            kill();
        }

        if(couldHaveBeenHit && noteDiff > Conductor.safeZoneOffset && (noteType == '1' || noteType == '2'))
        {
            dead = true;
            currentSong.playstate.smNoteMiss(direction, this);
        }

        if(!dead)
        {
            if(noteDiff < Conductor.safeZoneOffset && (noteType == '1' || noteType == '2'))
            {
                canBeHit = true;
                couldHaveBeenHit = true;
            }
            else if(noteDiff < 25 && noteType == 'M')
            {
                canBeHit = true;
                couldHaveBeenHit = true;
            }
            else if(rootNote != null && rootNote.wasGoodHit && noteType == '0')
            {
                canBeHit = true;
                couldHaveBeenHit = true;
            }
            else if(y <= 100 && noteType == '3')
            {
                canBeHit = true;
                couldHaveBeenHit = true;
            }
            else 
            {
                canBeHit = false;
            }
        }

        if((noteType == '0' || noteType == '3') && rootNote.wasGoodHit)
        {
            color = 0xFFFFFF -
                0x10000 * Std.int(0xE5 * Math.abs(1.0 - PlayState.holdArray[direction].getNormalizedfBool())) -
                0x100 * Std.int(0xE5 * Math.abs(1.0 - PlayState.holdArray[direction].getNormalizedfBool())) -
                Std.int(0xE5 * Math.abs(1.0 - PlayState.holdArray[direction].getNormalizedfBool()));
        }
        if(dead)
        {
            if (color != 0x1A1A1A)
				color = 0x1A1A1A;
        }
        
        if(((y < 50 && !dead && noteType != 'M') || (y < 100 && !dead && noteType == '3')) && !currentSong.mustPressSong)
        {
            goodHit();
        }

        if(y < 0 - height && dead && (noteType == '1' || noteType == '2' || noteType == '3'))
        {
            visible = false;
            kill();
        }
    }

    // returns hit rating
    public function goodHit():String
    {
        trace('GOOD JARB');
        var noteDiff:Float = Math.abs(strumTime - currentSong.elapsedTime);
        var rating:String = 'shit';
        
        if(noteType == '1' || noteType == '2')
        {
            if(noteDiff > 105)
                rating = "shit";
            else if(noteDiff < -105)
                rating = "shit";
            else if(noteDiff > 80)
                rating = "bad";
            else if(noteDiff < -80)
                rating = "bad";
            else if(noteDiff > 55)
                rating = "good";
            else if(noteDiff < -55)
                rating = "good";
            else if(noteDiff > 30)
                rating = "cool";
            else if(noteDiff < -30)
                rating = "cool";
            else
                rating = "sick";
        }
        else if(noteType == 'M')
        {
            rating = 'boom';
        }
        else 
        {
            rating = 'sus';
        }

        if(noteType != '3' && noteType != '0')
        {
            #if debug
            trace('tick ' + getBeat());
            //FlxG.sound.play(Paths.sound('OPENITG_tick', 'shared'));
            #end
        }
        if(rating != 'sus')
            currentSong.playstate.popUpSMScore(rating, noteDiff, this);
        if(jumpID != -1 || currentSong.hitIDs.indexOf(jumpID) == -1)
        {
            currentSong.hitIDs.push(jumpID);
        }
        if(noteType != '0')
        {
            visible = false;
            dead = true;
            wasGoodHit = true;
            this.kill();
        }
        if(noteType == '3')
        {
            sustainPiece.visible = false;
            sustainPiece.dead = true;
            sustainPiece.wasGoodHit = true;
            sustainPiece.kill();
        }

        switch (direction)
        {
            case 2:
                currentSong.playstate.boyfriend.playAnim('singUP');
            case 3:
                currentSong.playstate.boyfriend.playAnim('singRIGHT');
            case 1:
                currentSong.playstate.boyfriend.playAnim('singDOWN');
            case 0:
                currentSong.playstate.boyfriend.playAnim('singLEFT');
        }
        currentSong.playstate.playerStrums.forEach(function(spr:FlxSprite)
        {
            if (Math.abs(direction) == spr.ID)
            {
                spr.animation.play('confirm', true);
            }
        });

        if(noteType == '1' || noteType == '2')
        {
            kill();
        }

        trace(rating);
        return rating;
    }

    public function getBeat():Float
    {
        return 4.0 * (this.section + (this.numerator / this.denominator));
    }

    public function generateSprite(useSMTheme = true):Void
    {
        if(useSMTheme && noteType != 'M')
        {
            frames = Paths.getSparrowAtlas('SM_NOTE_assets', 'shared');
            for(i in 0...48)
            {
                animation.addByPrefix(colors[Math.floor(i / 6)] + ' ' + anim[i % 6], colors[Math.floor(i / 6)] + ' ' + anim[i % 6]);
            }

            if(noteType != '3' && noteType != '0')
            {
                if(Math.floor(getBeat() * 48) == Math.ceil(getBeat() * 48))
                    smcolor = GRAY;
                if(Math.floor(getBeat() * 16) == Math.ceil(getBeat() * 16))
                    smcolor = CYAN;
                if(Math.floor(getBeat() * 12) == Math.ceil(getBeat() * 12))
                    smcolor = PINK;
                if(Math.floor(getBeat() * 8) == Math.ceil(getBeat() * 8))
                    smcolor = ORANGE;
                if(Math.floor(getBeat() * 6) == Math.ceil(getBeat() * 6))
                    smcolor = PURPLE;
                if(Math.floor(getBeat() * 4) == Math.ceil(getBeat() * 4))
                    smcolor = GREEN;
                if(Math.floor(getBeat() * 3) == Math.ceil(getBeat() * 3))
                    smcolor = PURPLE;
                if(Math.floor(getBeat() * 2) == Math.ceil(getBeat() * 2))
                    smcolor = BLUE;
                if(Math.floor(getBeat()) == Math.ceil(getBeat()))
                    smcolor = RED;
            }
            else
            {
                smcolor = rootNote.smcolor;
            }


            var suffix:String = "";
            if(noteType == '3')
                suffix = "hold end";
            else if(noteType == '0')
                suffix = "hold piece";
            else if(noteType == '1' || noteType == '2')
            {
                switch(direction)
                {
                    case 0:
                        suffix += "left ";
                    case 1: 
                        suffix += "down ";
                    case 2:
                        suffix += "up ";
                    case 3: 
                        suffix += "right ";
                }
                suffix += "arrow";
            }

            var prefix:String = "gray";

            switch(smcolor)
            {
                default: 
                    prefix = "gray";
                case RED:
                    prefix = "red";
                case BLUE:
                    prefix = "blue";
                case PURPLE:
                    prefix = "purple";
                case GREEN:
                    prefix = "green";
                case ORANGE: 
                    prefix = "orange";
                case PINK: 
                    prefix = "pink";
                case CYAN: 
                    prefix = "cyan";
                case GRAY: 
                    prefix = "gray";
            }

            animation.play(prefix + ' ' + suffix);
        }
        else
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
            else 
            {
                switch(direction)
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
        }
        updateHitbox();
        setGraphicSize(Std.int(width * 0.7));
        updateHitbox();
        antialiasing = true;

        x = 417 + 160 * direction * 0.7;

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

    }

    #if debug
    override public function kill():Void
    {
        trace('got killed');
        alive = false;
        exists = false;
    }
    #end
}