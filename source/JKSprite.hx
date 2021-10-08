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

    private var fallback:String = "";

    private var elapsed:Float = 0.0;
    private var currentAnimation:String;
    private var animIndex:Int = 0;
    private var looping:Bool = false;
    private var stoppingOnEnd:Bool = false;

    private var timer:Timer;

    public var animationPlaying:Bool = false;

    public function new(x:Float = 0, y:Float = 0)
    {
        super(x, y);
        currentAnimation = "";
        timer = new Timer(0);
        animations = new Map<String, JKFrames>();
    }

    override function update(elapsed:Float)
    {
        #if debug
        var wtf:Bool = true;
        for(anim in animations)
        {
            for(spr in anim.SPRITES)
            {
                if(spr.alpha > 0)
                    wtf = false;
            }
        }
        if(wtf && currentAnimation != '')
        {
            trace('ALL SPRITES ARE INVISIBLE DESPTIE CURANIM ' + currentAnimation);
            trace(animIndex);
        }
        #end

        var curAnim = animations.get(currentAnimation);

        if(curAnim != null && curAnim.SPRITES != null && curAnim.SPRITES.length > 0)
        {
            for(spr in curAnim.SPRITES)
            {
                spr.alpha = 0;
            }

            if(animIndex >= curAnim.SPRITES.length)
            {
                if(looping)
                {
                    animIndex = 0;
                }
                else if(stoppingOnEnd)
                {
                    animIndex = 0;
                    currentAnimation = "";
                    animationPlaying = false;
                    timer.stop();
                    play(fallback);
                    trace('playing fallback');
                }
                else 
                {
                    animIndex = curAnim.SPRITES.length - 1;
                }
            }
            curAnim.SPRITES[animIndex].alpha = 1;

            while(elapsed >= curAnim.FRAMERATETIME.frameTime)
            {
                animIndex++;
                elapsed -= curAnim.FRAMERATETIME.frameTime;
            }
        }

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

    public function play(name:String, loop:Bool = false, stopOnEnd:Bool = false)
    {
        if(loop)
            stopOnEnd = true;

        if(animations.exists(name))
        {
            elapsed = 0.0;

            timer.run = function(){ elapsed += 8.0 / 1000.0; };

            currentAnimation = name;
            this.looping = loop;
            this.stoppingOnEnd = stopOnEnd;

            for(anim in animations)
            {
                for(spr in anim.SPRITES)
                {
                    spr.alpha = 0;
                }
            }

            animIndex = 0;
            animationPlaying = true;

            animations.get(currentAnimation).SPRITES[animIndex].alpha = 1;
        }
        return this;
    }

    public function setFallBackAnim(anim:String)
    {
        if(animations.exists(anim))
        {
            fallback = anim;
        }
    }

    override function setGraphicSize(Width:Int = 0, Height:Int = 0)
    {
        for(anim in animations)
        {
            for(spr in anim.SPRITES)
            {
                spr.setGraphicSize(Width, Height);
            }
        }
    }

    override function updateHitbox()
    {
        for(anim in animations)
        {
            for(spr in anim.SPRITES)
            {
                spr.updateHitbox();
            }
        }

        super.updateHitbox();
    }

    // X and Y are floats on the inclusive range [-1.0, 1.0] where (-1.0, -1.0) is top left, (0.0, 0.0) is center, and (1.0, 1.0) is bottom right
    public function setOrigin(X:Float, Y:Float)
    {
        var rootCenterX:Float = 0;
        var rootCenterY:Float = 0;
        var rootSpr:FlxSprite = null;

        for(anim in animations)
        {
            if(rootSpr == null)
            {
                rootSpr = anim.SPRITES[0];
            }
            for(spr in anim.SPRITES)
            {
                var sprCenterX:Float = spr.width / 2.0 + X * spr.width / 2.0;
                var sprCenterY:Float = spr.height / 2.0 + Y * spr.height / 2.0;

                var CenterDeltaX:Float = rootCenterX - sprCenterX;
                var CenterDeltaY:Float = rootCenterY - sprCenterY;

                spr.x += CenterDeltaX;
                spr.y += CenterDeltaY;
            }
        }
    }

    // Sets the origin of each sprite to the origin of the given sprite
    public function setRootSprite(animation:String, frame:Int)
    {
        if(frame >= animations.get(animation).SPRITES.length)
            frame = animations.get(animation).SPRITES.length - 1;
        var rootSpr:FlxSprite = animations.get(animation).SPRITES[frame];

        for(anim in animations)
        {
            for(spr in anim.SPRITES)
            {
                var dX:Float = x - rootSpr.x;
                var dY:Float = y - rootSpr.y;

                spr.x -= dX;
                spr.y -= dY;
            }
        }
    }

    // If you keep one value at zero, the whole thing will scale by the other factor
    // Essentially, scaleBy(0.7) is the same as scaleBy(0.7, 0.7)
    public function scaleBy(XScale:Float = 0, YScale:Float = 0)
    {
        XScale = YScale == 0 ? XScale : YScale;
        YScale = XScale == 0 ? YScale : XScale;
        for(anim in animations)
        {
            for(spr in anim.SPRITES)
            {
                var oldCenterX:Float = spr.width / 2.0;
                var oldCenterY:Float = spr.height / 2.0;

                spr.setGraphicSize(Math.ceil(spr.width * XScale), Math.ceil(spr.height * YScale));
                spr.updateHitbox();

                var newCenterX:Float = spr.width / 2.0;
                var newCenterY:Float = spr.height / 2.0;

                spr.x += oldCenterX - newCenterX;
                spr.y += oldCenterY - newCenterY;
            }
        }
    }
}
