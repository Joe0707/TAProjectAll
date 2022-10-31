// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Toon_River"
{
	Properties
	{
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 15
		_WaveASpeedXYSteepnesswavelength("WaveA(SpeedXY,Steepness,wavelength)", Vector) = (1,1,2,50)
		_WaveB("WaveB", Vector) = (1,1,2,50)
		_WaveC("WaveC", Vector) = (1,1,2,50)
		_WaveColor("WaveColor", Color) = (0,0,0,0)
		_ShallowColor("ShallowColor", Color) = (0,0,0,0)
		_DeepColor("DeepColor", Color) = (0,0,0,0)
		_DeepRange("Deep Range", Float) = 1
		_FresnelColor("FresnelColor", Color) = (0,0,0,0)
		_FresnelPower("FresnelPower", Float) = 1
		_NormalSpeed("NormalSpeed", Vector) = (0,0,0,0)
		_NormalMap("NormalMap", 2D) = "bump" {}
		_UnderWaterDistort("UnderWaterDistort", Float) = 1
		_ReflectIntensity("ReflectIntensity", Float) = 1
		_ReflectPower("ReflectPower", Float) = 5
		_CauasticsScale("Cauastics Scale", Float) = 8
		_CauasticsTex("CauasticsTex", 2D) = "white" {}
		_CauasticsSpeed("Cauastics Speed", Vector) = (-8,0,0,0)
		_FoamNoise("FoamNoise", 2D) = "white" {}
		_CauasticsIntensity("Cauastics Intensity", Float) = 3
		_CauasticsRange("Cauastics Range", Float) = 1
		_FoamRange("FoamRange", Float) = 1
		_FoamContrast("FoamContrast", Float) = 1
		_FoamSpeed("FoamSpeed", Float) = 1
		_FoamFastSpeed("FoamFastSpeed", Float) = 1
		_ReflectDistort("Reflect Distort", Float) = 0
		_FoamColor("FoamColor", Color) = (1,1,1,1)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		GrabPass{ }
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityStandardUtils.cginc"
		#include "Tessellation.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
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
			float3 worldPos;
			float4 vertexColor : COLOR;
			float4 screenPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
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

		uniform float4 _WaveASpeedXYSteepnesswavelength;
		uniform float4 _WaveB;
		uniform float4 _WaveC;
		uniform float4 _DeepColor;
		uniform float4 _ShallowColor;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DeepRange;
		uniform float4 _FresnelColor;
		uniform float _FresnelPower;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float2 _NormalSpeed;
		uniform float _ReflectDistort;
		uniform float _ReflectIntensity;
		uniform float _ReflectPower;
		uniform float4 _WaveColor;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float _UnderWaterDistort;
		uniform sampler2D _CauasticsTex;
		uniform float _CauasticsScale;
		uniform float2 _CauasticsSpeed;
		uniform float _CauasticsIntensity;
		uniform float _CauasticsRange;
		uniform float4 _FoamColor;
		uniform float _FoamContrast;
		uniform sampler2D _FoamNoise;
		uniform float _FoamFastSpeed;
		uniform float _FoamSpeed;
		uniform float _FoamRange;
		uniform float _EdgeLength;


		float3 GerstnerWave188( float3 position, inout float3 tangent, inout float3 binormal, float4 wave )
		{
			float steepness = wave.z * 0.01;
			float wavelength = wave.w;
			float k = 2 * UNITY_PI / wavelength;
			float c = sqrt(9.8 / k);
			float2 d = normalize(wave.xy);
			float f = k * (dot(d, position.xz) - c * _Time.y);
			float a = steepness / k;
						
			tangent += float3(
			-d.x * d.x * (steepness * sin(f)),
			d.x * (steepness * cos(f)),
			-d.x * d.y * (steepness * sin(f))
			);
			binormal += float3(
			-d.x * d.y * (steepness * sin(f)),
			d.y * (steepness * cos(f)),
			-d.y * d.y * (steepness * sin(f))
			);
			return float3(
			d.x * (a * cos(f)),
			a * sin(f),
			d.y * (a * cos(f))
			);
		}


		float3 GerstnerWave196( float3 position, inout float3 tangent, inout float3 binormal, float4 wave )
		{
			float steepness = wave.z * 0.01;
			float wavelength = wave.w;
			float k = 2 * UNITY_PI / wavelength;
			float c = sqrt(9.8 / k);
			float2 d = normalize(wave.xy);
			float f = k * (dot(d, position.xz) - c * _Time.y);
			float a = steepness / k;
						
			tangent += float3(
			-d.x * d.x * (steepness * sin(f)),
			d.x * (steepness * cos(f)),
			-d.x * d.y * (steepness * sin(f))
			);
			binormal += float3(
			-d.x * d.y * (steepness * sin(f)),
			d.y * (steepness * cos(f)),
			-d.y * d.y * (steepness * sin(f))
			);
			return float3(
			d.x * (a * cos(f)),
			a * sin(f),
			d.y * (a * cos(f))
			);
		}


		float3 GerstnerWave203( float3 position, inout float3 tangent, inout float3 binormal, float4 wave )
		{
			float steepness = wave.z * 0.01;
			float wavelength = wave.w;
			float k = 2 * UNITY_PI / wavelength;
			float c = sqrt(9.8 / k);
			float2 d = normalize(wave.xy);
			float f = k * (dot(d, position.xz) - c * _Time.y);
			float a = steepness / k;
						
			tangent += float3(
			-d.x * d.x * (steepness * sin(f)),
			d.x * (steepness * cos(f)),
			-d.x * d.y * (steepness * sin(f))
			);
			binormal += float3(
			-d.x * d.y * (steepness * sin(f)),
			d.y * (steepness * cos(f)),
			-d.y * d.y * (steepness * sin(f))
			);
			return float3(
			d.x * (a * cos(f)),
			a * sin(f),
			d.y * (a * cos(f))
			);
		}


		float2 UnStereo( float2 UV )
		{
			#if UNITY_SINGLE_PASS_STEREO
			float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex ];
			UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
			#endif
			return UV;
		}


		float3 InvertDepthDir72_g1( float3 In )
		{
			float3 result = In;
			#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
			result *= float3(1,1,-1);
			#endif
			return result;
		}


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 position188 = ase_worldPos;
			float3 tangent188 = float3( 1,0,0 );
			float3 binormal188 = float3( 0,0,1 );
			float4 wave188 = _WaveASpeedXYSteepnesswavelength;
			float3 localGerstnerWave188 = GerstnerWave188( position188 , tangent188 , binormal188 , wave188 );
			float3 position196 = ase_worldPos;
			float3 tangent196 = tangent188;
			float3 binormal196 = binormal188;
			float4 wave196 = _WaveB;
			float3 localGerstnerWave196 = GerstnerWave196( position196 , tangent196 , binormal196 , wave196 );
			float3 position203 = ase_worldPos;
			float3 tangent203 = tangent196;
			float3 binormal203 = binormal196;
			float4 wave203 = _WaveC;
			float3 localGerstnerWave203 = GerstnerWave203( position203 , tangent203 , binormal203 , wave203 );
			float3 temp_output_191_0 = ( ase_worldPos + localGerstnerWave188 + localGerstnerWave196 + localGerstnerWave203 );
			float3 worldToObj192 = mul( unity_WorldToObject, float4( temp_output_191_0, 1 ) ).xyz;
			float3 WaveVertexPos194 = worldToObj192;
			v.vertex.xyz = WaveVertexPos194;
			v.vertex.w = 1;
			float3 normalizeResult198 = normalize( cross( binormal203 , tangent203 ) );
			float3 worldToObjDir199 = mul( unity_WorldToObject, float4( normalizeResult198, 0 ) ).xyz;
			float3 WaveVertexNormal200 = worldToObjDir199;
			v.normal = WaveVertexNormal200;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 UV22_g3 = ase_screenPosNorm.xy;
			float2 localUnStereo22_g3 = UnStereo( UV22_g3 );
			float2 break64_g1 = localUnStereo22_g3;
			float clampDepth69_g1 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
			#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g1 = ( 1.0 - clampDepth69_g1 );
			#else
				float staticSwitch38_g1 = clampDepth69_g1;
			#endif
			float3 appendResult39_g1 = (float3(break64_g1.x , break64_g1.y , staticSwitch38_g1));
			float4 appendResult42_g1 = (float4((appendResult39_g1*2.0 + -1.0) , 1.0));
			float4 temp_output_43_0_g1 = mul( unity_CameraInvProjection, appendResult42_g1 );
			float3 In72_g1 = ( (temp_output_43_0_g1).xyz / (temp_output_43_0_g1).w );
			float3 localInvertDepthDir72_g1 = InvertDepthDir72_g1( In72_g1 );
			float4 appendResult49_g1 = (float4(localInvertDepthDir72_g1 , 1.0));
			float3 PositionFromDepth219 = (mul( unity_CameraToWorld, appendResult49_g1 )).xyz;
			float WaterDepth224 = ( ase_worldPos.y - (PositionFromDepth219).y );
			float clampResult233 = clamp( exp( ( -WaterDepth224 / _DeepRange ) ) , 0.0 , 1.0 );
			float4 lerpResult228 = lerp( _DeepColor , _ShallowColor , clampResult233);
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float fresnelNdotV237 = dot( ase_normWorldNormal, ase_worldViewDir );
			float fresnelNode237 = ( 0.0 + 1.0 * pow( max( 1.0 - fresnelNdotV237 , 0.0001 ), _FresnelPower ) );
			float4 lerpResult235 = lerp( lerpResult228 , _FresnelColor , fresnelNode237);
			float4 WaterColor239 = lerpResult235;
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float2 temp_output_252_0 = ( _NormalSpeed * _Time.y * 0.01 );
			float3 SurfaceNormal256 = BlendNormals( UnpackNormal( tex2D( _NormalMap, ( uv_NormalMap + temp_output_252_0 ) ) ) , UnpackNormal( tex2D( _NormalMap, ( ( uv_NormalMap * 2.0 ) + ( temp_output_252_0 * 0.5 ) ) ) ) );
			float3 lerpResult400 = lerp( float3(0,0,1) , SurfaceNormal256 , _ReflectDistort);
			float3 indirectNormal396 = WorldNormalVector( i , lerpResult400 );
			float fresnelNdotV294 = dot( ase_normWorldNormal, ase_worldViewDir );
			float fresnelNode294 = ( 0.0 + _ReflectIntensity * pow( max( 1.0 - fresnelNdotV294 , 0.0001 ), _ReflectPower ) );
			float clampResult298 = clamp( fresnelNode294 , 0.0 , 1.0 );
			Unity_GlossyEnvironmentData g396 = UnityGlossyEnvironmentSetup( 0.95, data.worldViewDir, indirectNormal396, float3(0,0,0));
			float3 indirectSpecular396 = UnityGI_IndirectSpecular( data, clampResult298, indirectNormal396, g396 );
			float3 ReflectColor275 = indirectSpecular396;
			float3 position188 = ase_worldPos;
			float3 tangent188 = float3( 1,0,0 );
			float3 binormal188 = float3( 0,0,1 );
			float4 wave188 = _WaveASpeedXYSteepnesswavelength;
			float3 localGerstnerWave188 = GerstnerWave188( position188 , tangent188 , binormal188 , wave188 );
			float3 position196 = ase_worldPos;
			float3 tangent196 = tangent188;
			float3 binormal196 = binormal188;
			float4 wave196 = _WaveB;
			float3 localGerstnerWave196 = GerstnerWave196( position196 , tangent196 , binormal196 , wave196 );
			float3 position203 = ase_worldPos;
			float3 tangent203 = tangent196;
			float3 binormal203 = binormal196;
			float4 wave203 = _WaveC;
			float3 localGerstnerWave203 = GerstnerWave203( position203 , tangent203 , binormal203 , wave203 );
			float3 temp_output_191_0 = ( ase_worldPos + localGerstnerWave188 + localGerstnerWave196 + localGerstnerWave203 );
			float clampResult209 = clamp( (( temp_output_191_0 - ase_worldPos )).y , 0.0 , 1.0 );
			float4 WaveColor212 = ( clampResult209 * _WaveColor );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor279 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ase_grabScreenPosNorm + float4( ( SurfaceNormal256 * _UnderWaterDistort * 0.01 ) , 0.0 ) ).xy);
			float4 SceneColor329 = screenColor279;
			float2 temp_output_301_0 = ( (PositionFromDepth219).xz / _CauasticsScale );
			float2 temp_output_306_0 = ( _CauasticsSpeed * _Time.y * 0.01 );
			float clampResult321 = clamp( exp( ( -WaterDepth224 / _CauasticsRange ) ) , 0.0 , 1.0 );
			float4 CauasticColor311 = ( ( min( tex2D( _CauasticsTex, ( temp_output_301_0 + temp_output_306_0 ) ) , tex2D( _CauasticsTex, ( -temp_output_301_0 + temp_output_306_0 ) ) ) * _CauasticsIntensity ) * clampResult321 );
			float4 UnderWaterColor287 = ( SceneColor329 + CauasticColor311 );
			float WaterOpacity242 = ( 1.0 - (lerpResult235).a );
			float4 lerpResult291 = lerp( ( WaterColor239 + float4( ReflectColor275 , 0.0 ) + WaveColor212 ) , UnderWaterColor287 , WaterOpacity242);
			float temp_output_9_0_g5 = _FoamContrast;
			float2 panner404 = ( ( _FoamFastSpeed * _Time.y ) * float2( 1,0 ) + i.uv_texcoord);
			float2 panner412 = ( ( _FoamSpeed * _Time.y ) * float2( 1,0 ) + i.uv_texcoord);
			float lerpResult414 = lerp( tex2D( _FoamNoise, panner404 ).r , tex2D( _FoamNoise, panner412 ).r , i.vertexColor.r);
			float clampResult421 = clamp( exp( ( -WaterDepth224 / _FoamRange ) ) , 0.0 , 1.0 );
			float clampResult428 = clamp( ( clampResult421 * i.vertexColor.g ) , 0.0 , 1.0 );
			float clampResult8_g5 = clamp( ( ( lerpResult414 - 1.0 ) + ( clampResult428 * 2.0 ) ) , 0.0 , 1.0 );
			float lerpResult12_g5 = lerp( ( 0.0 - temp_output_9_0_g5 ) , ( temp_output_9_0_g5 + 1.0 ) , clampResult8_g5);
			float clampResult13_g5 = clamp( lerpResult12_g5 , 0.0 , 1.0 );
			float4 FoamColor384 = ( _FoamColor * clampResult13_g5 );
			float4 lerpResult390 = lerp( lerpResult291 , ( lerpResult291 + float4( (FoamColor384).rgb , 0.0 ) ) , (FoamColor384).a);
			c.rgb = max( lerpResult390 , float4( 0,0,0,0 ) ).rgb;
			c.a = i.vertexColor.a;
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
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
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
				float2 customPack1 : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				half4 color : COLOR0;
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
				Input customInputData;
				vertexDataFunc( v );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				o.color = v.color;
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
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.screenPos = IN.screenPos;
				surfIN.vertexColor = IN.color;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
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
594;791;1906;1004;-1441.374;-2258.218;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;215;-679.2968,568.2693;Inherit;False;1517.458;392.4235;WaterDepth;7;224;220;222;216;219;218;217;WaterDepth;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;217;-650.3816,811.9634;Inherit;False;Reconstruct World Position From Depth;-1;;1;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;218;-234.3818,843.9634;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;245;-673.2817,1819.801;Inherit;False;2061.769;729.6726;SurfaceNormal;15;250;251;252;253;254;255;256;257;258;259;260;261;262;263;401;SurfaceNormal;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;254;-586.6357,2347.515;Inherit;False;Constant;_Float0;Float 0;11;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;253;-647.6355,2291.515;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;314;-679.3616,4235.717;Inherit;False;2524.356;769.0995;CausticsColor;24;311;322;321;312;320;313;310;318;304;306;301;319;317;300;309;303;308;307;316;299;323;324;325;326;CausticsColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;219;-15.38183,824.9634;Inherit;False;PositionFromDepth;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;251;-638.6355,2182.515;Inherit;False;Property;_NormalSpeed;NormalSpeed;14;0;Create;True;0;0;False;0;False;0,0;20,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;252;-346.8412,2199.335;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;260;-75.10674,2194.656;Inherit;False;Constant;_Float1;Float 1;12;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;401;-273.4307,1930.895;Inherit;False;0;255;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;262;-285.7383,2400.097;Inherit;False;Constant;_Float2;Float 2;12;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;299;-629.3616,4285.717;Inherit;False;219;PositionFromDepth;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;222;255.5639,836.4875;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;216;60.61816,606.9634;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;259;107.0608,2104.909;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;193;-672.3276,6455.187;Inherit;False;2542.907;761.6924;Wave Vertex Animation ;21;203;196;189;200;194;192;199;191;198;197;188;202;190;204;207;206;208;209;210;211;212;Wave Vertex Animation ;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;303;-389.7184,4450.347;Inherit;False;Property;_CauasticsScale;Cauastics Scale;19;0;Create;True;0;0;False;0;False;8;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;220;382.6183,641.9634;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;261;-86.68164,2325.995;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;300;-336.7183,4310.664;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;307;-528.0139,4710.676;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;258;284.1103,2180.287;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;308;-518.0139,4796.676;Inherit;False;Constant;_Float6;Float 6;19;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;224;611.3147,671.7977;Inherit;False;WaterDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;234;-677.7075,1054.508;Inherit;False;2058.288;663.3602;WaterColor;17;228;225;226;233;232;231;229;230;227;235;236;237;238;239;241;242;243;WaterColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;309;-572.0139,4574.676;Inherit;False;Property;_CauasticsSpeed;Cauastics Speed;21;0;Create;True;0;0;False;0;False;-8,0;-8,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector4Node;190;-593.9039,6834.913;Inherit;False;Property;_WaveASpeedXYSteepnesswavelength;WaveA(SpeedXY,Steepness,wavelength);5;0;Create;True;0;0;False;0;False;1,1,2,50;1,1,0,50;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;189;-551.9044,6536.913;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;250;252.4656,1953.244;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;385;1708.608,2409.594;Inherit;False;2055.526;1647.712;FoamColor;27;384;386;387;424;423;421;414;402;415;413;420;412;404;418;403;405;419;417;411;408;407;406;416;409;425;428;429;FoamColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;301;-97.27441,4385.125;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;227;-627.7075,1496.756;Inherit;False;224;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;188;-237.7303,6716.64;Inherit;False;float steepness = wave.z * 0.01@$float wavelength = wave.w@$float k = 2 * UNITY_PI / wavelength@$float c = sqrt(9.8 / k)@$float2 d = normalize(wave.xy)@$float f = k * (dot(d, position.xz) - c * _Time.y)@$float a = steepness / k@$			$$tangent += float3($-d.x * d.x * (steepness * sin(f)),$d.x * (steepness * cos(f)),$-d.x * d.y * (steepness * sin(f))$)@$$binormal += float3($-d.x * d.y * (steepness * sin(f)),$d.y * (steepness * cos(f)),$-d.y * d.y * (steepness * sin(f))$)@$$return float3($d.x * (a * cos(f)),$a * sin(f),$d.y * (a * cos(f))$)@;3;False;4;True;position;FLOAT3;0,0,0;In;;Inherit;False;True;tangent;FLOAT3;1,0,0;InOut;;Inherit;False;True;binormal;FLOAT3;0,0,1;InOut;;Inherit;False;True;wave;FLOAT4;0,0,0,0;In;;Inherit;False;GerstnerWave;True;False;0;4;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,0;False;2;FLOAT3;0,0,1;False;3;FLOAT4;0,0,0,0;False;3;FLOAT3;0;FLOAT3;2;FLOAT3;3
Node;AmplifyShaderEditor.SamplerNode;257;445.3838,2190.803;Inherit;True;Property;_TextureSample0;Texture Sample 0;15;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Instance;255;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;255;416.6126,1892.7;Inherit;True;Property;_NormalMap;NormalMap;15;0;Create;True;0;0;False;0;False;-1;None;972ba3323c209b54dacffe0942af5729;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;324;-17.89331,4671.255;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;316;657.9742,4776.841;Inherit;False;224;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;306;-302.5834,4692.504;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;202;-180.6752,6907.334;Inherit;False;Property;_WaveB;WaveB;6;0;Create;True;0;0;False;0;False;1,1,2,50;1,1,0,50;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;416;1801.907,3451.966;Inherit;False;224;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;417;2062.748,3540.554;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;230;-310.1289,1494.362;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;319;639.9323,4910.252;Inherit;False;Property;_CauasticsRange;Cauastics Range;24;0;Create;True;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;317;878.7321,4795.059;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;325;134.9153,4740.552;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;229;-388.129,1593.362;Inherit;False;Property;_DeepRange;Deep Range;11;0;Create;True;0;0;False;0;False;1;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;304;161.9861,4443.676;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CustomExpressionNode;196;143.252,6733.728;Inherit;False;float steepness = wave.z * 0.01@$float wavelength = wave.w@$float k = 2 * UNITY_PI / wavelength@$float c = sqrt(9.8 / k)@$float2 d = normalize(wave.xy)@$float f = k * (dot(d, position.xz) - c * _Time.y)@$float a = steepness / k@$			$$tangent += float3($-d.x * d.x * (steepness * sin(f)),$d.x * (steepness * cos(f)),$-d.x * d.y * (steepness * sin(f))$)@$$binormal += float3($-d.x * d.y * (steepness * sin(f)),$d.y * (steepness * cos(f)),$-d.y * d.y * (steepness * sin(f))$)@$$return float3($d.x * (a * cos(f)),$a * sin(f),$d.y * (a * cos(f))$)@;3;False;4;True;position;FLOAT3;0,0,0;In;;Inherit;False;True;tangent;FLOAT3;1,0,0;InOut;;Inherit;False;True;binormal;FLOAT3;0,0,1;InOut;;Inherit;False;True;wave;FLOAT4;0,0,0,0;In;;Inherit;False;GerstnerWave;True;False;0;4;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,0;False;2;FLOAT3;0,0,1;False;3;FLOAT4;0,0,0,0;False;3;FLOAT3;0;FLOAT3;2;FLOAT3;3
Node;AmplifyShaderEditor.BlendNormalsNode;263;762.7512,2142.188;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;204;238.1319,6924.125;Inherit;False;Property;_WaveC;WaveC;7;0;Create;True;0;0;False;0;False;1,1,2,50;1,1,0,50;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;419;2036.91,3717.73;Inherit;False;Property;_FoamRange;FoamRange;25;0;Create;True;0;0;False;0;False;1;0.27;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;256;982.2149,2138.799;Inherit;False;SurfaceNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;310;378.1145,4279.289;Inherit;True;Property;_CauasticsTex;CauasticsTex;20;0;Create;True;0;0;False;0;False;-1;None;4ab1d216348baa14ca2c92608a88695c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;409;1848.977,3020.827;Inherit;False;Property;_FoamSpeed;FoamSpeed;27;0;Create;True;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;288;-648.1119,3496.964;Inherit;False;1236.988;649.7175;UnderWaterColor;11;281;282;279;283;285;284;286;287;327;328;329;UnderWaterColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;323;381.4277,4545.357;Inherit;True;Property;_TextureSample1;Texture Sample 1;20;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;310;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;407;1805.549,2751.825;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;408;1840.977,3110.097;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;231;-143.1289,1535.362;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;406;1813.549,2662.555;Inherit;False;Property;_FoamFastSpeed;FoamFastSpeed;28;0;Create;True;0;0;False;0;False;1;2.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;418;2246.075,3592.23;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;203;410.5841,6761.917;Inherit;False;float steepness = wave.z * 0.01@$float wavelength = wave.w@$float k = 2 * UNITY_PI / wavelength@$float c = sqrt(9.8 / k)@$float2 d = normalize(wave.xy)@$float f = k * (dot(d, position.xz) - c * _Time.y)@$float a = steepness / k@$			$$tangent += float3($-d.x * d.x * (steepness * sin(f)),$d.x * (steepness * cos(f)),$-d.x * d.y * (steepness * sin(f))$)@$$binormal += float3($-d.x * d.y * (steepness * sin(f)),$d.y * (steepness * cos(f)),$-d.y * d.y * (steepness * sin(f))$)@$$return float3($d.x * (a * cos(f)),$a * sin(f),$d.y * (a * cos(f))$)@;3;False;4;True;position;FLOAT3;0,0,0;In;;Inherit;False;True;tangent;FLOAT3;1,0,0;InOut;;Inherit;False;True;binormal;FLOAT3;0,0,1;InOut;;Inherit;False;True;wave;FLOAT4;0,0,0,0;In;;Inherit;False;GerstnerWave;True;False;0;4;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,0;False;2;FLOAT3;0,0,1;False;3;FLOAT4;0,0,0,0;False;3;FLOAT3;0;FLOAT3;2;FLOAT3;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;318;1018.938,4856.741;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ExpOpNode;320;1162.089,4853.041;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;403;1813.549,2481.635;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;283;-580.7993,3821.495;Inherit;False;256;SurfaceNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;313;993.6005,4531.307;Inherit;False;Property;_CauasticsIntensity;Cauastics Intensity;23;0;Create;True;0;0;False;0;False;3;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;411;2115.598,3037.49;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;285;-593.7993,3929.495;Inherit;False;Property;_UnderWaterDistort;UnderWaterDistort;16;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;405;2080.169,2679.219;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;326;701.4454,4466.237;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;207;771.2634,6761.653;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;191;738.4705,6526.146;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ExpOpNode;420;2425.711,3611.917;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;264;-656.5028,2655.09;Inherit;False;2044.548;756.3464;ReflectColor;11;269;275;294;295;296;298;396;397;398;399;400;ReflectColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.ExpOpNode;232;15.87109,1491.362;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;286;-598.112,4031.681;Inherit;False;Constant;_Float5;Float 5;15;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;206;986.2631,6737.653;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;404;2318.223,2529.244;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;284;-339.7994,3863.495;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GrabScreenPosition;281;-573.1362,3545.684;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;296;-279.418,3067.044;Inherit;False;Property;_ReflectIntensity;ReflectIntensity;17;0;Create;True;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;412;2353.652,2887.517;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;226;-291.7721,1287.504;Inherit;False;Property;_ShallowColor;ShallowColor;9;0;Create;True;0;0;False;0;False;0,0,0,0;0.2901957,0.9529411,0.7803922,0.4588235;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;321;1294.348,4834.896;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;425;2333.384,3809.978;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;295;-283.8284,3166.13;Inherit;False;Property;_ReflectPower;ReflectPower;18;0;Create;True;0;0;False;0;False;5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;312;1213.706,4406.081;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;233;140.8711,1547.362;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;225;-286.3492,1104.508;Inherit;False;Property;_DeepColor;DeepColor;10;0;Create;True;0;0;False;0;False;0,0,0,0;0.06274475,0.3803917,0.3568623,0.446;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;238;305.7653,1589.531;Inherit;False;Property;_FresnelPower;FresnelPower;13;0;Create;True;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;421;2530.317,3667.092;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;402;2611.029,2517.343;Inherit;True;Property;_FoamNoise;FoamNoise;22;0;Create;True;0;0;False;0;False;-1;None;31e68d75d2651c148b4a9a296306d21c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;269;-45.23874,2859.469;Inherit;False;256;SurfaceNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;322;1427.431,4529.337;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;208;1158.263,6745.653;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;429;2706.675,3774.488;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;282;-328.5443,3657.215;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;413;2606.801,2766.164;Inherit;True;Property;_TextureSample2;Texture Sample 2;22;0;Create;True;0;0;False;0;False;-1;None;31e68d75d2651c148b4a9a296306d21c;True;0;False;white;Auto;False;Instance;402;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;236;316.6169,1413.283;Inherit;False;Property;_FresnelColor;FresnelColor;12;0;Create;True;0;0;False;0;False;0,0,0,0;0,0.1803917,0.2431368,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;237;562.1488,1495.039;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;415;2614.913,3044.733;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;294;-19.07351,3108.148;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;228;217.418,1253.698;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;399;-77.75757,2944.526;Inherit;False;Property;_ReflectDistort;Reflect Distort;29;0;Create;True;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;398;-5.757568,2701.526;Inherit;False;Constant;_Vector0;Vector 0;33;0;Create;True;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScreenColorNode;279;-105.3877,3568.627;Inherit;False;Global;_GrabScreen0;Grab Screen 0;14;0;Create;True;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;400;253.2424,2813.526;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;235;847.8387,1310.963;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;298;247.8686,3182.542;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;428;2888.063,3664.079;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;397;216.6369,3037.206;Inherit;False;Constant;_Float3;Float 3;34;0;Create;True;0;0;False;0;False;0.95;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;423;3077.05,3751.327;Inherit;False;Property;_FoamContrast;FoamContrast;26;0;Create;True;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;211;1198.325,6829.769;Inherit;False;Property;_WaveColor;WaveColor;8;0;Create;True;0;0;False;0;False;0,0,0,0;0.2901957,0.9529411,0.7803922,0.4588235;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;209;1336.555,6687.101;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;311;1545.705,4349.081;Inherit;False;CauasticColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;414;2826.415,3262.35;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;424;3252.082,3542.738;Inherit;False;HeightLerp;-1;;5;5b7e48aeb672921408225b5478ec5653;0;3;5;FLOAT;0;False;1;FLOAT;0;False;9;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;210;1540.555,6756.101;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;387;3028.563,3058.869;Inherit;False;Property;_FoamColor;FoamColor;30;0;Create;True;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;329;89.76661,3662.135;Inherit;False;SceneColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;328;-34.70018,3871.058;Inherit;False;311;CauasticColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;241;945.0409,1449.885;Inherit;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectSpecularLight;396;479.5517,2937.18;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;239;1113.091,1309.726;Inherit;False;WaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;243;1000.09,1615.246;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;386;3397.196,3114.63;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;275;852.7886,3071.038;Inherit;False;ReflectColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;327;246.6051,3770.887;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;212;1634.352,6581.563;Inherit;False;WaveColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;293;2158.708,1172.151;Inherit;False;239;WaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;287;323.8757,3638.25;Inherit;False;UnderWaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;242;1153.09,1509.246;Inherit;False;WaterOpacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;384;3456.51,2946.132;Inherit;False;FoamColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;395;2114.437,1385.51;Inherit;False;212;WaveColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;276;2129.836,1300.453;Inherit;False;275;ReflectColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;290;2237.175,1570.605;Inherit;False;242;WaterOpacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;388;2507.411,1834.799;Inherit;False;384;FoamColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CrossProductOpNode;197;818.7936,6981.518;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;289;2210.64,1474.576;Inherit;False;287;UnderWaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;292;2377.708,1291.151;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;291;2688.704,1520.881;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalizeNode;198;1017.793,7015.518;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;392;2702.319,1767.602;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;199;1217.793,6993.518;Inherit;False;World;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;389;2864.96,1858.376;Inherit;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;192;971.1472,6526.439;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;391;2880.82,1692.746;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;194;1274.627,6536.518;Inherit;False;WaveVertexPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;1467.793,7010.518;Inherit;False;WaveVertexNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;390;3083.521,1572.136;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;214;2233.375,892.7496;Inherit;False;212;WaveColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;430;3696.727,1447.144;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;393;3599.863,1740.069;Inherit;False;194;WaveVertexPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;195;1920.754,769.6491;Inherit;False;194;WaveVertexPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;354;3568.565,1565.584;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;1595.047,779.8349;Inherit;False;200;WaveVertexNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;394;3629.671,1837.954;Inherit;False;200;WaveVertexNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;244;2043.655,923.6302;Inherit;False;242;WaterOpacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;240;2426.082,891.5475;Inherit;False;239;WaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3916.815,1496.211;Float;False;True;-1;6;ASEMaterialInspector;0;0;CustomLighting;Toon_River;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;218;0;217;0
WireConnection;219;0;218;0
WireConnection;252;0;251;0
WireConnection;252;1;253;0
WireConnection;252;2;254;0
WireConnection;222;0;219;0
WireConnection;259;0;401;0
WireConnection;259;1;260;0
WireConnection;220;0;216;2
WireConnection;220;1;222;0
WireConnection;261;0;252;0
WireConnection;261;1;262;0
WireConnection;300;0;299;0
WireConnection;258;0;259;0
WireConnection;258;1;261;0
WireConnection;224;0;220;0
WireConnection;250;0;401;0
WireConnection;250;1;252;0
WireConnection;301;0;300;0
WireConnection;301;1;303;0
WireConnection;188;0;189;0
WireConnection;188;3;190;0
WireConnection;257;1;258;0
WireConnection;255;1;250;0
WireConnection;324;0;301;0
WireConnection;306;0;309;0
WireConnection;306;1;307;0
WireConnection;306;2;308;0
WireConnection;417;0;416;0
WireConnection;230;0;227;0
WireConnection;317;0;316;0
WireConnection;325;0;324;0
WireConnection;325;1;306;0
WireConnection;304;0;301;0
WireConnection;304;1;306;0
WireConnection;196;0;189;0
WireConnection;196;1;188;2
WireConnection;196;2;188;3
WireConnection;196;3;202;0
WireConnection;263;0;255;0
WireConnection;263;1;257;0
WireConnection;256;0;263;0
WireConnection;310;1;304;0
WireConnection;323;1;325;0
WireConnection;231;0;230;0
WireConnection;231;1;229;0
WireConnection;418;0;417;0
WireConnection;418;1;419;0
WireConnection;203;0;189;0
WireConnection;203;1;196;2
WireConnection;203;2;196;3
WireConnection;203;3;204;0
WireConnection;318;0;317;0
WireConnection;318;1;319;0
WireConnection;320;0;318;0
WireConnection;411;0;409;0
WireConnection;411;1;408;0
WireConnection;405;0;406;0
WireConnection;405;1;407;0
WireConnection;326;0;310;0
WireConnection;326;1;323;0
WireConnection;191;0;189;0
WireConnection;191;1;188;0
WireConnection;191;2;196;0
WireConnection;191;3;203;0
WireConnection;420;0;418;0
WireConnection;232;0;231;0
WireConnection;206;0;191;0
WireConnection;206;1;207;0
WireConnection;404;0;403;0
WireConnection;404;1;405;0
WireConnection;284;0;283;0
WireConnection;284;1;285;0
WireConnection;284;2;286;0
WireConnection;412;0;403;0
WireConnection;412;1;411;0
WireConnection;321;0;320;0
WireConnection;312;0;326;0
WireConnection;312;1;313;0
WireConnection;233;0;232;0
WireConnection;421;0;420;0
WireConnection;402;1;404;0
WireConnection;322;0;312;0
WireConnection;322;1;321;0
WireConnection;208;0;206;0
WireConnection;429;0;421;0
WireConnection;429;1;425;2
WireConnection;282;0;281;0
WireConnection;282;1;284;0
WireConnection;413;1;412;0
WireConnection;237;3;238;0
WireConnection;294;2;296;0
WireConnection;294;3;295;0
WireConnection;228;0;225;0
WireConnection;228;1;226;0
WireConnection;228;2;233;0
WireConnection;279;0;282;0
WireConnection;400;0;398;0
WireConnection;400;1;269;0
WireConnection;400;2;399;0
WireConnection;235;0;228;0
WireConnection;235;1;236;0
WireConnection;235;2;237;0
WireConnection;298;0;294;0
WireConnection;428;0;429;0
WireConnection;209;0;208;0
WireConnection;311;0;322;0
WireConnection;414;0;402;1
WireConnection;414;1;413;1
WireConnection;414;2;415;1
WireConnection;424;5;428;0
WireConnection;424;1;414;0
WireConnection;424;9;423;0
WireConnection;210;0;209;0
WireConnection;210;1;211;0
WireConnection;329;0;279;0
WireConnection;241;0;235;0
WireConnection;396;0;400;0
WireConnection;396;1;397;0
WireConnection;396;2;298;0
WireConnection;239;0;235;0
WireConnection;243;0;241;0
WireConnection;386;0;387;0
WireConnection;386;1;424;0
WireConnection;275;0;396;0
WireConnection;327;0;329;0
WireConnection;327;1;328;0
WireConnection;212;0;210;0
WireConnection;287;0;327;0
WireConnection;242;0;243;0
WireConnection;384;0;386;0
WireConnection;197;0;203;3
WireConnection;197;1;203;2
WireConnection;292;0;293;0
WireConnection;292;1;276;0
WireConnection;292;2;395;0
WireConnection;291;0;292;0
WireConnection;291;1;289;0
WireConnection;291;2;290;0
WireConnection;198;0;197;0
WireConnection;392;0;388;0
WireConnection;199;0;198;0
WireConnection;389;0;388;0
WireConnection;192;0;191;0
WireConnection;391;0;291;0
WireConnection;391;1;392;0
WireConnection;194;0;192;0
WireConnection;200;0;199;0
WireConnection;390;0;291;0
WireConnection;390;1;391;0
WireConnection;390;2;389;0
WireConnection;354;0;390;0
WireConnection;0;9;430;4
WireConnection;0;13;354;0
WireConnection;0;11;393;0
WireConnection;0;12;394;0
ASEEND*/
//CHKSM=2316472EA20F0348F198B299793CE65875E97D38