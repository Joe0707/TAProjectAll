// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Flowmap_Custom"
{
	Properties
	{
		_Noise("Noise", 2D) = "white" {}
		_FlowMap("FlowMap", 2D) = "white" {}
		_NoiseStrength("NoiseStrength", Vector) = (0,0,0,0)
		_NoiseSpeed("NoiseSpeed", Float) = 0
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

		uniform sampler2D _Noise;
		uniform float4 _Noise_ST;
		uniform sampler2D _FlowMap;
		uniform float4 _FlowMap_ST;
		uniform float _NoiseSpeed;
		uniform float2 _NoiseStrength;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float2 uv_FlowMap = i.uv_texcoord * _FlowMap_ST.xy + _FlowMap_ST.zw;
			float4 tex2DNode3 = tex2D( _FlowMap, uv_FlowMap );
			float2 appendResult7 = (float2(tex2DNode3.r , tex2DNode3.g));
			float2 FlowDir37 = ( -appendResult7 + 0.5 );
			float mulTime23 = _Time.y * _NoiseSpeed;
			float temp_output_24_0 = frac( mulTime23 );
			float4 lerpResult41 = lerp( tex2D( _Noise, ( uv_Noise + ( FlowDir37 * ( temp_output_24_0 * _NoiseStrength ) ) ) ) , tex2D( _Noise, ( uv_Noise + ( FlowDir37 * ( _NoiseStrength * frac( ( mulTime23 + 0.5 ) ) ) ) ) ) , abs( (temp_output_24_0*2.0 + -1.0) ));
			float4 Noise11 = lerpResult41;
			o.Emission = Noise11.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
-339;749;1522;785;2618.168;-968.5215;1.855572;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-2921.731,837.3546;Inherit;False;0;3;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-2698.545,811.2045;Inherit;True;Property;_FlowMap;FlowMap;4;0;Create;True;0;0;False;0;False;-1;None;75c11ff777c73f745a290b5eb6b2723f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;6;-2015.817,1630.795;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;6;0;Create;True;0;0;False;0;False;0;0.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;36;-1910.893,1793.746;Inherit;False;1113.524;273.0002;Comment;6;31;30;32;33;34;38;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;7;-2361.52,832.4891;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-2270.517,954.1408;Inherit;False;Constant;_Float1;Float 1;5;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;20;-2208.823,839.2891;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;23;-1835.445,1629.932;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1860.893,1951.746;Inherit;False;Constant;_Float2;Float 2;6;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-2028.103,866.2141;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-1594.893,1915.746;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;35;-1628.063,1429.561;Inherit;False;471.1733;333.5032;Phase;3;24;26;8;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FractNode;24;-1578.063,1487.932;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;32;-1379.893,1926.746;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-1863.524,878.6595;Inherit;False;FlowDir;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;8;-1528.057,1602.064;Inherit;False;Property;_NoiseStrength;NoiseStrength;5;0;Create;True;0;0;False;0;False;0,0;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;39;-1286.575,1208.362;Inherit;False;37;FlowDir;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1325.89,1479.561;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-1189.822,1828.967;Inherit;False;37;FlowDir;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-1202.893,1917.746;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1062.752,1220.835;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;15;-1557.421,1051.925;Inherit;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-962.223,1897.652;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-788.415,1437.676;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;42;-1116.757,1613.537;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-915.751,1098.248;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;4;-1148.14,858.1677;Inherit;True;Property;_Noise;Noise;3;0;Create;True;0;0;False;0;False;None;6e9e3841a0552a34cb7c38b3628da853;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.AbsOpNode;43;-702.2938,1651.197;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;28;-524.7024,1411.881;Inherit;True;Property;_TextureSample6;Texture Sample 5;5;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;17;-648.019,1085.758;Inherit;True;Property;_TextureSample5;Texture Sample 5;5;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;41;36.38992,1502.035;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;1;-1974.874,-155.6293;Inherit;False;2071.194;822.7737;Noise;3;10;9;5;Noise;0,0.6411763,0.8529412,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1288.836,169.8127;Inherit;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;266.5997,1181.021;Inherit;True;Noise;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;10;-559.951,25.31867;Inherit;False;FLOAT;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;9;-838.516,29.71015;Inherit;False;Flow;0;;1;acad10cc8145e1f4eb8042bebe2d9a42;2,51,0,50,0;5;5;SAMPLER2D;;False;2;FLOAT2;0,0;False;18;FLOAT2;0,0;False;17;FLOAT2;1,1;False;24;FLOAT;0.2;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;636.9741,4.260692;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Flowmap_Custom;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;1;2;0
WireConnection;7;0;3;1
WireConnection;7;1;3;2
WireConnection;20;0;7;0
WireConnection;23;0;6;0
WireConnection;21;0;20;0
WireConnection;21;1;22;0
WireConnection;30;0;23;0
WireConnection;30;1;31;0
WireConnection;24;0;23;0
WireConnection;32;0;30;0
WireConnection;37;0;21;0
WireConnection;26;0;24;0
WireConnection;26;1;8;0
WireConnection;33;0;8;0
WireConnection;33;1;32;0
WireConnection;25;0;39;0
WireConnection;25;1;26;0
WireConnection;34;0;38;0
WireConnection;34;1;33;0
WireConnection;29;0;15;0
WireConnection;29;1;34;0
WireConnection;42;0;24;0
WireConnection;19;0;15;0
WireConnection;19;1;25;0
WireConnection;43;0;42;0
WireConnection;28;0;4;0
WireConnection;28;1;29;0
WireConnection;17;0;4;0
WireConnection;17;1;19;0
WireConnection;41;0;17;0
WireConnection;41;1;28;0
WireConnection;41;2;43;0
WireConnection;11;0;41;0
WireConnection;10;0;9;0
WireConnection;0;2;11;0
ASEEND*/
//CHKSM=0B0BFBECE8426B36B8C2EB3B80F622399F2FC7B9