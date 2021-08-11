import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxSprite;

class CustomKeybindSubstate extends MusicBeatSubstate
{
    public static var bindStrs:Array<String> = 
    [
        'LEFT',
        'DOWN',
        'UP',
        'RIGHT',
        'ACCEPT',
        'BACK',
        'RESET'
    ];
    private var bindNames:Array<Alphabet>;
    private var currentKeyBinds:Array<FlxText>;
    private var keybindIndex:Int = 0;
    private var key:FlxKey;

    private var binding:Bool = false;
    private var skipbind:Bool = false;

    public function new()
    {
        super();

        var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

        // space all lines by 70 pixels
        bindNames = new Array<Alphabet>();
        for(i in 0...bindStrs.length)
        {
            trace(110 + i * 70);
            bindNames.push(new Alphabet(0, 110 + i * 70, bindStrs[i], true, false));
        }
        for(spr in bindNames)
        {
            spr.x = 50;
            add(spr);
        }

        // make key x 500 pixels
        var tempindex:Int = -1;
        currentKeyBinds = new Array<FlxText>();
        var keybind:FlxKey = FlxG.save.data.KEY_LEFT;
        currentKeyBinds.push(new FlxText(0, 187 + tempindex++ * 70, 0, keybind.toString(), 56));

        var keybind:FlxKey = FlxG.save.data.KEY_DOWN;
        currentKeyBinds.push(new FlxText(0, 187 + tempindex++ * 70, 0, keybind.toString(), 56));

        var keybind:FlxKey = FlxG.save.data.KEY_UP;
        currentKeyBinds.push(new FlxText(0, 187 + tempindex++ * 70, 0, keybind.toString(), 56));

        var keybind:FlxKey = FlxG.save.data.KEY_RIGHT;
        currentKeyBinds.push(new FlxText(0, 187 + tempindex++ * 70, 0, keybind.toString(), 56));

        var keybind:FlxKey = FlxG.save.data.KEY_ACCEPT;
        currentKeyBinds.push(new FlxText(0, 187 + tempindex++ * 70, 0, keybind.toString(), 56));

        var keybind:FlxKey = FlxG.save.data.KEY_BACK;
        currentKeyBinds.push(new FlxText(0, 187 + tempindex++ * 70, 0, keybind.toString(), 56));

        var keybind:FlxKey = FlxG.save.data.KEY_RESET;
        currentKeyBinds.push(new FlxText(0, 187 + tempindex++ * 70, 0, keybind.toString(), 56));

        for(kb in currentKeyBinds)
        {
            kb.x = 500;
            add(kb);
        }
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        for(t in currentKeyBinds)
        {
            t.color = 0xFF000000;
        }

        skipbind = false;

        if(key != FlxG.keys.firstPressed())
        {
            key = FlxG.keys.firstPressed();
            if(key.toString() != null)
                trace(key.toString());
            else
                trace('RELEASED');
        }

        for(i in 0...bindStrs.length)
        {
            if(i != keybindIndex)
            {
                bindNames[i].alpha = 0.6;
                currentKeyBinds[i].alpha = 0.6;
            }
            else 
            {
                bindNames[i].alpha = 1.0;
                currentKeyBinds[i].alpha = 1.0;
            }
        }
        if(FlxG.keys.justPressed.DOWN && !binding)
        {
            keybindIndex++;
        }
        if(FlxG.keys.justPressed.UP && !binding)
        {
            keybindIndex--;
        }
        if(keybindIndex < 0)
        {
            keybindIndex = bindStrs.length - 1;
        }
        if(keybindIndex >= bindStrs.length)
        {
            keybindIndex = 0;
        }
        
        if(FlxG.keys.justPressed.ESCAPE)
        {
            if(!binding)
            {
                var tempKeyIndex:Int = -1;
                key = currentKeyBinds[++tempKeyIndex].text;
                FlxG.save.data.KEY_LEFT = key;

                key = currentKeyBinds[++tempKeyIndex].text;
                FlxG.save.data.KEY_DOWN = key;

                key = currentKeyBinds[++tempKeyIndex].text;
                FlxG.save.data.KEY_UP = key;

                key = currentKeyBinds[++tempKeyIndex].text;
                FlxG.save.data.KEY_RIGHT = key;

                key = currentKeyBinds[++tempKeyIndex].text;
                FlxG.save.data.KEY_ACCEPT = key;

                key = currentKeyBinds[++tempKeyIndex].text;
                FlxG.save.data.KEY_BACK = key;

                key = currentKeyBinds[++tempKeyIndex].text;
                FlxG.save.data.KEY_RESET = key;

                controls.setKeyboardScheme(Controls.KeyboardScheme.None, true);

                controls.bindKeys(UP, [FlxG.save.data.KEY_UP, FlxKey.UP]);
                controls.bindKeys(LEFT, [FlxG.save.data.KEY_LEFT, FlxKey.LEFT]);
                controls.bindKeys(DOWN, [FlxG.save.data.KEY_DOWN, FlxKey.DOWN]);
                controls.bindKeys(RIGHT, [FlxG.save.data.KEY_RIGHT, FlxKey.RIGHT]);
                controls.bindKeys(ACCEPT, [FlxG.save.data.KEY_ACCEPT]);
                controls.bindKeys(BACK, [FlxG.save.data.KEY_BACK]);
                controls.bindKeys(RESET, [FlxG.save.data.KEY_RESET]);
                close();
            }
        }

        if(FlxG.keys.justPressed.ENTER)
        {
            if(!binding)
            {
                binding = true;
                currentKeyBinds[keybindIndex].text = "_";
                skipbind = true;
            }
        }

        if(FlxG.keys.firstJustPressed() != -1 && binding && !skipbind)
        {
            binding = false;
            key = FlxG.keys.firstJustPressed();
            currentKeyBinds[keybindIndex].text = key.toString();
        }
    }
}
