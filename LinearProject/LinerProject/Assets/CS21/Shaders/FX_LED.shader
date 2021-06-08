// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FX_LED"
{
	Properties
	{
		_Emission("Emission", 2D) = "white" {}
		_Speed("Speed", Vector) = (0,0,0,0)
		_LED("LED", 2D) = "white" {}
		_Mask("Mask", 2D) = "white" {}
		_Distort("Distort", Float) = 0.35
		[HDR]_ScanlineColor("ScanlineColor", Color) = (0,0,0,0)
		_FlickingSpeed("FlickingSpeed", Float) = 1
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

		uniform sampler2D _LED;
		uniform float4 _LED_ST;
		uniform sampler2D _Emission;
		uniform float2 _Speed;
		uniform sampler2D _Mask;
		uniform float _FlickingSpeed;
		uniform float _Distort;
		uniform float4 _ScanlineColor;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_LED = i.uv_texcoord * _LED_ST.xy + _LED_ST.zw;
			float4 tex2DNode398 = tex2D( _LED, uv_LED );
			o.Albedo = tex2DNode398.rgb;
			float2 panner360 = ( 1.0 * _Time.y * float2( 7,9 ) + i.uv_texcoord);
			float mulTime381 = _Time.y * _FlickingSpeed;
			float temp_output_362_0 = ( mulTime381 * 60.0 );
			float clampResult372 = clamp( ( sin( ( temp_output_362_0 * 0.7 ) ) + sin( temp_output_362_0 ) + sin( ( temp_output_362_0 * 1.3 ) ) + sin( ( temp_output_362_0 * 2.5 ) ) ) , 0.0 , 1.0 );
			float Flicking1377 = clampResult372;
			float NoiseGlitch386 = ( ( tex2D( _Mask, panner360 ).b * Flicking1377 ) * _Distort );
			float2 panner401 = ( 1.0 * _Time.y * _Speed + ( i.uv_texcoord + NoiseGlitch386 ));
			float2 panner337 = ( 1.0 * _Time.y * float2( 0,0.5 ) + i.uv_texcoord);
			float Scanline389 = tex2D( _Mask, panner337 ).r;
			float SmallScanline391 = tex2D( _Mask, i.uv_texcoord ).g;
			float mulTime382 = _Time.y * _FlickingSpeed;
			float temp_output_343_0 = ( mulTime382 * 20.0 );
			float clampResult349 = clamp( ( sin( ( temp_output_343_0 * 0.7 ) ) + sin( temp_output_343_0 ) + sin( ( temp_output_343_0 * 1.3 ) ) + sin( ( temp_output_343_0 * 2.5 ) ) ) , 0.7 , 1.0 );
			float Flicking2383 = clampResult349;
			o.Emission = ( tex2DNode398 + ( tex2D( _Emission, panner401 ) + ( ( Scanline389 + ( ( SmallScanline391 * Flicking2383 ) * 0.5 ) ) * _ScanlineColor ) ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
7;29;1906;1044;4107.478;996.8881;1.165845;True;False
Node;AmplifyShaderEditor.RangedFloatNode;412;-3424.292,-801.0259;Inherit;False;Property;_FlickingSpeed;FlickingSpeed;6;0;Create;True;0;0;False;0;False;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;376;-3168.742,-957.4957;Inherit;False;1478.181;456.7979;Flicking 1;12;372;370;366;369;368;367;364;363;365;362;377;381;Flicking 1;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;381;-3092.7,-812.3933;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;362;-2855.554,-811.9878;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;60;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;363;-2641.45,-712.9337;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;364;-2644.919,-619.4358;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;380;-3165.806,-419.4178;Inherit;False;1476.656;510.4567;Flicking 2;12;383;382;349;346;350;351;344;345;347;352;343;348;Flicking 2;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;365;-2652.28,-898.6644;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;367;-2468.262,-897.9009;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;366;-2462.615,-615.8647;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;382;-3129.9,-247.7932;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;368;-2460.407,-711.886;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;369;-2464.642,-810.5089;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;370;-2288.782,-807.5967;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;343;-2943.808,-247.622;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;394;-1621.136,-944.5485;Inherit;False;1521.079;1003.685;Mask;15;359;360;379;358;371;375;374;386;390;388;356;337;391;338;389;Mask;0,0.5448277,1,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;372;-2064.506,-808.5769;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;346;-2731.053,-66.27457;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;350;-2728.704,-164.2541;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;352;-2739.535,-330.5138;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;359;-1540.435,-346.703;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;348;-2553.255,-325.9657;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;344;-2552.392,-76.73057;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;360;-1244.048,-343.2968;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;7,9;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SinOpNode;345;-2551.896,-246.143;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;347;-2548.923,-170.2284;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;377;-1901.372,-800.7596;Inherit;False;Flicking1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;390;-1535.21,-620.3738;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;379;-942.1599,-125.9659;Inherit;False;377;Flicking1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;351;-2352.439,-246.0691;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;358;-1034.197,-368.4218;Inherit;True;Property;_asdasd;asdasd;3;0;Create;True;0;0;False;0;False;-1;None;8714712f4d4a886488df03a7007d0adc;True;0;False;white;Auto;False;Instance;338;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;371;-706.7229,-222.6143;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;356;-1026.987,-651.5762;Inherit;True;Property;_TextureSample4;Texture Sample 4;3;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;338;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;349;-2109.791,-245.2602;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.7;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;388;-1571.136,-855.5356;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;375;-744.1649,-55.86317;Float;False;Property;_Distort;Distort;4;0;Create;True;0;0;False;0;False;0.35;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;391;-600.9288,-604.863;Inherit;False;SmallScanline;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;383;-1917.236,-251.5832;Inherit;False;Flicking2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;337;-1265.551,-858.5044;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.5;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;374;-514.0249,-221.8956;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;384;761.3951,-277.7769;Inherit;False;383;Flicking2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;386;-343.0564,-227.8445;Inherit;False;NoiseGlitch;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;338;-1039.76,-886.5485;Inherit;True;Property;_Mask;Mask;3;0;Create;True;0;0;False;0;False;-1;None;8714712f4d4a886488df03a7007d0adc;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;392;726.0054,-372.9382;Inherit;False;391;SmallScanline;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;354;1017.29,-370.9617;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;396;1021.613,-224.9757;Inherit;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;311;481.1893,-788.366;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;387;506.1894,-654.3658;Inherit;False;386;NoiseGlitch;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;389;-595.4159,-863.1073;Inherit;False;Scanline;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;402;756.8709,-631.5497;Inherit;False;Property;_Speed;Speed;1;0;Create;True;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;395;1220.785,-375.1453;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;361;818.1894,-788.366;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;393;1160.344,-564.4161;Inherit;False;389;Scanline;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;405;1378.46,-495.8179;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;407;1271.46,-245.8179;Inherit;False;Property;_ScanlineColor;ScanlineColor;5;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0.07374566,0.3569384,0.9117647,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;401;1005.864,-773.956;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;400;1126.198,-1156.399;Inherit;False;0;398;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;397;1223.463,-808.655;Inherit;True;Property;_Emission;Emission;0;0;Create;True;0;0;False;0;False;-1;None;22d37b6b0be35bb45a0e322755f0b58b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;406;1521.46,-493.8179;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;408;1703.759,-761.0179;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;398;1410.688,-1175.858;Inherit;True;Property;_LED;LED;2;0;Create;True;0;0;False;0;False;-1;None;0d03e934ec665394395cecb6d54d29cb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;411;2003.362,-782.4707;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2287.234,-833.3335;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;FX_LED;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;3;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;381;0;412;0
WireConnection;362;0;381;0
WireConnection;363;0;362;0
WireConnection;364;0;362;0
WireConnection;365;0;362;0
WireConnection;367;0;365;0
WireConnection;366;0;364;0
WireConnection;382;0;412;0
WireConnection;368;0;363;0
WireConnection;369;0;362;0
WireConnection;370;0;367;0
WireConnection;370;1;369;0
WireConnection;370;2;368;0
WireConnection;370;3;366;0
WireConnection;343;0;382;0
WireConnection;372;0;370;0
WireConnection;346;0;343;0
WireConnection;350;0;343;0
WireConnection;352;0;343;0
WireConnection;348;0;352;0
WireConnection;344;0;346;0
WireConnection;360;0;359;0
WireConnection;345;0;343;0
WireConnection;347;0;350;0
WireConnection;377;0;372;0
WireConnection;351;0;348;0
WireConnection;351;1;345;0
WireConnection;351;2;347;0
WireConnection;351;3;344;0
WireConnection;358;1;360;0
WireConnection;371;0;358;3
WireConnection;371;1;379;0
WireConnection;356;1;390;0
WireConnection;349;0;351;0
WireConnection;391;0;356;2
WireConnection;383;0;349;0
WireConnection;337;0;388;0
WireConnection;374;0;371;0
WireConnection;374;1;375;0
WireConnection;386;0;374;0
WireConnection;338;1;337;0
WireConnection;354;0;392;0
WireConnection;354;1;384;0
WireConnection;389;0;338;1
WireConnection;395;0;354;0
WireConnection;395;1;396;0
WireConnection;361;0;311;0
WireConnection;361;1;387;0
WireConnection;405;0;393;0
WireConnection;405;1;395;0
WireConnection;401;0;361;0
WireConnection;401;2;402;0
WireConnection;397;1;401;0
WireConnection;406;0;405;0
WireConnection;406;1;407;0
WireConnection;408;0;397;0
WireConnection;408;1;406;0
WireConnection;398;1;400;0
WireConnection;411;0;398;0
WireConnection;411;1;408;0
WireConnection;0;0;398;0
WireConnection;0;2;411;0
ASEEND*/
//CHKSM=EA095A85CE120C29D6D6A6A078849C7B1457E80F