// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Scene_Standard"
{
	Properties
	{
		_BaseColor("BaseColor", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_Metallic("Metallic", 2D) = "black" {}
		_RoughnessMap("RoughnessMap", 2D) = "white" {}
		_MinRoughness("MinRoughness", Float) = 0
		_MaxRoughness("MaxRoughness", Float) = 1
		_AOMap("AOMap", 2D) = "white" {}
		_Emission("Emission", 2D) = "white" {}
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _NormalMap;
		uniform sampler2D _BaseColor;
		uniform float4 _BaseColor_ST;
		uniform sampler2D _Emission;
		uniform float4 _EmissionColor;
		uniform sampler2D _Metallic;
		uniform float _MinRoughness;
		uniform float _MaxRoughness;
		uniform sampler2D _RoughnessMap;
		uniform sampler2D _AOMap;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BaseColor = i.uv_texcoord * _BaseColor_ST.xy + _BaseColor_ST.zw;
			o.Normal = UnpackNormal( tex2D( _NormalMap, uv_BaseColor ) );
			o.Albedo = tex2D( _BaseColor, uv_BaseColor ).rgb;
			o.Emission = ( tex2D( _Emission, uv_BaseColor ) * _EmissionColor ).rgb;
			o.Metallic = tex2D( _Metallic, uv_BaseColor ).r;
			float lerpResult5 = lerp( _MinRoughness , _MaxRoughness , tex2D( _RoughnessMap, uv_BaseColor ).r);
			o.Smoothness = ( 1.0 - lerpResult5 );
			o.Occlusion = tex2D( _AOMap, uv_BaseColor ).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
7;29;1906;1044;2494.819;724.8247;1.492584;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;16;-2000.773,-253.1682;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-870.8982,307.9881;Inherit;True;Property;_RoughnessMap;RoughnessMap;3;0;Create;True;0;0;False;0;False;-1;None;8cbbef0ef996cab408234f1a097bef85;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;6;-762.8317,137.2512;Inherit;False;Property;_MinRoughness;MinRoughness;4;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-763.4102,222.7104;Inherit;False;Property;_MaxRoughness;MaxRoughness;5;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;5;-464.1546,288.7189;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;15;-1583.936,388.8951;Inherit;False;Property;_EmissionColor;EmissionColor;8;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;12;-1660.914,131.9264;Inherit;True;Property;_Emission;Emission;7;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;9;-536.0573,0.6070087;Inherit;True;Property;_Metallic;Metallic;2;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-537.0068,-385.7461;Inherit;True;Property;_BaseColor;BaseColor;0;0;Create;True;0;0;False;0;False;-1;None;c93c9dd7bf2b7de4bb35a391670dd9b9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-532.1366,-193.4015;Inherit;True;Property;_NormalMap;NormalMap;1;0;Create;True;0;0;False;0;False;-1;None;0886ac56fb9094e4da4c36c722d41b9f;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-1259.209,137.8916;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;11;-416.6054,482.0742;Inherit;True;Property;_AOMap;AOMap;6;0;Create;True;0;0;False;0;False;-1;None;d74a1fe3d05db8c4cbee73eed6c57ed2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;8;-289.1417,289.9;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;176.8272,106.4367;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Scene_Standard;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;1;16;0
WireConnection;5;0;6;0
WireConnection;5;1;7;0
WireConnection;5;2;4;1
WireConnection;12;1;16;0
WireConnection;9;1;16;0
WireConnection;1;1;16;0
WireConnection;2;1;16;0
WireConnection;13;0;12;0
WireConnection;13;1;15;0
WireConnection;11;1;16;0
WireConnection;8;0;5;0
WireConnection;0;0;1;0
WireConnection;0;1;2;0
WireConnection;0;2;13;0
WireConnection;0;3;9;1
WireConnection;0;4;8;0
WireConnection;0;5;11;1
ASEEND*/
//CHKSM=36B61E0ACBA88F4609A73CE298044809E0DB2598