// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FX_Flicker"
{
	Properties
	{
		_Minimunbrighness("Minimun brighness", Range( 0 , 1)) = 0
		_Colorize("Colorize", Color) = (1,1,1,1)
		_FlickerRate("Flicker Rate", Float) = 60
		_EmissiveAmount("Emissive Amount", Float) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			half filler;
		};

		uniform float4 _Colorize;
		uniform float _FlickerRate;
		uniform float _Minimunbrighness;
		uniform float _EmissiveAmount;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float clampResult13 = clamp( ( 1.0 - pow( max( sin( ( ( _Time.y * 6.28318548202515 ) * 100.0 ) ) , 0.0 ) , _FlickerRate ) ) , _Minimunbrighness , 1.0 );
			o.Emission = ( _Colorize * ( clampResult13 * _EmissiveAmount ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
7;29;1906;1044;2320.477;659.0506;1.63335;True;False
Node;AmplifyShaderEditor.SimpleTimeNode;7;-2206.779,211.5755;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TauNode;11;-2158.679,303.8755;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-2017.679,244.8755;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-2067.308,415.7098;Inherit;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-1847.072,282.693;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;8;-1663.679,259.8755;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;22;-1522.207,330.5159;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1434.453,433.3824;Inherit;False;Property;_FlickerRate;Flicker Rate;2;0;Create;True;0;0;False;0;False;60;1000;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;12;-1254,312;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-1343,550;Inherit;False;Property;_Minimunbrighness;Minimun brighness;0;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;23;-1081.399,238.467;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;13;-949.2579,313.1275;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-990.3995,570.255;Inherit;False;Property;_EmissiveAmount;Emissive Amount;3;0;Create;True;0;0;False;0;False;1;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-777.3981,-147.4651;Inherit;False;Property;_Colorize;Colorize;1;0;Create;True;0;0;False;0;False;1,1,1,1;1,0.5659999,0.1469996,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-723.6107,394.0263;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-353,35;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;FX_Flicker;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;9;0;7;0
WireConnection;9;1;11;0
WireConnection;16;0;9;0
WireConnection;16;1;17;0
WireConnection;8;0;16;0
WireConnection;22;0;8;0
WireConnection;12;0;22;0
WireConnection;12;1;5;0
WireConnection;23;0;12;0
WireConnection;13;0;23;0
WireConnection;13;1;1;0
WireConnection;14;0;13;0
WireConnection;14;1;6;0
WireConnection;4;0;2;0
WireConnection;4;1;14;0
WireConnection;0;2;4;0
ASEEND*/
//CHKSM=2744C71B562245353B50A1644ABA6DB092F4EC5A