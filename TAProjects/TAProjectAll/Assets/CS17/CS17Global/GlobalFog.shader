// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "GlobalFog"
{
	Properties
	{
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
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float4 screenPos;
			float3 worldPos;
		};

		uniform float4 _FogColor;
		uniform float4 _SunFogColor;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _SunFogRange;
		uniform float _SunFogIntensity;
		uniform float _FogDistanceEnd;
		uniform float _FogDistanceStart;
		uniform float _FogHeightEnd;
		uniform float _FogHeightStart;
		uniform float _FogIntensity;


		float2 UnStereo( float2 UV )
		{
			#if UNITY_SINGLE_PASS_STEREO
			float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex ];
			UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
			#endif
			return UV;
		}


		float3 InvertDepthDir72_g4( float3 In )
		{
			float3 result = In;
			#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
			result *= float3(1,1,-1);
			#endif
			return result;
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 UV22_g5 = ase_screenPosNorm.xy;
			float2 localUnStereo22_g5 = UnStereo( UV22_g5 );
			float2 break64_g4 = localUnStereo22_g5;
			float clampDepth69_g4 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
			#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g4 = ( 1.0 - clampDepth69_g4 );
			#else
				float staticSwitch38_g4 = clampDepth69_g4;
			#endif
			float3 appendResult39_g4 = (float3(break64_g4.x , break64_g4.y , staticSwitch38_g4));
			float4 appendResult42_g4 = (float4((appendResult39_g4*2.0 + -1.0) , 1.0));
			float4 temp_output_43_0_g4 = mul( unity_CameraInvProjection, appendResult42_g4 );
			float3 In72_g4 = ( (temp_output_43_0_g4).xyz / (temp_output_43_0_g4).w );
			float3 localInvertDepthDir72_g4 = InvertDepthDir72_g4( In72_g4 );
			float4 appendResult49_g4 = (float4(localInvertDepthDir72_g4 , 1.0));
			float4 WorldPosFormDepth61 = mul( unity_CameraToWorld, appendResult49_g4 );
			float4 normalizeResult68 = normalize( ( WorldPosFormDepth61 - float4( _WorldSpaceCameraPos , 0.0 ) ) );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult42 = dot( normalizeResult68 , float4( ase_worldlightDir , 0.0 ) );
			float clampResult47 = clamp( pow( (dotResult42*0.5 + 0.5) , _SunFogRange ) , 0.0 , 1.0 );
			float SunFog52 = ( clampResult47 * _SunFogIntensity );
			float4 lerpResult55 = lerp( _FogColor , _SunFogColor , SunFog52);
			o.Emission = lerpResult55.rgb;
			float temp_output_11_0_g7 = _FogDistanceEnd;
			float clampResult9_g7 = clamp( ( ( temp_output_11_0_g7 - distance( WorldPosFormDepth61 , float4( _WorldSpaceCameraPos , 0.0 ) ) ) / ( temp_output_11_0_g7 - _FogDistanceStart ) ) , 0.0 , 1.0 );
			float FogDistance23 = ( 1.0 - clampResult9_g7 );
			float temp_output_11_0_g6 = _FogHeightEnd;
			float clampResult9_g6 = clamp( ( ( temp_output_11_0_g6 - (WorldPosFormDepth61).y ) / ( temp_output_11_0_g6 - _FogHeightStart ) ) , 0.0 , 1.0 );
			float FogHeight33 = ( 1.0 - ( 1.0 - clampResult9_g6 ) );
			float clampResult37 = clamp( ( ( FogDistance23 * FogHeight33 ) * _FogIntensity ) , 0.0 , 1.0 );
			o.Alpha = clampResult37;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 

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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
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
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
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
				surfIN.worldPos = worldPos;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
7;29;1522;788;1083.219;-556.7264;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;62;-3364.982,1330.056;Inherit;False;724.365;214.4506;WolrdPosFromDepth;2;60;61;WolrdPosFromDepth;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;60;-3314.982,1380.056;Inherit;False;Reconstruct World Position From Depth;-1;;4;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;61;-2883.617,1429.507;Inherit;False;WorldPosFormDepth;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;51;-2657.377,2015.132;Inherit;False;2144.507;656.9175;Sun Fog;13;67;68;66;65;52;48;49;47;45;44;46;42;43;Sun Fog;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-2611.524,2061.354;Inherit;False;61;WorldPosFormDepth;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;67;-2635.888,2203.365;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;66;-2296.888,2115.365;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalizeNode;68;-2099.888,2161.365;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;43;-2167.865,2308.809;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;24;-2341.568,429.0659;Inherit;False;1218.384;606.1257;FogDistance;7;10;11;7;8;22;23;59;FogDistance;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;26;-2355.338,1265.15;Inherit;False;1218.384;606.1257;FogHeight;5;33;32;31;29;35;FogHeight;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-2343.871,1364.092;Inherit;False;61;WorldPosFormDepth;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;64;-2085.871,1389.092;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;59;-2310.21,509.311;Inherit;False;61;WorldPosFormDepth;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;10;-2291.568,660.9516;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;31;-2229.225,1550.568;Inherit;False;Property;_FogHeightStart;Fog Height Start;1;0;Create;True;0;0;False;0;False;0;-50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-2198.181,1719.404;Inherit;False;Property;_FogHeightEnd;Fog Height End;2;0;Create;True;0;0;False;0;False;700;500;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;42;-1842.865,2189.809;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1965.663,716.4413;Inherit;False;Property;_FogDistanceStart;Fog Distance Start;3;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;11;-1946.493,579.7646;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;44;-1657.865,2224.809;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1887.277,920.1916;Inherit;False;Property;_FogDistanceEnd;Fog Distance End;4;0;Create;True;0;0;False;0;False;700;700;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;32;-1927.135,1412.071;Inherit;False;FogLinear;-1;;6;8b9eb64b63c5f9848bc41179a8457d0e;0;3;13;FLOAT;500;False;12;FLOAT;0;False;11;FLOAT;700;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1681.865,2381.809;Inherit;False;Property;_SunFogRange;Sun Fog Range;5;0;Create;True;0;0;False;0;False;10;15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;35;-1693.435,1472.251;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;22;-1670.365,583.9875;Inherit;False;FogLinear;-1;;7;8b9eb64b63c5f9848bc41179a8457d0e;0;3;13;FLOAT;500;False;12;FLOAT;0;False;11;FLOAT;700;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;45;-1432.865,2264.809;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-1366.183,598.0262;Inherit;False;FogDistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;47;-1240.865,2274.809;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;56;-617.851,561.1362;Inherit;False;854.0399;785.885;FogCombine;10;25;34;36;54;37;55;18;53;58;57;FogCombine;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-1339.567,2445.245;Inherit;False;Property;_SunFogIntensity;Sun Fog Intensity;6;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-1379.953,1434.11;Inherit;False;FogHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;34;-542.2231,1179.725;Inherit;False;33;FogHeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-549.1583,1040.932;Inherit;False;23;FogDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-1050.567,2347.245;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-811.4116,2385.121;Inherit;False;SunFog;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-307.3476,1090.396;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-487.865,1259.587;Inherit;False;Property;_FogIntensity;FogIntensity;8;0;Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;53;-567.851,847.6799;Inherit;False;Property;_SunFogColor;Sun Fog Color;7;0;Create;True;0;0;False;0;False;1,0.5172414,0,0;0.7971601,0.6323529,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;18;-559.6468,611.1362;Inherit;False;Property;_FogColor;FogColor;0;0;Create;True;0;0;False;0;False;0,0.3793104,1,0;0,0.3793104,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-155.5843,1150.13;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-359.7855,921.2448;Inherit;False;52;SunFog;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;55;-171.2811,710.74;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;37;52.87212,1173.35;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1008.942,652.7153;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;GlobalFog;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;61;0;60;0
WireConnection;66;0;65;0
WireConnection;66;1;67;0
WireConnection;68;0;66;0
WireConnection;64;0;63;0
WireConnection;42;0;68;0
WireConnection;42;1;43;0
WireConnection;11;0;59;0
WireConnection;11;1;10;0
WireConnection;44;0;42;0
WireConnection;32;13;64;0
WireConnection;32;12;31;0
WireConnection;32;11;29;0
WireConnection;35;0;32;0
WireConnection;22;13;11;0
WireConnection;22;12;8;0
WireConnection;22;11;7;0
WireConnection;45;0;44;0
WireConnection;45;1;46;0
WireConnection;23;0;22;0
WireConnection;47;0;45;0
WireConnection;33;0;35;0
WireConnection;48;0;47;0
WireConnection;48;1;49;0
WireConnection;52;0;48;0
WireConnection;36;0;25;0
WireConnection;36;1;34;0
WireConnection;58;0;36;0
WireConnection;58;1;57;0
WireConnection;55;0;18;0
WireConnection;55;1;53;0
WireConnection;55;2;54;0
WireConnection;37;0;58;0
WireConnection;0;2;55;0
WireConnection;0;9;37;0
ASEEND*/
//CHKSM=CB06C30C6E4FEDBF5D7A983D12DB932DA52B238D