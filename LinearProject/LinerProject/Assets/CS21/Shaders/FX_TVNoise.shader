// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FX_TVNoise"
{
	Properties
	{
		_Speed("Speed", Float) = 0
		_Scale("Scale", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float2 _Scale;
		uniform float _Speed;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float mulTime119 = _Time.y * _Speed;
			float dotResult4_g21 = dot( ( ( i.uv_texcoord * _Scale ) + sin( mulTime119 ) ) , float2( 12.9898,78.233 ) );
			float lerpResult10_g21 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g21 ) * 43758.55 ) ));
			float temp_output_121_0 = lerpResult10_g21;
			float3 temp_cast_0 = (temp_output_121_0).xxx;
			o.Albedo = temp_cast_0;
			float3 temp_cast_1 = (temp_output_121_0).xxx;
			o.Emission = temp_cast_1;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
7;29;1906;1044;1056.369;-44.90628;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;122;-634.3685,542.9063;Inherit;False;Property;_Speed;Speed;0;0;Create;True;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;119;-440.3685,550.9063;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;117;-646.3685,293.9063;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;125;-615.369,429.9063;Inherit;False;Property;_Scale;Scale;1;0;Create;True;0;0;False;0;False;0,0;0,1E-05;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SinOpNode;126;-255.369,634.9063;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-360.369,343.9063;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;118;-152.3685,407.9063;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;121;137.6315,396.9063;Inherit;False;Random Range;-1;;21;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;557.6248,134.1394;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;FX_TVNoise;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;119;0;122;0
WireConnection;126;0;119;0
WireConnection;123;0;117;0
WireConnection;123;1;125;0
WireConnection;118;0;123;0
WireConnection;118;1;126;0
WireConnection;121;1;118;0
WireConnection;0;0;121;0
WireConnection;0;2;121;0
ASEEND*/
//CHKSM=C69CA932B0BE1BF64F034B15C63229FF340450F3