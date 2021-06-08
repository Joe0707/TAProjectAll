// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Scene_StandardComp"
{
	Properties
	{
		_BaseColor("BaseColor", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_MinRoughness("MinRoughness", Float) = 0
		_MaxRoughness("MaxRoughness", Float) = 1
		_ORM("ORM", 2D) = "white" {}
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

		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform sampler2D _BaseColor;
		uniform float4 _BaseColor_ST;
		uniform sampler2D _ORM;
		uniform float4 _ORM_ST;
		uniform float _MinRoughness;
		uniform float _MaxRoughness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			o.Normal = UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) );
			float2 uv_BaseColor = i.uv_texcoord * _BaseColor_ST.xy + _BaseColor_ST.zw;
			o.Albedo = tex2D( _BaseColor, uv_BaseColor ).rgb;
			float2 uv_ORM = i.uv_texcoord * _ORM_ST.xy + _ORM_ST.zw;
			float4 tex2DNode13 = tex2D( _ORM, uv_ORM );
			o.Metallic = tex2DNode13.b;
			float lerpResult5 = lerp( _MinRoughness , _MaxRoughness , tex2DNode13.g);
			o.Smoothness = ( 1.0 - lerpResult5 );
			float saferPower14 = max( tex2DNode13.r , 0.0001 );
			o.Occlusion = pow( saferPower14 , 2.2 );
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
905;7;1906;1044;1607.288;914.0252;2.454281;True;False
Node;AmplifyShaderEditor.RangedFloatNode;7;-534.4438,495.2572;Inherit;False;Property;_MaxRoughness;MaxRoughness;3;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-532.4727,400.4241;Inherit;False;Property;_MinRoughness;MinRoughness;2;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;13;-1117.067,209.3804;Inherit;True;Property;_ORM;ORM;4;0;Create;True;0;0;False;0;False;-1;None;409a6128b2abbc84281e217dd429f5c8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;5;-309.4727,456.4241;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;8;-0.7456951,560.6192;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;14;-705.6172,170.5613;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;2.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-627.7582,-14.7604;Inherit;True;Property;_NormalMap;NormalMap;1;0;Create;True;0;0;False;0;False;-1;None;bddd259ff29ce49489f3614adc5abef0;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-618.686,-248.09;Inherit;True;Property;_BaseColor;BaseColor;0;0;Create;True;0;0;False;0;False;-1;None;7352055065806a942a2a0e7613cb6f87;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;215,10;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Scene_StandardComp;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;5;0;6;0
WireConnection;5;1;7;0
WireConnection;5;2;13;2
WireConnection;8;0;5;0
WireConnection;14;0;13;1
WireConnection;0;0;1;0
WireConnection;0;1;2;0
WireConnection;0;3;13;3
WireConnection;0;4;8;0
WireConnection;0;5;14;0
ASEEND*/
//CHKSM=FF03B423D2D1C0A00BF1AF44BAB6FB9B5E981011