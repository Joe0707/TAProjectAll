// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Plane"
{
	Properties
	{
		_SGT_Ground_5_Albedo("SGT_Ground_5_Albedo", 2D) = "white" {}
		_SGT_Ground_5_Normal("SGT_Ground_5_Normal", 2D) = "bump" {}
		_SGT_Ground_5_Smoothness("SGT_Ground_5_Smoothness", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _SGT_Ground_5_Normal;
		uniform sampler2D _SGT_Ground_5_Albedo;
		uniform float4 _SGT_Ground_5_Albedo_ST;
		uniform sampler2D _SGT_Ground_5_Smoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_SGT_Ground_5_Albedo = i.uv_texcoord * _SGT_Ground_5_Albedo_ST.xy + _SGT_Ground_5_Albedo_ST.zw;
			o.Normal = UnpackNormal( tex2D( _SGT_Ground_5_Normal, uv_SGT_Ground_5_Albedo ) );
			o.Albedo = tex2D( _SGT_Ground_5_Albedo, uv_SGT_Ground_5_Albedo ).rgb;
			o.Smoothness = tex2D( _SGT_Ground_5_Smoothness, uv_SGT_Ground_5_Albedo ).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
93;221;1570;504;1579.407;208.4853;1.7172;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1043,66;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-638,152;Inherit;True;Property;_SGT_Ground_5_Normal;SGT_Ground_5_Normal;1;0;Create;True;0;0;False;0;False;-1;bfc519b5f83cdee4ca3b1d96b96475ec;c886840aa65cea14ab7494ed2314b46f;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-525,-145;Inherit;True;Property;_SGT_Ground_5_Albedo;SGT_Ground_5_Albedo;0;0;Create;True;0;0;False;0;False;-1;d3acf765604aece4e86196de184012d2;c8461f3ab2ff47c489e4aeaf88a5e05d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-558,381;Inherit;True;Property;_SGT_Ground_5_Smoothness;SGT_Ground_5_Smoothness;2;0;Create;True;0;0;False;0;False;-1;d572eb85e4c185745acc7b0b270b769f;5b69da41deae6fc468efafdbfb3d62ac;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;661,-14;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Plane;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;1;5;0
WireConnection;1;1;5;0
WireConnection;4;1;5;0
WireConnection;0;0;1;0
WireConnection;0;1;3;0
WireConnection;0;4;4;1
ASEEND*/
//CHKSM=A745CB2F44D981DC99A69A8EC39795D387D2B1E1