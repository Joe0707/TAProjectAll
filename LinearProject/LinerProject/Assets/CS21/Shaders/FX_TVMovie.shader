// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FX_TVMovie"
{
	Properties
	{
		_Color("Color", Color) = (0.5807742,0.7100198,0.9632353,0)
		_Moive("Moive", 2D) = "white" {}
		_Columns("Columns", Range( 0 , 128)) = 0
		_Rows("Rows", Range( 0 , 128)) = 16
		_StartFrame("StartFrame", Float) = 0
		_MovieSpeed("Movie Speed", Range( 0 , 50)) = 1
		_EmissIntensity("EmissIntensity", Float) = 1
		_Noise("Noise", 2D) = "white" {}
		_DistortSpeed("Distort Speed", Range( 0 , 1)) = 0
		_Distort("Distort", Range( 0 , 1)) = 0.1
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

		uniform float4 _Color;
		uniform sampler2D _Moive;
		uniform float _Columns;
		uniform float _Rows;
		uniform float _MovieSpeed;
		uniform float _StartFrame;
		uniform float _Distort;
		uniform sampler2D _Noise;
		uniform float _DistortSpeed;
		uniform float _EmissIntensity;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles4 = _Columns * _Rows;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset4 = 1.0f / _Columns;
			float fbrowsoffset4 = 1.0f / _Rows;
			// Speed of animation
			float fbspeed4 = _Time[ 1 ] * _MovieSpeed;
			// UV Tiling (col and row offset)
			float2 fbtiling4 = float2(fbcolsoffset4, fbrowsoffset4);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex4 = round( fmod( fbspeed4 + _StartFrame, fbtotaltiles4) );
			fbcurrenttileindex4 += ( fbcurrenttileindex4 < 0) ? fbtotaltiles4 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox4 = round ( fmod ( fbcurrenttileindex4, _Columns ) );
			// Multiply Offset X by coloffset
			float fboffsetx4 = fblinearindextox4 * fbcolsoffset4;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy4 = round( fmod( ( fbcurrenttileindex4 - fblinearindextox4 ) / _Columns, _Rows ) );
			// Reverse Y to get tiles from Top to Bottom
			fblinearindextoy4 = (int)(_Rows-1) - fblinearindextoy4;
			// Multiply Offset Y by rowoffset
			float fboffsety4 = fblinearindextoy4 * fbrowsoffset4;
			// UV Offset
			float2 fboffset4 = float2(fboffsetx4, fboffsety4);
			// Flipbook UV
			half2 fbuv4 = i.uv_texcoord * fbtiling4 + fboffset4;
			// *** END Flipbook UV Animation vars ***
			float temp_output_287_0 = ( _Time.y * _DistortSpeed );
			float2 uv_TexCoord271 = i.uv_texcoord * float2( 0.3,0.3 );
			float2 panner274 = ( temp_output_287_0 * float2( 3,4 ) + uv_TexCoord271);
			float2 panner272 = ( temp_output_287_0 * float2( -3.3,-2 ) + uv_TexCoord271);
			float2 panner273 = ( temp_output_287_0 * float2( -3,6 ) + uv_TexCoord271);
			float NoiseGlitch292 = ( (0.0 + (_Distort - 0.0) * (0.01 - 0.0) / (1.0 - 0.0)) * ( ( tex2D( _Noise, panner274 ).r + tex2D( _Noise, panner272 ).r ) + ( tex2D( _Noise, panner273 ).r * 0.5 ) ) );
			float4 tex2DNode66 = tex2D( _Moive, ( fbuv4 + NoiseGlitch292 ) );
			o.Albedo = ( _Color * tex2DNode66 ).rgb;
			o.Emission = ( tex2DNode66 * _EmissIntensity ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
7;29;1906;1044;2047.18;1542.986;1.414249;True;False
Node;AmplifyShaderEditor.CommentaryNode;293;-1976.954,-857.436;Inherit;False;1944.006;947.6727;NoiseGlitch;17;271;273;274;272;277;276;275;278;285;279;280;289;284;288;287;291;292;NoiseGlitch;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;288;-1900.854,-71.8244;Float;False;Property;_DistortSpeed;Distort Speed;8;0;Create;True;0;0;False;0;False;0;0.16;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;291;-1841.848,-185.9477;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;287;-1609.733,-130.9071;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;271;-1842.476,-643.3213;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.3,0.3;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;274;-1308.428,-640.9188;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;3,4;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;273;-1326.421,-174.6478;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-3,6;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;272;-1318.235,-456.7344;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-3.3,-2;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;277;-1106.369,-668.8163;Inherit;True;Property;_Noise;Noise;7;0;Create;True;0;0;False;0;False;-1;None;a3cb981d6ca8b0b4b9e5b9a81ad45c24;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;276;-1077.224,-139.7632;Inherit;True;Property;_TextureSample1;Texture Sample 1;7;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;277;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;275;-1107.726,-482.5292;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;277;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;285;-967.9778,-807.4361;Float;False;Property;_Distort;Distort;9;0;Create;True;0;0;False;0;False;0.1;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;278;-750.8197,-111.0911;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;279;-738.1078,-570.9369;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;280;-581.9319,-552.4171;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;289;-641.7682,-785.873;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;284;-451.2313,-716.6143;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;258;-807.9988,-1412.628;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;6;-857.1686,-1106.924;Float;False;Property;_MovieSpeed;Movie Speed;5;0;Create;True;0;0;False;0;False;1;24;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;290;-753.2982,-1022.06;Inherit;False;Property;_StartFrame;StartFrame;4;0;Create;True;0;0;False;0;False;0;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;256;-851.912,-1198.42;Float;False;Property;_Rows;Rows;3;0;Create;True;0;0;False;0;False;16;16;0;128;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;255;-849.8011,-1278.494;Float;False;Property;_Columns;Columns;2;0;Create;True;0;0;False;0;False;0;16;0;128;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;292;-275.9476,-723.6467;Inherit;False;NoiseGlitch;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;4;-413.4995,-1234.48;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;8;False;2;FLOAT;8;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;294;-369.2683,-1010.859;Inherit;False;292;NoiseGlitch;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;286;-115.1335,-1233.853;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;119;86.2767,-1503.239;Float;False;Property;_Color;Color;0;0;Create;True;0;0;False;0;False;0.5807742,0.7100198,0.9632353,0;0.5807741,0.7100198,0.9632353,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;66;39.54718,-1262.138;Inherit;True;Property;_Moive;Moive;1;0;Create;True;0;0;False;0;False;-1;None;431aba1d589c49d41b881aa536127d88;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;266;116.9142,-1027.848;Float;False;Property;_EmissIntensity;EmissIntensity;6;0;Create;True;0;0;False;0;False;1;0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;263;484.4798,-1136.186;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;482.8938,-1287.815;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;704.241,-1247.399;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;FX_TVMovie;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;3;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;287;0;291;0
WireConnection;287;1;288;0
WireConnection;274;0;271;0
WireConnection;274;1;287;0
WireConnection;273;0;271;0
WireConnection;273;1;287;0
WireConnection;272;0;271;0
WireConnection;272;1;287;0
WireConnection;277;1;274;0
WireConnection;276;1;273;0
WireConnection;275;1;272;0
WireConnection;278;0;276;1
WireConnection;279;0;277;1
WireConnection;279;1;275;1
WireConnection;280;0;279;0
WireConnection;280;1;278;0
WireConnection;289;0;285;0
WireConnection;284;0;289;0
WireConnection;284;1;280;0
WireConnection;292;0;284;0
WireConnection;4;0;258;0
WireConnection;4;1;255;0
WireConnection;4;2;256;0
WireConnection;4;3;6;0
WireConnection;4;4;290;0
WireConnection;286;0;4;0
WireConnection;286;1;294;0
WireConnection;66;1;286;0
WireConnection;263;0;66;0
WireConnection;263;1;266;0
WireConnection;121;0;119;0
WireConnection;121;1;66;0
WireConnection;0;0;121;0
WireConnection;0;2;263;0
ASEEND*/
//CHKSM=1AC99997F2BA0560FB7EF7BC665CAFC5C5E2364B