// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FX_FlowLight"
{
	Properties
	{
		_Logo("Logo", 2D) = "black" {}
		_PannerX("Panner X", Range( 0 , 1)) = 0
		_PannerY("Panner Y", Range( 0 , 1)) = 0
		_AlbedoColor("Albedo Color", Color) = (0.490566,0.490566,0.490566,0)
		_Background("Background", 2D) = "gray" {}
		_BackgroundEm("Background Em", Range( 0 , 1)) = 0
		_LEDint("LED int", Range( 0 , 1)) = 0
		_LED("LED", 2D) = "white" {}
		_FlowLight("FlowLight", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_FlowLightIntensity("FlowLightIntensity", Float) = 0
		_Dir("Dir", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _AlbedoColor;
		uniform sampler2D _Background;
		uniform sampler2D _Logo;
		uniform float4 _Logo_ST;
		uniform float _BackgroundEm;
		uniform sampler2D _FlowLight;
		uniform float _PannerX;
		uniform float _PannerY;
		uniform float4 _FlowLight_ST;
		uniform float _Dir;
		uniform float _FlowLightIntensity;
		uniform float _LEDint;
		uniform sampler2D _LED;
		uniform float4 _LED_ST;
		uniform float _Smoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Logo = i.uv_texcoord * _Logo_ST.xy + _Logo_ST.zw;
			float4 tex2DNode244 = tex2D( _Background, uv_Logo );
			o.Albedo = ( _AlbedoColor * tex2DNode244 ).rgb;
			float2 appendResult286 = (float2(_PannerX , _PannerY));
			float2 uv_FlowLight = i.uv_texcoord * _FlowLight_ST.xy + _FlowLight_ST.zw;
			float cos306 = cos( _Dir );
			float sin306 = sin( _Dir );
			float2 rotator306 = mul( uv_FlowLight - float2( 0.5,0.5 ) , float2x2( cos306 , -sin306 , sin306 , cos306 )) + float2( 0.5,0.5 );
			float2 panner219 = ( 1.0 * _Time.y * appendResult286 + rotator306);
			float2 uv_LED = i.uv_texcoord * _LED_ST.xy + _LED_ST.zw;
			o.Emission = ( ( tex2DNode244 * _BackgroundEm ) + ( ( tex2D( _Logo, i.uv_texcoord ) * tex2D( _FlowLight, panner219 ) * _FlowLightIntensity ) + ( _LEDint * tex2D( _LED, uv_LED ) ) ) ).rgb;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
7;29;1906;1044;405.4958;970.7323;2.445059;True;False
Node;AmplifyShaderEditor.RangedFloatNode;309;653.4161,348.9159;Inherit;False;Property;_Dir;Dir;12;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;308;758.3779,210.0955;Inherit;False;Constant;_Vector0;Vector 0;12;0;Create;True;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;302;732.7258,58.05146;Inherit;False;0;303;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;287;967.0246,232.4769;Float;False;Property;_PannerX;Panner X;2;0;Create;True;0;0;False;0;False;0;0.311;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;288;962.7989,319.1111;Float;False;Property;_PannerY;Panner Y;3;0;Create;True;0;0;False;0;False;0;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;286;1294.544,311.7154;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;306;1144.367,82.5613;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;301;1290.394,-267.2872;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;219;1493.512,285.0983;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;300;1849.677,530.3275;Inherit;False;0;249;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;210;1676.86,-244.726;Inherit;True;Property;_Logo;Logo;1;0;Create;True;0;0;False;0;False;-1;None;eb93eb9eb457f2b4f86da000b4d6c6a3;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;305;1782.472,316.1388;Inherit;False;Property;_FlowLightIntensity;FlowLightIntensity;11;0;Create;True;0;0;False;0;False;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;213;1212.498,-648.1666;Inherit;False;0;210;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;303;1719.985,71.07756;Inherit;True;Property;_FlowLight;FlowLight;9;0;Create;True;0;0;False;0;False;-1;None;985220bb934ab754ca6c78bd2d31da7a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;252;2215.249,361.3554;Float;False;Property;_LEDint;LED int;7;0;Create;True;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;249;2226.148,511.8965;Inherit;True;Property;_LED;LED;8;0;Create;True;0;0;False;0;False;-1;None;0d03e934ec665394395cecb6d54d29cb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;244;1549.185,-626.5857;Inherit;True;Property;_Background;Background;5;0;Create;True;0;0;False;0;False;-1;None;b1b8fb6e5191b6a4c887f1350432efab;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;298;2245.2,-347.8714;Float;False;Property;_BackgroundEm;Background Em;6;0;Create;True;0;0;False;0;False;0;0.604;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;304;2140.699,44.80194;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;251;2514.302,347.4312;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;250;2748.355,-115.3429;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;246;1560.503,-908.5312;Float;False;Property;_AlbedoColor;Albedo Color;4;0;Create;True;0;0;False;0;False;0.490566,0.490566,0.490566,0;0.490566,0.490566,0.490566,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;297;2628.46,-381.3949;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;247;2059.359,-672.8325;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;299;3033.28,126.3287;Float;False;Property;_Smoothness;Smoothness;10;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;296;2921.904,-157.3116;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3380.687,-279.6361;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;FX_FlowLight;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;3;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.28;True;True;0;False;TransparentCutout;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;1;4;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;286;0;287;0
WireConnection;286;1;288;0
WireConnection;306;0;302;0
WireConnection;306;1;308;0
WireConnection;306;2;309;0
WireConnection;219;0;306;0
WireConnection;219;2;286;0
WireConnection;210;1;301;0
WireConnection;303;1;219;0
WireConnection;249;1;300;0
WireConnection;244;1;213;0
WireConnection;304;0;210;0
WireConnection;304;1;303;0
WireConnection;304;2;305;0
WireConnection;251;0;252;0
WireConnection;251;1;249;0
WireConnection;250;0;304;0
WireConnection;250;1;251;0
WireConnection;297;0;244;0
WireConnection;297;1;298;0
WireConnection;247;0;246;0
WireConnection;247;1;244;0
WireConnection;296;0;297;0
WireConnection;296;1;250;0
WireConnection;0;0;247;0
WireConnection;0;2;296;0
WireConnection;0;4;299;0
ASEEND*/
//CHKSM=57CACD2FF177E31A5BB0F88874F6B4A562088594