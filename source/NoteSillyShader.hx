import flixel.system.FlxAssets.FlxShader;
import sys.io.File;

class NoteSillyShader extends FlxShader 
{
    var totalElapsed:Float;
    var elapsedCoefficient:FuzzyBool = new FuzzyBool();

    @:glFragmentSource('
    #pragma header

    uniform float time;
    uniform float coefficient;

    void main()
    {
        vec2 coords = openfl_TextureCoordv;
        coords.x += 0.05 * coefficient * sin(12.56637061 * (openfl_TextureCoordv.y + time / 5.0));
        vec4 color = flixel_texture2D(bitmap, coords);
        
        gl_FragColor = vec4(color.r, color.g, color.b, color.a);
    }')

    public function new()
    {
        super();
    }

    public function update(elapsed:Float, ?startEffect:Bool = true)
    {
        totalElapsed += elapsed;
        if(startEffect)
            elapsedCoefficient.addTofBool(elapsed);
        else
            elapsedCoefficient.subFromfBool(elapsed);

        time.value = [totalElapsed];
        coefficient.value = [elapsedCoefficient.getNormalizedfBool()];
    }
}