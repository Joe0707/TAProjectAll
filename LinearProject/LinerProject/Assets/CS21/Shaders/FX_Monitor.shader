// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FX_Monitor"
{
	Properties
	{
		_Emission("Emission", 2D) = "white" {}
		_Background("Background", Color) = (0,0,0,0)
		_EmissColor("EmissColor", Color) = (1,1,1,0)
		_AlbedoPower("Albedo Power", Float) = 0
		_EmissionPower("Emission Power", Float) = 0
		_Mask("Mask", 2D) = "white" {}
		_Distort("Distort", Float) = 0.35
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		ZTest LEqual
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _AlbedoPower;
		uniform float4 _Background;
		uniform float4 _EmissColor;
		uniform sampler2D _Emission;
		uniform sampler2D _Mask;
		uniform float _Distort;
		uniform float _EmissionPower;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 panner360 = ( 1.0 * _Time.y * float2( 7,9 ) + i.uv_texcoord);
			float temp_output_362_0 = ( _Time.y * 60.0 );
			float clampResult372 = clamp( ( sin( ( temp_output_362_0 * 0.7 ) ) + sin( temp_output_362_0 ) + sin( ( temp_output_362_0 * 1.3 ) ) + sin( ( temp_output_362_0 * 2.5 ) ) ) , 0.0 , 1.0 );
			float Flicking1377 = clampResult372;
			float NoiseGlitch386 = ( ( tex2D( _Mask, panner360 ).b * Flicking1377 ) * _Distort );
			float2 temp_output_361_0 = ( i.uv_texcoord + NoiseGlitch386 );
			float4 tex2DNode308 = tex2D( _Emission, temp_output_361_0 );
			float2 panner312 = ( 1.0 * _Time.y * float2( 0,0.2 ) + temp_output_361_0);
			float2 panner331 = ( 1.0 * _Time.y * float2( -0.2,0 ) + temp_output_361_0);
			float2 panner337 = ( 1.0 * _Time.y * float2( 0,0.5 ) + i.uv_texcoord);
			float Scanline389 = tex2D( _Mask, panner337 ).r;
			float SmallScanline391 = tex2D( _Mask, i.uv_texcoord ).g;
			float temp_output_343_0 = ( _Time.y * 20.0 );
			float clampResult349 = clamp( ( sin( ( temp_output_343_0 * 0.7 ) ) + sin( temp_output_343_0 ) + sin( ( temp_output_343_0 * 1.3 ) ) + sin( ( temp_output_343_0 * 2.5 ) ) ) , 0.7 , 1.0 );
			float Flicking2383 = clampResult349;
			float4 lerpResult335 = lerp( _Background , _EmissColor , ( ( ( tex2DNode308.r + ( ( tex2DNode308.g * tex2D( _Emission, panner312 ).a ) + ( tex2DNode308.b * tex2D( _Emission, panner331 ).a ) ) ) + Scanline389 ) + ( ( SmallScanline391 * Flicking2383 ) * 0.5 ) ));
			o.Albedo = ( _AlbedoPower * lerpResult335 ).rgb;
			o.Emission = ( lerpResult335 * _EmissionPower ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
7;29;1906;1044;1932.56;880.0795;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;376;-3796.664,-1005.307;Inherit;False;1478.181;456.7979;Flicking 1;12;372;370;366;369;368;367;364;363;365;362;377;381;Flicking 1;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;381;-3720.622,-860.2046;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;362;-3483.476,-859.7991;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;60;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;363;-3269.372,-760.745;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;364;-3272.841,-667.2471;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;365;-3280.202,-946.4757;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;366;-3090.537,-663.676;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;368;-3088.329,-759.6973;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;369;-3092.564,-858.3201;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;367;-3096.184,-945.7122;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;394;-2249.058,-992.3598;Inherit;False;1521.079;1003.685;Mask;15;359;360;379;358;371;375;374;386;390;388;356;337;391;338;389;Mask;0,0.5448277,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;370;-2916.704,-855.408;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;372;-2692.428,-856.3882;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;359;-2168.357,-394.5144;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;377;-2529.294,-848.5709;Inherit;False;Flicking1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;360;-1871.97,-391.1082;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;7,9;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;379;-1570.082,-173.7772;Inherit;False;377;Flicking1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;358;-1662.119,-416.2332;Inherit;True;Property;_asdasd;asdasd;5;0;Create;True;0;0;False;0;False;-1;None;8714712f4d4a886488df03a7007d0adc;True;0;False;white;Auto;False;Instance;338;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;380;-3793.728,-467.2292;Inherit;False;1476.656;510.4567;Flicking 2;12;383;382;349;346;350;351;344;345;347;352;343;348;Flicking 2;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;371;-1334.645,-270.4257;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;375;-1372.087,-103.6745;Float;False;Property;_Distort;Distort;6;0;Create;True;0;0;False;0;False;0.35;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;382;-3757.822,-295.6046;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;374;-1141.947,-269.7069;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;386;-970.9786,-275.6558;Inherit;False;NoiseGlitch;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;343;-3571.73,-295.4334;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;352;-3367.457,-378.3252;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;350;-3356.626,-212.0654;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;311;-597.0857,-642.7143;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;387;-572.0857,-508.7143;Inherit;False;386;NoiseGlitch;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;346;-3358.975,-114.0859;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;344;-3180.314,-124.5419;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;345;-3179.818,-293.9543;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;361;-260.0857,-642.7143;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SinOpNode;347;-3176.845,-218.0397;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;348;-3181.177,-373.7771;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;351;-2980.361,-293.8804;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;388;-2199.058,-903.3469;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;331;33.83107,-158.9648;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.2,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;312;35.19587,-376.9531;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.2;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;390;-2163.132,-668.1851;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;330;263.8311,-184.9648;Inherit;True;Property;_TextureSample2;Texture Sample 2;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;308;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;337;-1893.473,-906.3157;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.5;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;308;258.3858,-667.6701;Inherit;True;Property;_Emission;Emission;0;0;Create;True;0;0;False;0;False;-1;None;ad60ea0298b7fb44fb46d84220ab784e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;356;-1654.909,-699.3875;Inherit;True;Property;_TextureSample4;Texture Sample 4;5;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;338;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;302;266.8311,-405.9648;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;308;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;349;-2737.713,-293.0716;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.7;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;383;-2545.158,-299.3946;Inherit;False;Flicking2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;338;-1667.682,-934.3598;Inherit;True;Property;_Mask;Mask;5;0;Create;True;0;0;False;0;False;-1;None;8714712f4d4a886488df03a7007d0adc;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;391;-1228.851,-652.6743;Inherit;False;SmallScanline;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;326;661.4212,-469.7923;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;332;662.2791,-270.4518;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;389;-1223.338,-910.9186;Inherit;False;Scanline;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;333;843.5388,-469.987;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;392;741.0054,-116.9382;Inherit;False;391;SmallScanline;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;384;776.3951,-21.77695;Inherit;False;383;Flicking2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;354;1032.29,-114.9617;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;396;1036.613,31.02431;Inherit;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;334;1048.136,-633.0021;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;393;989.3445,-407.4161;Inherit;False;389;Scanline;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;395;1235.785,-119.1453;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;339;1246.041,-547.7144;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;304;1466.508,-1035.995;Float;False;Property;_Background;Background;1;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;357;1449.714,-545.3312;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;306;1470.388,-792.8857;Float;False;Property;_EmissColor;EmissColor;2;0;Create;True;0;0;False;0;False;1,1,1,0;0,0.6689658,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;323;1683.938,-545.0815;Float;False;Property;_EmissionPower;Emission Power;4;0;Create;True;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;335;1734.406,-809.0354;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;325;1744.504,-999.7843;Float;False;Property;_AlbedoPower;Albedo Power;3;0;Create;True;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;324;2048.921,-831.4172;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;322;1997.012,-565.2516;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2287.234,-833.3335;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;FX_Monitor;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;3;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;362;0;381;0
WireConnection;363;0;362;0
WireConnection;364;0;362;0
WireConnection;365;0;362;0
WireConnection;366;0;364;0
WireConnection;368;0;363;0
WireConnection;369;0;362;0
WireConnection;367;0;365;0
WireConnection;370;0;367;0
WireConnection;370;1;369;0
WireConnection;370;2;368;0
WireConnection;370;3;366;0
WireConnection;372;0;370;0
WireConnection;377;0;372;0
WireConnection;360;0;359;0
WireConnection;358;1;360;0
WireConnection;371;0;358;3
WireConnection;371;1;379;0
WireConnection;374;0;371;0
WireConnection;374;1;375;0
WireConnection;386;0;374;0
WireConnection;343;0;382;0
WireConnection;352;0;343;0
WireConnection;350;0;343;0
WireConnection;346;0;343;0
WireConnection;344;0;346;0
WireConnection;345;0;343;0
WireConnection;361;0;311;0
WireConnection;361;1;387;0
WireConnection;347;0;350;0
WireConnection;348;0;352;0
WireConnection;351;0;348;0
WireConnection;351;1;345;0
WireConnection;351;2;347;0
WireConnection;351;3;344;0
WireConnection;331;0;361;0
WireConnection;312;0;361;0
WireConnection;330;1;331;0
WireConnection;337;0;388;0
WireConnection;308;1;361;0
WireConnection;356;1;390;0
WireConnection;302;1;312;0
WireConnection;349;0;351;0
WireConnection;383;0;349;0
WireConnection;338;1;337;0
WireConnection;391;0;356;2
WireConnection;326;0;308;2
WireConnection;326;1;302;4
WireConnection;332;0;308;3
WireConnection;332;1;330;4
WireConnection;389;0;338;1
WireConnection;333;0;326;0
WireConnection;333;1;332;0
WireConnection;354;0;392;0
WireConnection;354;1;384;0
WireConnection;334;0;308;1
WireConnection;334;1;333;0
WireConnection;395;0;354;0
WireConnection;395;1;396;0
WireConnection;339;0;334;0
WireConnection;339;1;393;0
WireConnection;357;0;339;0
WireConnection;357;1;395;0
WireConnection;335;0;304;0
WireConnection;335;1;306;0
WireConnection;335;2;357;0
WireConnection;324;0;325;0
WireConnection;324;1;335;0
WireConnection;322;0;335;0
WireConnection;322;1;323;0
WireConnection;0;0;324;0
WireConnection;0;2;322;0
ASEEND*/
//CHKSM=74F3983192F6A0BF49360C7778D6810945545809