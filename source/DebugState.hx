import JKSprite.FrameRateTime;
import openfl.filters.ShaderFilter;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;

class DebugState extends FlxState
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
        //figgleCamera.setFilters([ new ShaderFilter(noteSillyShader) ]);

        add(figgleCamera);

        FlxG.cameras.reset(figgleCamera);

        add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height));

        figgleBottom = new JKSprite();
        figgleBottom.addAnim('static', Paths.themeimage('idle_left', 'receptors', FlxG.save.data.NOTE_THEME), new FrameRateTime().setFPS(1));
        figgleBottom.addAnims('pressed', Paths.themeanim('miss_tap_left', 'receptors', FlxG.save.data.NOTE_THEME), new FrameRateTime().setFPS(24));
        figgleBottom.addAnims('confirm', Paths.themeanim('hit_tap_left', 'receptors', FlxG.save.data.NOTE_THEME), new FrameRateTime().setFPS(24));
        figgleBottom.play('static');
        figgleBottom.setOrigin(0, 0);
        figgleBottom.alpha = 1;
        //figgleBottom.setGraphicSize(20, 20);
        figgleBottom.updateHitbox();
        figgleBottom.setRootSprite('static', 0);
        figgleBottom.x = FlxG.width / 2;
        figgleBottom.y = FlxG.height / 2;
        figgleBottom.scaleBy(2);
        figgleBottom.antialiasing = true;

        add(figgleBottom);

        trace(Paths.themeanim('hit_tap_down', 'receptors'));
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        figgleBottom.alpha = FlxG.mouse.getPosition().y / FlxG.height;

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

        if(FlxG.keys.justPressed.D)
        {
            figgleBottom.play('pressed');
        }
        else if(FlxG.keys.justPressed.F)
        {
            figgleBottom.play('confirm');
        }
        else if(FlxG.keys.justReleased.ANY)
        {
            figgleBottom.play('static');
        }

        if(FlxG.keys.justPressed.E)
        {
            FlxG.switchState(new TitleState());
        }
    }
}