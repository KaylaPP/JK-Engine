import flixel.FlxG;

class NoteThemeCFG
{
    public var stepColored:Bool;

    public var noteDistance:Float;

    public var noteScale:Float;

    public var spriteXOrigin:Float;
    public var spriteYOrigin:Float;

    public var animateExplosions:Bool;
    public var doExplosionSound:Bool;
    public var explosionDuration:Float;

    public var tileSustainPiece:Bool;

    public var framerate:Int;

    public function new()
    {

    }
}

class NoteTheme
{
    private static var cfg:NoteThemeCFG;
    private static var curTheme:String;

    private static function updateCFG():Void
    {
        if(FlxG.save.data.NOTE_THEME != curTheme)
        {
            curTheme = FlxG.save.data.NOTE_THEME;

            cfg = new NoteThemeCFG();

            var CFG:Array<String> = Paths.themecfg();
            for(line in CFG)
            {
                while(line.charAt(0) == ' ' || line.charAt(0) == '\t')
                {
                    line = line.substr(1);
                }

                if(line.charAt(0) != '#')
                {
                    if(line.indexOf('step-colored') != -1)
                    {
                        line = line.substr(line.indexOf('=') + 1);
                        if(line.indexOf('false') != -1)
                        {
                            cfg.stepColored = false;
                        }
                        if(line.indexOf('true') != -1)
                        {
                            cfg.stepColored = true;
                        }
                    }
                    if(line.indexOf('note-distance') != -1)
                    {
                        line = line.substr(line.indexOf('=') + 1);
                        cfg.noteDistance = Std.parseFloat(line);
                    }
                    if(line.indexOf('note-scale') != -1)
                    {
                        line = line.substr(line.indexOf('=') + 1);
                        cfg.noteScale = Std.parseFloat(line);
                    }
                    if(line.indexOf('sprite-X-origin') != -1)
                    {
                        line = line.substr(line.indexOf('=') + 1);
                        cfg.spriteXOrigin = Std.parseFloat(line);
                    }
                    if(line.indexOf('sprite-Y-origin') != -1)
                    {
                        line = line.substr(line.indexOf('=') + 1);
                        cfg.spriteXOrigin = Std.parseFloat(line);
                    }
                    if(line.indexOf('animate-explosion') != -1)
                    {
                        line = line.substr(line.indexOf('=') + 1);
                        if(line.indexOf('false') != -1)
                        {
                            cfg.animateExplosions = false;
                        }
                        if(line.indexOf('true') != -1)
                        {
                            cfg.animateExplosions = true;
                        }
                    }
                    if(line.indexOf('do-explosion-sound') != -1)
                    {
                        line = line.substr(line.indexOf('=') + 1);
                        if(line.indexOf('false') != -1)
                        {
                            cfg.doExplosionSound = false;
                        }
                        if(line.indexOf('true') != -1)
                        {
                            cfg.doExplosionSound = true;
                        }
                    }
                    if(line.indexOf('explosion-duration') != -1)
                    {
                        line = line.substr(line.indexOf('=') + 1);
                        cfg.explosionDuration = Std.parseFloat(line);
                    }
                    if(line.indexOf('tile-sustainpieces') != -1)
                    {
                        line = line.substr(line.indexOf('=') + 1);
                        if(line.indexOf('false') != -1)
                        {
                            cfg.tileSustainPiece = false;
                        }
                        if(line.indexOf('true') != -1)
                        {
                            cfg.tileSustainPiece = true;
                        }
                    }
                    if(line.indexOf('framerate') != -1)
                    {
                        line = line.substr(line.indexOf('=') + 1);
                        cfg.framerate = Std.parseInt(line);
                    }

                }
            }
        }
    }

    public static function getCFG():NoteThemeCFG
    {
        updateCFG();
        return cfg;
    }
}