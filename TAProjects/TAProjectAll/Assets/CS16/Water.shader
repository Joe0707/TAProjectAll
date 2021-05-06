// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Water"
{
	Properties
	{
		_ReflectionTex("ReflectionTex", 2D) = "white" {}
		_WaterNormal("WaterNormal", 2D) = "bump" {}
		_UnderWaterTilling("UnderWaterTilling", Float) = 4
		_NormalIntensity("NormalIntensity", Float) = 1
		_NormalTilling("NormalTilling", Float) = 8
		_WaterSpeed("WaterSpeed", Float) = 1
		_WaterNoise("WaterNoise", Float) = 1
		_SpecTint("SpecTint", Color) = (1,1,1,1)
		_SpecSmoothness("SpecSmoothness", Range( 0.0001 , 1)) = 0.0001
		_SpecIntensity("SpecIntensity", Float) = 1
		_SpecEnd("SpecEnd", Float) = 200
		_UnderWater("UnderWater", 2D) = "white" {}
		_WaterDepth("WaterDepth", Float) = -1
		_BlinkSpeed("BlinkSpeed", Float) = 1
		_BlinkNoise("BlinkNoise", Float) = 1
		_BlinkTilling("BlinkTilling", Float) = 8
		_BlinkThreshold("BlinkThreshold", Float) = 2
		_BlinkIntensity("BlinkIntensity", Float) = 5
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float3 viewDir;
			float4 screenPos;
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

		uniform sampler2D _WaterNormal;
		uniform float _NormalTilling;
		uniform float _WaterSpeed;
		uniform float _NormalIntensity;
		uniform float _SpecSmoothness;
		uniform float4 _SpecTint;
		uniform float _SpecIntensity;
		uniform float _SpecEnd;
		uniform sampler2D _UnderWater;
		uniform float _UnderWaterTilling;
		uniform float _WaterDepth;
		uniform sampler2D _ReflectionTex;
		uniform float _WaterNoise;
		uniform float _BlinkTilling;
		uniform float _BlinkSpeed;
		uniform float _BlinkNoise;
		uniform float _BlinkThreshold;
		uniform float _BlinkIntensity;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float2 temp_output_7_0 = ( (ase_worldPos).xz / _NormalTilling );
			float temp_output_11_0 = ( _Time.y * 0.1 * _WaterSpeed );
			float2 temp_output_26_0 = ( (( UnpackScaleNormal( tex2D( _WaterNormal, ( temp_output_7_0 + temp_output_11_0 ) ), _NormalIntensity ) + UnpackScaleNormal( tex2D( _WaterNormal, ( ( temp_output_7_0 * 1.5 ) + ( temp_output_11_0 * -1.0 ) ) ), _NormalIntensity ) )).xy * 0.5 );
			float dotResult28 = dot( temp_output_26_0 , temp_output_26_0 );
			float4 appendResult32 = (float4(temp_output_26_0 , sqrt( ( 1.0 - dotResult28 ) ) , 0.0));
			float3 WorldNormal34 = (WorldNormalVector( i , appendResult32.xyz ));
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult49 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult50 = dot( WorldNormal34 , normalizeResult49 );
			float clampResult73 = clamp( ( ( _SpecEnd - distance( ase_worldPos , _WorldSpaceCameraPos ) ) / ( _SpecEnd - 0.0 ) ) , 0.0 , 1.0 );
			float4 SpecColor61 = ( ( ( pow( max( dotResult50 , 0.0 ) , ( _SpecSmoothness * 256.0 ) ) * _SpecTint ) * _SpecIntensity ) * clampResult73 );
			float2 paralaxOffset93 = ParallaxOffset( 0 , _WaterDepth , i.viewDir );
			float4 UnderWaterColor80 = tex2D( _UnderWater, ( ( ( (ase_worldPos).xz / _UnderWaterTilling ) + ( (WorldNormal34).xy * 0.1 ) ) + paralaxOffset93 ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 unityObjectToClipPos39 = UnityObjectToClipPos( ase_vertex3Pos );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 temp_output_114_0 = ( (ase_worldPos).xz / _BlinkTilling );
			float temp_output_111_0 = ( _Time.y * 0.1 * _BlinkSpeed );
			float2 temp_output_125_0 = ( (( UnpackNormal( tex2D( _WaterNormal, ( temp_output_114_0 + temp_output_111_0 ) ) ) + UnpackNormal( tex2D( _WaterNormal, ( ( temp_output_114_0 * 1.5 ) + ( temp_output_111_0 * -1.0 ) ) ) ) )).xy * 0.5 );
			float dotResult126 = dot( temp_output_125_0 , temp_output_125_0 );
			float4 appendResult129 = (float4(temp_output_125_0 , sqrt( ( 1.0 - dotResult126 ) ) , 0.0));
			float3 WorldNormalBlink131 = (WorldNormalVector( i , appendResult129.xyz ));
			float4 temp_cast_2 = (_BlinkThreshold).xxxx;
			float4 ReflectBlink146 = ( max( ( tex2D( _ReflectionTex, ( ( (WorldNormalBlink131).xz * _BlinkNoise ) + (ase_screenPosNorm).xy ) ) - temp_cast_2 ) , float4( 0,0,0,0 ) ) * _BlinkIntensity );
			float4 ReflectColor43 = ( tex2D( _ReflectionTex, ( ( ( (WorldNormal34).xz / ( 1.0 + unityObjectToClipPos39.w ) ) * _WaterNoise ) + (ase_screenPosNorm).xy ) ) + ReflectBlink146 );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float dotResult83 = dot( ase_worldNormal , ase_worldViewDir );
			float clampResult85 = clamp( dotResult83 , 0.0 , 1.0 );
			float temp_output_86_0 = ( 1.0 - clampResult85 );
			float clampResult102 = clamp( ( 0.2 + temp_output_86_0 ) , 0.0 , 1.0 );
			float4 lerpResult87 = lerp( UnderWaterColor80 , ( ReflectColor43 * clampResult102 ) , temp_output_86_0);
			c.rgb = ( SpecColor61 + lerpResult87 ).rgb;
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
			o.Normal = float3(0,0,1);
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
				float4 screenPos : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.screenPos = IN.screenPos;
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
7;29;1522;788;7922.286;1424.311;2.672009;True;False
Node;AmplifyShaderEditor.CommentaryNode;104;-6789.784,-1515.845;Inherit;False;3043.943;860.8121;WorldNormalBlink;26;131;130;129;128;127;126;125;124;123;122;121;120;118;117;116;115;114;113;112;111;110;109;108;107;106;105;WorldNormalBlink;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;105;-6739.784,-1465.845;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;107;-6639.805,-770.0328;Inherit;False;Property;_BlinkSpeed;BlinkSpeed;13;0;Create;True;0;0;False;0;False;1;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-6639.384,-872.7195;Inherit;False;Constant;_Float7;Float 0;3;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-6647.76,-1272.889;Inherit;False;Property;_BlinkTilling;BlinkTilling;15;0;Create;True;0;0;False;0;False;8;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;108;-6634.93,-1007.788;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;110;-6549.797,-1434.675;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;114;-6376.136,-1397.568;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-6362.002,-806.23;Inherit;False;Constant;_Float9;Float 2;5;0;Create;True;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;-6397.446,-966.2286;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-6414.314,-1165.439;Inherit;False;Constant;_Float8;Float 1;5;0;Create;True;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;-6143.923,-1126.908;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;-6159.729,-914.3416;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;35;-3050.18,-1512.002;Inherit;False;3043.943;860.8121;WorldNormal;27;5;10;6;8;13;12;11;22;20;7;18;21;9;23;4;19;25;14;29;28;31;34;33;27;32;26;103;WorldNormal;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;118;-6059.302,-1345.13;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;5;-3000.18,-1462.002;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;117;-5981.868,-1020.709;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;121;-5707.061,-972.1104;Inherit;True;Property;_WaterNormal3;WaterNormal;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Instance;4;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;120;-5670.518,-1386.849;Inherit;True;Property;_WaterNormal2;WaterNormal;1;0;Create;True;0;0;False;0;False;-1;None;588cec9407e143145a30498db9c1f2c0;True;0;True;bump;Auto;True;Instance;4;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;13;-2900.201,-766.1896;Inherit;False;Property;_WaterSpeed;WaterSpeed;5;0;Create;True;0;0;False;0;False;1;0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-2899.78,-868.8762;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-2908.156,-1269.046;Inherit;False;Property;_NormalTilling;NormalTilling;4;0;Create;True;0;0;False;0;False;8;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;6;-2810.193,-1430.832;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;10;-2895.326,-1003.945;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-2622.399,-802.3868;Inherit;False;Constant;_Float2;Float 2;5;0;Create;True;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-2674.71,-1161.596;Inherit;False;Constant;_Float1;Float 1;5;0;Create;True;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-2657.842,-962.3852;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;122;-5397.724,-1035.736;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;7;-2636.532,-1393.725;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-2404.319,-1123.065;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-2420.125,-910.4983;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;124;-5248.44,-1090.088;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-5372.941,-821.2167;Inherit;False;Constant;_Float10;Float 3;5;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-2220.45,-1179.84;Inherit;False;Property;_NormalIntensity;NormalIntensity;3;0;Create;True;0;0;False;0;False;1;2.43;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;23;-2242.264,-1016.866;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-5102.034,-953.524;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;9;-2319.698,-1341.287;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;19;-1967.457,-968.2672;Inherit;True;Property;_WaterNormal1;WaterNormal;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Instance;4;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;126;-4927.975,-870.5031;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-1930.914,-1383.006;Inherit;True;Property;_WaterNormal;WaterNormal;1;0;Create;True;0;0;False;0;False;-1;None;588cec9407e143145a30498db9c1f2c0;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;127;-4747.257,-861.1155;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-1658.12,-1031.893;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;14;-1508.836,-1086.245;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1633.337,-817.3734;Inherit;False;Constant;_Float3;Float 3;5;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SqrtOpNode;128;-4540.723,-859.9419;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1362.43,-949.6808;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;129;-4403.425,-949.1271;Inherit;False;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DotProductOpNode;28;-1188.371,-866.6598;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;130;-4211.337,-912.6324;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;131;-3988.841,-866.9541;Inherit;False;WorldNormalBlink;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;132;-6816.946,-456.0612;Inherit;False;2463.354;690.994;ReflectBlink;14;146;151;152;149;147;145;148;144;142;143;139;140;138;134;ReflectBlink;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;29;-1007.654,-857.2723;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;134;-6248.062,-237.2128;Inherit;False;131;WorldNormalBlink;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SqrtOpNode;31;-801.1198,-856.0986;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;138;-5949.908,-388.7859;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;32;-663.8215,-945.2838;Inherit;False;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;139;-5961.862,-118.5095;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;140;-5956.726,-268.2349;Inherit;False;Property;_BlinkNoise;BlinkNoise;14;0;Create;True;0;0;False;0;False;1;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;44;-3069.412,-510.3581;Inherit;False;2273.846;655.0865;ReflectColor;16;43;154;153;1;17;3;15;2;16;38;41;37;39;42;36;40;ReflectColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;33;-471.7332,-908.7892;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;-5720.726,-328.235;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;143;-5718.964,-91.92012;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;62;-3055.483,351.9063;Inherit;False;2108.708;1078.63;SpecColor;25;61;59;57;60;53;58;55;52;54;50;56;49;51;48;46;47;65;66;67;69;68;70;71;72;73;SpecColor;0.4191176,0.2724265,0.0523897,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-249.2368,-863.1108;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;144;-5525.642,-207.061;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosVertexDataNode;40;-3019.412,-304.2794;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;46;-2941.617,413.2528;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;47;-3005.483,595.7471;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;148;-5299.972,-59.56805;Inherit;False;Property;_BlinkThreshold;BlinkThreshold;16;0;Create;True;0;0;False;0;False;2;5.39;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;-2592.246,-460.3581;Inherit;False;34;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;145;-5346.488,-376.6999;Inherit;True;Property;_ReflectionTex1;ReflectionTex;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;42;-2611.157,-353.5996;Inherit;False;Constant;_Float4;Float 4;5;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;39;-2715.504,-231.757;Inherit;False;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-2709.224,538.4937;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;97;-3052,1617.104;Inherit;False;1744.745;1087.979;UnderWater;15;76;88;78;90;91;77;79;89;94;95;92;93;96;75;80;UnderWater;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-2403.157,-221.5996;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;147;-5063.184,-150.7536;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;37;-2369.45,-444.9168;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;38;-2141.875,-435.9243;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;76;-2961.551,1667.104;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;49;-2533.036,557.04;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-3002,2048.946;Inherit;False;34;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;2;-2196.923,-42.27154;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;16;-2191.786,-191.9971;Inherit;False;Property;_WaterNoise;WaterNoise;6;0;Create;True;0;0;False;0;False;1;2.58;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;152;-5003.215,8.174194;Inherit;False;Property;_BlinkIntensity;BlinkIntensity;17;0;Create;True;0;0;False;0;False;5;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-2581.47,401.9063;Inherit;False;34;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;149;-4896.912,-265.3001;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-1955.786,-251.9971;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-2380.659,876.8929;Inherit;False;Constant;_Float5;Float 5;5;0;Create;True;0;0;False;0;False;256;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;67;-2835.317,1186.438;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;77;-2771.563,1698.274;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;65;-2809.011,916.792;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;91;-2784,2056.946;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;84;-926.9192,391.1382;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;90;-2814,2185.946;Inherit;False;Constant;_Float6;Float 6;11;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-2429.659,742.8929;Inherit;False;Property;_SpecSmoothness;SpecSmoothness;8;0;Create;True;0;0;False;0;False;0.0001;0.02;0.0001;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;3;-1954.025,-15.68217;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;82;-943.9192,202.1382;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;50;-2332.367,486.6007;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-2869.527,1860.06;Inherit;False;Property;_UnderWaterTilling;UnderWaterTilling;2;0;Create;True;0;0;False;0;False;4;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;-4793.215,-121.8258;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;79;-2597.903,1735.381;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;66;-2526.21,1082.855;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-2374.944,1222.61;Inherit;False;Constant;_SpecStart;SpecStart;8;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-2355.214,982.5596;Inherit;False;Property;_SpecEnd;SpecEnd;10;0;Create;True;0;0;False;0;False;200;200;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;83;-687.9192,268.1382;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;52;-2175.432,567.5594;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-2710.211,2429.542;Inherit;False;Property;_WaterDepth;WaterDepth;12;0;Create;True;0;0;False;0;False;-1;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;146;-4599.164,-271.1441;Inherit;False;ReflectBlink;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-1760.702,-130.8231;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;94;-2781.902,2521.083;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-2555,2093.946;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-2156.659,831.8929;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;71;-2156.268,1191.371;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;70;-2156.267,1063.125;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxOffsetHlpNode;93;-2400.295,2395.352;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;53;-1961.204,674.6739;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;154;-1504.677,-28.2074;Inherit;False;146;ReflectBlink;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-1577.198,-296.0107;Inherit;True;Property;_ReflectionTex;ReflectionTex;0;0;Create;True;0;0;False;0;False;-1;None;;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;85;-536.5083,302.5794;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;58;-1964.332,843.4421;Inherit;False;Property;_SpecTint;SpecTint;7;0;Create;True;0;0;False;0;False;1,1,1,1;0.7647059,0.4296624,0.005622843,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;92;-2348,1933.946;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-1728.332,855.442;Inherit;False;Property;_SpecIntensity;SpecIntensity;9;0;Create;True;0;0;False;0;False;1;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;86;-389.5083,363.5794;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;96;-2138.104,2163.038;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;153;-1247.677,-131.2074;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-1719.332,743.4421;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;72;-1970.474,1125.604;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;73;-1806.055,1156.844;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;-352.756,188.66;Inherit;False;2;2;0;FLOAT;0.2;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-1511.332,754.4421;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;43;-1065.566,-188.6817;Inherit;False;ReflectColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;75;-1918.74,1926.921;Inherit;True;Property;_UnderWater;UnderWater;11;0;Create;True;0;0;False;0;False;-1;None;0a7a0e7b4095f774e8b09e980c792987;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-1572.254,1986.907;Inherit;False;UnderWaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-1378.839,1014.383;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;-267.0223,48.6699;Inherit;False;43;ReflectColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;102;-206.0676,251.291;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;61;-1201.637,863.3393;Inherit;False;SpecColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;81;-210.1187,-35.64098;Inherit;False;80;UnderWaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-34.38712,174.9532;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;87;232.9745,282.3571;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;225.5988,83.40009;Inherit;False;61;SpecColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;64;462.7083,150.7677;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;685.4154,41.60703;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;110;0;105;0
WireConnection;114;0;110;0
WireConnection;114;1;109;0
WireConnection;111;0;108;0
WireConnection;111;1;106;0
WireConnection;111;2;107;0
WireConnection;115;0;114;0
WireConnection;115;1;112;0
WireConnection;116;0;111;0
WireConnection;116;1;113;0
WireConnection;118;0;114;0
WireConnection;118;1;111;0
WireConnection;117;0;115;0
WireConnection;117;1;116;0
WireConnection;121;1;117;0
WireConnection;120;1;118;0
WireConnection;6;0;5;0
WireConnection;11;0;10;0
WireConnection;11;1;12;0
WireConnection;11;2;13;0
WireConnection;122;0;120;0
WireConnection;122;1;121;0
WireConnection;7;0;6;0
WireConnection;7;1;8;0
WireConnection;18;0;7;0
WireConnection;18;1;20;0
WireConnection;21;0;11;0
WireConnection;21;1;22;0
WireConnection;124;0;122;0
WireConnection;23;0;18;0
WireConnection;23;1;21;0
WireConnection;125;0;124;0
WireConnection;125;1;123;0
WireConnection;9;0;7;0
WireConnection;9;1;11;0
WireConnection;19;1;23;0
WireConnection;19;5;103;0
WireConnection;126;0;125;0
WireConnection;126;1;125;0
WireConnection;4;1;9;0
WireConnection;4;5;103;0
WireConnection;127;0;126;0
WireConnection;25;0;4;0
WireConnection;25;1;19;0
WireConnection;14;0;25;0
WireConnection;128;0;127;0
WireConnection;26;0;14;0
WireConnection;26;1;27;0
WireConnection;129;0;125;0
WireConnection;129;2;128;0
WireConnection;28;0;26;0
WireConnection;28;1;26;0
WireConnection;130;0;129;0
WireConnection;131;0;130;0
WireConnection;29;0;28;0
WireConnection;31;0;29;0
WireConnection;138;0;134;0
WireConnection;32;0;26;0
WireConnection;32;2;31;0
WireConnection;33;0;32;0
WireConnection;142;0;138;0
WireConnection;142;1;140;0
WireConnection;143;0;139;0
WireConnection;34;0;33;0
WireConnection;144;0;142;0
WireConnection;144;1;143;0
WireConnection;145;1;144;0
WireConnection;39;0;40;0
WireConnection;48;0;46;0
WireConnection;48;1;47;0
WireConnection;41;0;42;0
WireConnection;41;1;39;4
WireConnection;147;0;145;0
WireConnection;147;1;148;0
WireConnection;37;0;36;0
WireConnection;38;0;37;0
WireConnection;38;1;41;0
WireConnection;49;0;48;0
WireConnection;149;0;147;0
WireConnection;15;0;38;0
WireConnection;15;1;16;0
WireConnection;77;0;76;0
WireConnection;91;0;88;0
WireConnection;3;0;2;0
WireConnection;50;0;51;0
WireConnection;50;1;49;0
WireConnection;151;0;149;0
WireConnection;151;1;152;0
WireConnection;79;0;77;0
WireConnection;79;1;78;0
WireConnection;66;0;65;0
WireConnection;66;1;67;0
WireConnection;83;0;82;0
WireConnection;83;1;84;0
WireConnection;52;0;50;0
WireConnection;146;0;151;0
WireConnection;17;0;15;0
WireConnection;17;1;3;0
WireConnection;89;0;91;0
WireConnection;89;1;90;0
WireConnection;55;0;54;0
WireConnection;55;1;56;0
WireConnection;71;0;69;0
WireConnection;71;1;68;0
WireConnection;70;0;69;0
WireConnection;70;1;66;0
WireConnection;93;1;95;0
WireConnection;93;2;94;0
WireConnection;53;0;52;0
WireConnection;53;1;55;0
WireConnection;1;1;17;0
WireConnection;85;0;83;0
WireConnection;92;0;79;0
WireConnection;92;1;89;0
WireConnection;86;0;85;0
WireConnection;96;0;92;0
WireConnection;96;1;93;0
WireConnection;153;0;1;0
WireConnection;153;1;154;0
WireConnection;57;0;53;0
WireConnection;57;1;58;0
WireConnection;72;0;70;0
WireConnection;72;1;71;0
WireConnection;73;0;72;0
WireConnection;99;1;86;0
WireConnection;59;0;57;0
WireConnection;59;1;60;0
WireConnection;43;0;153;0
WireConnection;75;1;96;0
WireConnection;80;0;75;0
WireConnection;74;0;59;0
WireConnection;74;1;73;0
WireConnection;102;0;99;0
WireConnection;61;0;74;0
WireConnection;98;0;45;0
WireConnection;98;1;102;0
WireConnection;87;0;81;0
WireConnection;87;1;98;0
WireConnection;87;2;86;0
WireConnection;64;0;63;0
WireConnection;64;1;87;0
WireConnection;0;13;64;0
ASEEND*/
//CHKSM=E8C624C6E73A64FFC949CD5DA1B97AB3CFA2A2D4