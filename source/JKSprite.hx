import flixel.group.FlxSpriteGroup;
import haxe.Timer;
import flixel.FlxSprite;

typedef JKFrames =
{
    var SPRITES:Array<FlxSprite>;
    var FRAMERATETIME:FrameRateTime;
};

class FrameRateTime
{
    public var frameTime:Float;
    public var FPS:Float;

    public function new()
    {
    }

    public function setFrameTime(frameTime)
    {
        this.frameTime = frameTime;
        this.FPS = 1.0 / frameTime;

        return this;
    }

    public function setFPS(FPS)
    {
        this.FPS = FPS;
        this.frameTime = 1.0 / FPS;

        return this;
    }
}

// My custom version of an animated sprite that doesn't require knowledge of Adobe Animate XML files
class JKSprite extends FlxSpriteGroup
{
    private var animations:Map<String, JKFrames>;

    private var elapsed:Float = 0.0;
    private var timer:Timer;
    private var currentAnimation:String;
    private var animIndex:Int = 0;

    public var animationPlaying:Bool = false;

    public function new(x:Float = 0, y:Float = 0)
    {
        super(x, y);

        animations = new Map<String, JKFrames>();
    }

    public function getCurAnim()
    {
        return currentAnimation;
    }

    public function generateAnim(name:String, frt:FrameRateTime)
    {
        if(frt == null)
        {
            frt = new FrameRateTime().setFPS(1);
        }
        if(!animations.exists(name))
        {
            animations.set(name, { SPRITES:new Array<FlxSprite>(), FRAMERATETIME:frt });
        }
        return this;
    }

    // If an animation already exists, the fps argument goes completely ignored
    public function addAnim(name:String, path:String, frt:FrameRateTime = null)
    {
        if(frt == null)
        {
            frt = new FrameRateTime().setFPS(1);
        }
        var newsprite:FlxSprite = new FlxSprite().loadGraphic(path);
        if(animations.exists(name))
        {
            animations.get(name).SPRITES.push(newsprite);
        }
        else 
        {
            animations.set(name, { SPRITES:new Array<FlxSprite>(), FRAMERATETIME:frt });
            animations.get(name).SPRITES.push(newsprite);
        }

        add(newsprite);
        newsprite.alpha = 0;

        return this;
    }

    // If an animation already exists, the fps argument goes completely ignored
    public function addAnims(name:String, paths:Array<String>, frt:FrameRateTime = null)
    {
        for(p in paths)
        {
            addAnim(name, p, frt);
        }
        return this;
    }

    public function play(name:String, loop:Bool = false)
    {
        if(animations.exists(name))
        {
            timer = new Timer(0);
            animIndex = 0;
            currentAnimation = name;
            animationPlaying = true;
            if(loop)
            {
                // repeat over and over
                timer.run = function()
                {
                    var curAnim = animations.get(currentAnimation);
                    if(curAnim.SPRITES.length > 0)
                    {
                        for(spr in curAnim.SPRITES)
                        {
                            spr.alpha = 0;
                        }

                        if(animIndex >= curAnim.SPRITES.length)
                        {
                            animIndex = 0;
                        }
                        curAnim.SPRITES[animIndex].alpha = 1;

                        if(elapsed >= curAnim.FRAMERATETIME.frameTime)
                        {
                            animIndex++;
                            elapsed -= curAnim.FRAMERATETIME.frameTime;
                        }

                        elapsed += 8.0 / 1000.0;
                    }
                };
            }
            else 
            {
                // dont repeat
                timer.run = function()
                {
                    var curAnim = animations.get(currentAnimation);
                    if(curAnim.SPRITES.length > 0)
                    {
                        for(spr in curAnim.SPRITES)
                        {
                            spr.alpha = 0;
                        }

                        if(animIndex >= curAnim.SPRITES.length)
                        {
                            animIndex = curAnim.SPRITES.length - 1;
                        }
                        curAnim.SPRITES[animIndex].alpha = 1;

                        if(elapsed >= curAnim.FRAMERATETIME.frameTime)
                        {
                            animIndex++;
                            elapsed -= curAnim.FRAMERATETIME.frameTime;
                        }

                        elapsed += 8.0 / 1000.0;
                    }
                };
            }
        }
        return this;
    }

    override function setGraphicSize(Width:Int = 0, Height:Int = 0)
    {
        for(anim in animations)
        {
            for(spr in anim.SPRITES)
            {
                spr.setGraphicSize(Width, Height);
                spr.updateHitbox();
            }
        }
    }
}