// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Terrain"
{
	Properties
	{
		_BaseColor("BaseColor", Color) = (0.6029412,0.6029412,0.6029412,0)
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_FogColor("FogColor", Color) = (0,0.3793104,1,0)
		_FogHeightStart("Fog Height Start", Float) = 0
		_FogHeightEnd("Fog Height End", Float) = 700
		_FogDistanceStart("Fog Distance Start", Float) = 0
		_FogDistanceEnd("Fog Distance End", Float) = 700
		_SunFogRange("Sun Fog Range", Float) = 10
		_SunFogIntensity("Sun Fog Intensity", Float) = 1
		_SunFogColor("Sun Fog Color", Color) = (1,0.5172414,0,0)
		_FogIntensity("FogIntensity", Range( 0 , 1)) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Background+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldNormal;
			float3 viewDir;
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _Smoothness;
		uniform float4 _BaseColor;
		uniform float4 _FogColor;
		uniform float4 _SunFogColor;
		uniform float _SunFogRange;
		uniform float _SunFogIntensity;
		uniform float _FogDistanceEnd;
		uniform float _FogDistanceStart;
		uniform float _FogHeightEnd;
		uniform float _FogHeightStart;
		uniform float _FogIntensity;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldNormal = i.worldNormal;
			Unity_GlossyEnvironmentData g2 = UnityGlossyEnvironmentSetup( _Smoothness, data.worldViewDir, ase_worldNormal, float3(0,0,0));
			float3 indirectSpecular2 = UnityGI_IndirectSpecular( data, 1.0, ase_worldNormal, g2 );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult42 = dot( -i.viewDir , ase_worldlightDir );
			float clampResult47 = clamp( pow( (dotResult42*0.5 + 0.5) , _SunFogRange ) , 0.0 , 1.0 );
			float SunFog52 = ( clampResult47 * _SunFogIntensity );
			float4 lerpResult55 = lerp( _FogColor , _SunFogColor , SunFog52);
			float temp_output_11_0_g3 = _FogDistanceEnd;
			float clampResult9_g3 = clamp( ( ( temp_output_11_0_g3 - distance( ase_worldPos , _WorldSpaceCameraPos ) ) / ( temp_output_11_0_g3 - _FogDistanceStart ) ) , 0.0 , 1.0 );
			float FogDistance23 = ( 1.0 - clampResult9_g3 );
			float temp_output_11_0_g2 = _FogHeightEnd;
			float clampResult9_g2 = clamp( ( ( temp_output_11_0_g2 - ase_worldPos.y ) / ( temp_output_11_0_g2 - _FogHeightStart ) ) , 0.0 , 1.0 );
			float FogHeight33 = ( 1.0 - ( 1.0 - clampResult9_g2 ) );
			float clampResult37 = clamp( ( ( FogDistance23 * FogHeight33 ) * _FogIntensity ) , 0.0 , 1.0 );
			float4 lerpResult17 = lerp( ( float4( indirectSpecular2 , 0.0 ) * _BaseColor ) , lerpResult55 , clampResult37);
			c.rgb = lerpResult17.rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
7;29;1522;788;395.6774;-46.9381;1.465325;True;False
Node;AmplifyShaderEditor.CommentaryNode;51;-2357.887,2015.132;Inherit;False;1845.017;671.8921;Sun Fog;11;52;48;49;47;45;44;46;42;43;50;41;Sun Fog;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;41;-2307.887,2065.133;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;26;-2355.338,1265.15;Inherit;False;1218.384;606.1257;FogHeight;6;33;32;31;29;28;35;FogHeight;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;24;-2341.568,429.0659;Inherit;False;1218.384;606.1257;FogDistance;7;9;10;11;7;8;22;23;FogDistance;1,1,1,1;0;0
Node;AmplifyShaderEditor.NegateNode;50;-2118.805,2156.074;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;43;-2167.865,2308.809;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;31;-2229.225,1550.568;Inherit;False;Property;_FogHeightStart;Fog Height Start;4;0;Create;True;0;0;False;0;False;0;-50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-2198.181,1719.404;Inherit;False;Property;_FogHeightEnd;Fog Height End;5;0;Create;True;0;0;False;0;False;700;500;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;9;-2222.279,479.0659;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;28;-2300.069,1380.466;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;42;-1842.865,2189.809;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;10;-2291.568,660.9516;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;32;-1958.135,1398.071;Inherit;False;FogLinear;-1;;2;8b9eb64b63c5f9848bc41179a8457d0e;0;3;13;FLOAT;500;False;12;FLOAT;0;False;11;FLOAT;700;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1878.663,741.4413;Inherit;False;Property;_FogDistanceStart;Fog Distance Start;6;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1887.277,920.1916;Inherit;False;Property;_FogDistanceEnd;Fog Distance End;7;0;Create;True;0;0;False;0;False;700;700;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1681.865,2381.809;Inherit;False;Property;_SunFogRange;Sun Fog Range;8;0;Create;True;0;0;False;0;False;10;15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;44;-1657.865,2224.809;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;11;-1946.493,579.7646;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;22;-1670.365,583.9875;Inherit;False;FogLinear;-1;;3;8b9eb64b63c5f9848bc41179a8457d0e;0;3;13;FLOAT;500;False;12;FLOAT;0;False;11;FLOAT;700;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;45;-1432.865,2264.809;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;35;-1693.435,1472.251;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-1366.183,598.0262;Inherit;False;FogDistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-1379.953,1434.11;Inherit;False;FogHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;47;-1240.865,2274.809;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;56;-617.851,561.1362;Inherit;False;854.0399;785.885;FogCombine;11;25;34;36;54;37;55;18;53;17;58;57;FogCombine;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-1339.567,2445.245;Inherit;False;Property;_SunFogIntensity;Sun Fog Intensity;9;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-1050.567,2347.245;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;34;-540.2231,1177.725;Inherit;False;33;FogHeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-549.1583,1040.932;Inherit;False;23;FogDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-811.4116,2385.121;Inherit;False;SunFog;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-827.7147,-43.48313;Inherit;False;Property;_Smoothness;Smoothness;2;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-307.3476,1090.396;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-487.865,1259.587;Inherit;False;Property;_FogIntensity;FogIntensity;11;0;Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-338.7855,878.2448;Inherit;False;52;SunFog;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;5;-485.7148,130.5169;Inherit;False;Property;_BaseColor;BaseColor;1;0;Create;True;0;0;False;0;False;0.6029412,0.6029412,0.6029412,0;0.2941176,0.2941176,0.2941176,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-155.5843,1150.13;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;18;-559.6468,611.1362;Inherit;False;Property;_FogColor;FogColor;3;0;Create;True;0;0;False;0;False;0,0.3793104,1,0;0,0.3793104,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IndirectSpecularLight;2;-463.7148,-61.48312;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;53;-567.851,847.6799;Inherit;False;Property;_SunFogColor;Sun Fog Color;10;0;Create;True;0;0;False;0;False;1,0.5172414,0,0;0.7971601,0.6323529,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;37;52.87212,1173.35;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;55;-171.2811,710.74;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-153.7148,49.51686;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;17;52.189,685.6705;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1133.12,147.9898;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Terrain;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;Background;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;50;0;41;0
WireConnection;42;0;50;0
WireConnection;42;1;43;0
WireConnection;32;13;28;2
WireConnection;32;12;31;0
WireConnection;32;11;29;0
WireConnection;44;0;42;0
WireConnection;11;0;9;0
WireConnection;11;1;10;0
WireConnection;22;13;11;0
WireConnection;22;12;8;0
WireConnection;22;11;7;0
WireConnection;45;0;44;0
WireConnection;45;1;46;0
WireConnection;35;0;32;0
WireConnection;23;0;22;0
WireConnection;33;0;35;0
WireConnection;47;0;45;0
WireConnection;48;0;47;0
WireConnection;48;1;49;0
WireConnection;52;0;48;0
WireConnection;36;0;25;0
WireConnection;36;1;34;0
WireConnection;58;0;36;0
WireConnection;58;1;57;0
WireConnection;2;1;6;0
WireConnection;37;0;58;0
WireConnection;55;0;18;0
WireConnection;55;1;53;0
WireConnection;55;2;54;0
WireConnection;3;0;2;0
WireConnection;3;1;5;0
WireConnection;17;0;3;0
WireConnection;17;1;55;0
WireConnection;17;2;37;0
WireConnection;0;13;17;0
ASEEND*/
//CHKSM=C9DB8AE5B4364544C6DD4BA6D1FB08CE1465CA73