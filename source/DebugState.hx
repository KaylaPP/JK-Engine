import JKSprite.FrameRateTime;
import openfl.filters.ShaderFilter;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;

class DebugState extends MusicBeatState
{
    private var figgleBottom:JKSprite;
    private var figgleCamera:FlxCamera;
    private var noteSillyShader:NoteSillyShader;

    private var totalElapsed:Float = 0.0;

    private var playedWhatDogDoesSound:Bool = false;
    private var playedRegularSound:Bool = false;
    
    public function new()
    {
        super();
    }

    override function create()
    {
        FlxG.save.data.NOTE_THEME = "vanilla";
        figgleCamera = new FlxCamera();
        noteSillyShader = new NoteSillyShader();
        figgleCamera.setFilters([ new ShaderFilter(noteSillyShader) ]);

        add(figgleCamera);

        FlxG.cameras.reset(figgleCamera);

        figgleBottom = new JKSprite().addAnims('default', Paths.themeanim("hit_tap_down", "receptors"), new FrameRateTime().setFPS(1)).play('default', true);
        figgleBottom.setOrigin(0, 0);
        figgleBottom.x = FlxG.width / 2;
        figgleBottom.y = FlxG.height / 2;
        figgleBottom.alpha = 1;
        //figgleBottom.setGraphicSize(20, 20);
        //figgleBottom.updateHitbox();

        add(figgleBottom);

        trace(Paths.themeanim('hit_tap_down', 'receptors'));
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        totalElapsed += elapsed;

        if(totalElapsed >= 1.0)
        {
            if(!playedWhatDogDoesSound)
            {
                FlxG.sound.play(Paths.sound("whatdogdoin", "shared"));
            }
            playedWhatDogDoesSound = true;
            if(totalElapsed >= 2.168)
            {
                noteSillyShader.update(elapsed, true);
                if(!playedRegularSound)
                {
                    FlxG.sound.play(Paths.sound("regular", "shared"));
                }
                playedRegularSound = true;
            }
        }

        if(FlxG.keys.justPressed.E)
        {
            FlxG.switchState(new TitleState());
        }
    }
}