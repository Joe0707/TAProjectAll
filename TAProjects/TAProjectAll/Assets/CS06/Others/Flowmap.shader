// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Flowmap"
{
	Properties
	{
		_Size("Size", Range( 0 , 10)) = 1
		_NoiseStrength1("NoiseStrength", Vector) = (0,0,0,0)
		_FlowMap1("FlowMap", 2D) = "white" {}
		_NoiseSpeed1("NoiseSpeed", Float) = 0
		_Noise1("Noise", 2D) = "white" {}
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
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Noise1;
		uniform float4 _Noise1_ST;
		uniform float _Size;
		uniform sampler2D _FlowMap1;
		uniform float4 _FlowMap1_ST;
		uniform float2 _NoiseStrength1;
		uniform float _NoiseSpeed1;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_Noise1 = i.uv_texcoord * _Noise1_ST.xy + _Noise1_ST.zw;
			float2 temp_output_4_0_g1 = (( uv_Noise1 / _Size )).xy;
			float2 uv_FlowMap1 = i.uv_texcoord * _FlowMap1_ST.xy + _FlowMap1_ST.zw;
			float4 tex2DNode3 = tex2D( _FlowMap1, uv_FlowMap1 );
			float4 appendResult4 = (float4(tex2DNode3.r , tex2DNode3.g , 0.0 , 0.0));
			float2 temp_output_41_0_g1 = ( -appendResult4.xy + 0.5 );
			float2 temp_output_17_0_g1 = _NoiseStrength1;
			float mulTime22_g1 = _Time.y * _NoiseSpeed1;
			float temp_output_27_0_g1 = frac( mulTime22_g1 );
			float2 temp_output_11_0_g1 = ( temp_output_4_0_g1 + ( temp_output_41_0_g1 * temp_output_17_0_g1 * temp_output_27_0_g1 ) );
			float2 temp_output_12_0_g1 = ( temp_output_4_0_g1 + ( temp_output_41_0_g1 * temp_output_17_0_g1 * frac( ( mulTime22_g1 + 0.5 ) ) ) );
			float4 lerpResult9_g1 = lerp( tex2D( _Noise1, temp_output_11_0_g1 ) , tex2D( _Noise1, temp_output_12_0_g1 ) , ( abs( ( temp_output_27_0_g1 - 0.5 ) ) / 0.5 ));
			float Noise11 = (lerpResult9_g1).r;
			float3 temp_cast_1 = (Noise11).xxx;
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
-80;427;1522;785;2259.115;233.5674;1.683113;True;True
Node;AmplifyShaderEditor.CommentaryNode;1;-2178.542,-177.62;Inherit;False;1845.309;652.605;Noise;11;11;10;9;8;7;6;5;4;3;2;15;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-1994.794,218.7208;Inherit;False;0;3;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-1750.471,203.6048;Inherit;True;Property;_FlowMap1;FlowMap;4;0;Create;True;0;0;False;0;False;-1;None;75c11ff777c73f745a290b5eb6b2723f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;4;-1414.658,163.6248;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-1161.664,362.1989;Inherit;False;Property;_NoiseSpeed1;NoiseSpeed;5;0;Create;True;0;0;False;0;False;0;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;15;-1259.127,191.2041;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TexturePropertyNode;8;-1650.781,-137.2492;Inherit;True;Property;_Noise1;Noise;6;0;Create;True;0;0;False;0;False;None;6e9e3841a0552a34cb7c38b3628da853;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1660.122,56.86873;Inherit;False;0;8;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;7;-1370.743,328.4818;Inherit;False;Property;_NoiseStrength1;NoiseStrength;3;0;Create;True;0;0;False;0;False;0,0;0.5,-1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.FunctionNode;9;-1000.34,25.53376;Inherit;False;Flow;0;;1;acad10cc8145e1f4eb8042bebe2d9a42;2,51,0,50,0;5;5;SAMPLER2D;;False;2;FLOAT2;0,0;False;18;FLOAT2;0,0;False;17;FLOAT2;1,1;False;24;FLOAT;0.2;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;10;-657.014,7.522976;Inherit;False;FLOAT;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-586.8131,225.4142;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-113.625,-55.14854;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Flowmap;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;1;2;0
WireConnection;4;0;3;1
WireConnection;4;1;3;2
WireConnection;15;0;4;0
WireConnection;9;5;8;0
WireConnection;9;2;5;0
WireConnection;9;18;15;0
WireConnection;9;17;7;0
WireConnection;9;24;6;0
WireConnection;10;0;9;0
WireConnection;11;0;10;0
WireConnection;0;2;11;0
ASEEND*/
//CHKSM=0F19D5F805178BEDF99A409B56B5E06DFC95C2D7