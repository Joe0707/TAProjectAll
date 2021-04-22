// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hexagon"
{
	Properties
	{
		_HitRampTex1("HitRampTex", 2D) = "white" {}
		_HitSpread1("HitSpread", Float) = 0
		_HitNoise1("HitNoise", 2D) = "white" {}
		_HitNoiseTilling1("HitNoiseTilling", Vector) = (1,1,1,0)
		_HitNoiseIntensity1("HitNoiseIntensity", Float) = 0
		_HitFadePower1("HitFadePower", Float) = 1
		_HitFadeDistance1("HitFadeDistance", Float) = 6
		_HitVertexOffset("HitVertexOffset", Float) = 0.1
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 15
		_Rimpower1("Rimpower", Float) = 2
		_RimScale1("RimScale", Float) = 1
		_RimBias1("RimBias", Float) = 0
		_EmissColor1("EmissColor", Color) = (0,0,0,0)
		_EmissIntensity1("EmissIntensity", Float) = 1
		_LineHexagon("LineHexagon", 2D) = "white" {}
		_HitWaveIntensity("HitWaveIntensity", Float) = 0.5
		_HexagonLineIntensity("HexagonLineIntensity", Float) = 0
		_LineEmissMask("LineEmissMask", 2D) = "white" {}
		_LineMaskSpeed("LineMaskSpeed", Vector) = (0.1,0.1,0,0)
		_LineEmissIntensity("LineEmissIntensity", Float) = 1
		_AuraTex("AuraTex", 2D) = "white" {}
		_AuraSpeed("AuraSpeed", Vector) = (0.02,0.035,0,0)
		_DissolvePoint1("DissolvePoint", Vector) = (0,0,0,0)
		_DissolveAmount1("DissolveAmount", Float) = 0
		_DissolveEdgeIntensity1("DissolveEdgeIntensity", Float) = 1
		_DissolveSpread1("DissolveSpread", Float) = 1
		_AuraIntensity("AuraIntensity", Float) = 1
		_AuraTexMask("AuraTexMask", 2D) = "white" {}
		_DepthFade("DepthFade", Float) = 1
		[HideInInspector] _texcoord3( "", 2D ) = "white" {}
		[HideInInspector] _texcoord4( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf Unlit alpha:fade keepalpha noshadow vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			half ASEVFace : VFACE;
			float2 uv_texcoord;
			float2 uv3_texcoord3;
			float2 uv4_texcoord4;
			float4 screenPos;
		};

		uniform float AffectorAmount;
		uniform float HitSize[20];
		uniform float4 HitPosition[20];
		uniform sampler2D _HitRampTex1;
		uniform sampler2D _HitNoise1;
		uniform float3 _HitNoiseTilling1;
		uniform float _HitNoiseIntensity1;
		uniform float _HitSpread1;
		uniform float _HitFadeDistance1;
		uniform float _HitFadePower1;
		uniform float _HitVertexOffset;
		uniform float3 _DissolvePoint1;
		uniform float _DissolveAmount1;
		uniform float _DissolveSpread1;
		uniform float4 _EmissColor1;
		uniform float _EmissIntensity1;
		uniform float _RimBias1;
		uniform float _RimScale1;
		uniform float _Rimpower1;
		uniform sampler2D _LineHexagon;
		uniform float _HexagonLineIntensity;
		uniform sampler2D _LineEmissMask;
		uniform float2 _LineMaskSpeed;
		uniform float _LineEmissIntensity;
		uniform sampler2D _AuraTex;
		uniform float2 _AuraSpeed;
		uniform float4 _AuraTex_ST;
		uniform float _AuraIntensity;
		uniform sampler2D _AuraTexMask;
		uniform float4 _AuraTexMask_ST;
		uniform float _DissolveEdgeIntensity1;
		uniform float _HitWaveIntensity;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DepthFade;
		uniform float _EdgeLength;


		inline float4 TriplanarSampling72( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.zy * float2(  nsign.x, 1.0 ), 0, 0) );
			yNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xz * float2(  nsign.y, 1.0 ), 0, 0) );
			zNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xy * float2( -nsign.z, 1.0 ), 0, 0) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		float HitWaveFunction_VS103( sampler2D RampTex, float3 WorldPos, float HitNoise, float HitSpread, float HitFadeDistance, float HitFadePower )
		{
			float hit_result;
			for(int j = 0;j < AffectorAmount;j++)
			{
			float distance_mask = distance(HitPosition[j].xyz,WorldPos);
			float hit_range = -clamp((distance_mask - HitSize[j] + HitNoise) / HitSpread,-1,0);
			float2 ramp_uv = float2(hit_range,0.5);
			float hit_wave = tex2Dlod(RampTex,float4(ramp_uv,0,0)).r; 
			float hit_fade = saturate((1.0 - distance_mask / HitFadeDistance) * HitFadePower);
			hit_result = hit_result + hit_fade * hit_wave;
			}
			return saturate(hit_result);
		}


		float HitWaveFunction81( sampler2D RampTex, float3 WorldPos, float HitNoise, float HitSpread, float HitFadeDistance, float HitFadePower )
		{
			float hit_result;
			for(int j = 0;j < AffectorAmount;j++)
			{
			float distance_mask = distance(HitPosition[j].xyz,WorldPos);
			float hit_range = -clamp((distance_mask - HitSize[j] + HitNoise) / HitSpread,-1,0);
			float2 ramp_uv = float2(hit_range,0.5);
			float hit_wave = tex2D(RampTex,ramp_uv).r; 
			float hit_fade = saturate((1.0 - distance_mask / HitFadeDistance) * HitFadePower);
			hit_result = hit_result + hit_fade * hit_wave;
			}
			return saturate(hit_result);
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			sampler2D RampTex103 = _HitRampTex1;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 objToWorld109 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float3 temp_output_3_0_g1 = ( ase_worldPos - objToWorld109 );
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float3 temp_output_6_0_g2 = ase_worldNormal;
			float dotResult1_g2 = dot( temp_output_3_0_g1 , temp_output_6_0_g2 );
			float dotResult2_g2 = dot( temp_output_6_0_g2 , temp_output_6_0_g2 );
			float3 PointToCenter113 = -( temp_output_3_0_g1 - ( ( dotResult1_g2 / dotResult2_g2 ) * temp_output_6_0_g2 ) );
			float3 HexagonCenter117 = ( ase_worldPos + PointToCenter113 );
			float3 WorldPos103 = HexagonCenter117;
			float4 triplanar72 = TriplanarSampling72( _HitNoise1, ( ase_worldPos * _HitNoiseTilling1 ), ase_worldNormal, 5.0, float2( 1,1 ), 1.0, 0 );
			float WaveNoise74 = triplanar72.x;
			float temp_output_76_0 = ( WaveNoise74 * _HitNoiseIntensity1 );
			float HitNoise103 = temp_output_76_0;
			float HitSpread103 = _HitSpread1;
			float HitFadeDistance103 = _HitFadeDistance1;
			float HitFadePower103 = _HitFadePower1;
			float localHitWaveFunction_VS103 = HitWaveFunction_VS103( RampTex103 , WorldPos103 , HitNoise103 , HitSpread103 , HitFadeDistance103 , HitFadePower103 );
			float HitWave_VS105 = localHitWaveFunction_VS103;
			float3 ase_vertexNormal = v.normal.xyz;
			float3 objToWorld125 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float clampResult138 = clamp( ( ( distance( ( HexagonCenter117 - objToWorld125 ) , _DissolvePoint1 ) - _DissolveAmount1 ) / _DissolveSpread1 ) , 0.0 , 1.0 );
			float temp_output_173_0 = ( 1.0 - clampResult138 );
			float3 worldToObj169 = mul( unity_WorldToObject, float4( ( ase_worldPos + ( PointToCenter113 * temp_output_173_0 ) ), 1 ) ).xyz;
			float3 DissolveVertexPosition170 = worldToObj169;
			v.vertex.xyz = ( ( ( HitWave_VS105 * ase_vertexNormal * 0.01 ) * _HitVertexOffset ) + DissolveVertexPosition170 );
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 switchResult10 = (((i.ASEVFace>0)?(ase_worldNormal):(-ase_worldNormal)));
			float fresnelNdotV14 = dot( switchResult10, ase_worldViewDir );
			float fresnelNode14 = ( _RimBias1 + _RimScale1 * pow( 1.0 - fresnelNdotV14, _Rimpower1 ) );
			float RimFactor16 = fresnelNode14;
			float4 tex2DNode22 = tex2D( _LineHexagon, i.uv_texcoord );
			float HexagonLine24 = tex2DNode22.r;
			sampler2D RampTex81 = _HitRampTex1;
			float3 WorldPos81 = ase_worldPos;
			float4 triplanar72 = TriplanarSampling72( _HitNoise1, ( ase_worldPos * _HitNoiseTilling1 ), ase_worldNormal, 5.0, float2( 1,1 ), 1.0, 0 );
			float WaveNoise74 = triplanar72.x;
			float temp_output_76_0 = ( WaveNoise74 * _HitNoiseIntensity1 );
			float HitNoise81 = temp_output_76_0;
			float HitSpread81 = _HitSpread1;
			float HitFadeDistance81 = _HitFadeDistance1;
			float HitFadePower81 = _HitFadePower1;
			float localHitWaveFunction81 = HitWaveFunction81( RampTex81 , WorldPos81 , HitNoise81 , HitSpread81 , HitFadeDistance81 , HitFadePower81 );
			float HitWave82 = localHitWaveFunction81;
			float2 panner31 = ( 1.0 * _Time.y * _LineMaskSpeed + ( ( HitWave82 * 0.2 ) + i.uv3_texcoord3 ));
			float LineEmiss36 = ( ( tex2DNode22.r * tex2D( _LineEmissMask, panner31 ).r ) * _LineEmissIntensity );
			float2 uv4_AuraTex = i.uv4_texcoord4 * _AuraTex_ST.xy + _AuraTex_ST.zw;
			float2 panner49 = ( 1.0 * _Time.y * ( _AuraSpeed * float2( 1.5,2 ) ) + ( uv4_AuraTex * float2( 0.5,0.5 ) ));
			float2 panner41 = ( 1.0 * _Time.y * _AuraSpeed + ( uv4_AuraTex + ( (tex2D( _AuraTex, panner49 )).rg * 0.5 ) + ( HitWave82 * 0.2 ) ));
			float4 tex2DNode39 = tex2D( _AuraTex, panner41 );
			float2 uv4_AuraTexMask = i.uv4_texcoord4 * _AuraTexMask_ST.xy + _AuraTexMask_ST.zw;
			float2 panner56 = ( 1.0 * _Time.y * float2( 0,0.02 ) + uv4_AuraTexMask);
			float AuraColor44 = ( ( tex2DNode39.r * _AuraIntensity ) + ( tex2DNode39.r * tex2D( _AuraTexMask, panner56 ).r * 2.0 ) );
			float3 objToWorld109 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float3 temp_output_3_0_g1 = ( ase_worldPos - objToWorld109 );
			float3 temp_output_6_0_g2 = ase_worldNormal;
			float dotResult1_g2 = dot( temp_output_3_0_g1 , temp_output_6_0_g2 );
			float dotResult2_g2 = dot( temp_output_6_0_g2 , temp_output_6_0_g2 );
			float3 PointToCenter113 = -( temp_output_3_0_g1 - ( ( dotResult1_g2 / dotResult2_g2 ) * temp_output_6_0_g2 ) );
			float3 HexagonCenter117 = ( ase_worldPos + PointToCenter113 );
			float3 objToWorld125 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float clampResult138 = clamp( ( ( distance( ( HexagonCenter117 - objToWorld125 ) , _DissolvePoint1 ) - _DissolveAmount1 ) / _DissolveSpread1 ) , 0.0 , 1.0 );
			float temp_output_173_0 = ( 1.0 - clampResult138 );
			float temp_output_149_0 = step( 0.01 , clampResult138 );
			float DissolveEmiss150 = ( ( temp_output_173_0 * temp_output_149_0 ) * _DissolveEdgeIntensity1 );
			float temp_output_26_0 = ( RimFactor16 + ( HexagonLine24 * _HexagonLineIntensity ) + LineEmiss36 + AuraColor44 + ( DissolveEmiss150 + ( DissolveEmiss150 * HexagonLine24 ) ) );
			float temp_output_90_0 = ( temp_output_26_0 + ( ( temp_output_26_0 + _HitWaveIntensity ) * HitWave82 ) );
			o.Emission = ( _EmissColor1 * _EmissIntensity1 * temp_output_90_0 ).rgb;
			float clampResult21 = clamp( temp_output_90_0 , 0.0 , 1.0 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth63 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth63 = abs( ( screenDepth63 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFade ) );
			float clampResult66 = clamp( distanceDepth63 , 0.0 , 1.0 );
			float DissolveAlpha148 = temp_output_149_0;
			o.Alpha = ( clampResult21 * clampResult66 * DissolveAlpha148 );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
7;29;1522;788;2364.814;-2333.731;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;118;-3533.022,1643.776;Inherit;False;1734.304;497.7905;HexagonCenter;10;110;113;111;114;117;115;106;109;107;116;HexagonCenter;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;106;-3465.687,1693.776;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;109;-3483.022,1885.2;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;107;-3154.347,1816.431;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;111;-3174.794,1962.567;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;110;-2907.588,1902.392;Inherit;False;Rejection;-1;;1;ea6ca936e02c9e74fae837451ff893c3;0;2;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;67;-5826.464,-1569.111;Inherit;False;2291.384;1279.597;HitWave;22;85;84;83;82;81;80;79;78;77;76;75;74;73;72;71;70;69;68;103;104;105;121;HitWave;0.489655,1,0,1;0;0
Node;AmplifyShaderEditor.NegateNode;115;-2681.322,1914.813;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;68;-5770.825,-911.9452;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;69;-5743.825,-743.9453;Inherit;False;Property;_HitNoiseTilling1;HitNoiseTilling;3;0;Create;True;0;0;False;0;False;1,1,1;0.1,0.1,0.1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;113;-2491.121,1896.082;Inherit;False;PointToCenter;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;114;-2663.74,1703.157;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-5495.826,-918.9453;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;71;-5769.825,-1145.945;Inherit;True;Property;_HitNoise1;HitNoise;2;0;Create;True;0;0;False;0;False;None;3c506748d17579d4a85691a58877ff1e;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;116;-2229.959,1761.66;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TriplanarNode;72;-5331.586,-948.416;Inherit;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;5;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;62;-3787.438,591.197;Inherit;False;2880.448;745.1689;AuraColor;23;43;40;51;50;49;48;53;61;60;55;52;41;56;54;58;46;39;45;57;59;44;91;92;AuraColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;124;-3768.761,2352.448;Inherit;False;3052.204;676.084;Dissolve;23;138;137;136;133;131;130;128;127;125;147;148;149;150;161;162;165;166;167;168;169;170;173;174;Dissolve;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;117;-2051.718,1789.687;Inherit;False;HexagonCenter;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;40;-3737.438,655.9207;Inherit;False;3;39;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;73;-5365.974,-1096.125;Inherit;False;Property;_HitNoiseIntensity1;HitNoiseIntensity;4;0;Create;True;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;74;-4945.18,-927.3885;Inherit;False;WaveNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;147;-3747.778,2374.358;Inherit;False;117;HexagonCenter;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;125;-3735.773,2551.2;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector2Node;43;-3500.68,846.483;Inherit;False;Property;_AuraSpeed;AuraSpeed;25;0;Create;True;0;0;False;0;False;0.02,0.035;0.02,0.03;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;75;-4635.203,-670.5944;Inherit;False;Property;_HitFadePower1;HitFadePower;5;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;79;-4624.367,-1174.264;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-4581.404,-1044.223;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;77;-4634.742,-1423.334;Inherit;True;Property;_HitRampTex1;HitRampTex;0;0;Create;True;0;0;False;0;False;None;bfb5d11eb2154099bda5558461f45026;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;80;-4670.405,-785.4948;Inherit;False;Property;_HitFadeDistance1;HitFadeDistance;6;0;Create;True;0;0;False;0;False;6;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-3589.259,1006.841;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;128;-3490.774,2448.2;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;127;-3708.963,2735.9;Inherit;False;Property;_DissolvePoint1;DissolvePoint;26;0;Create;True;0;0;False;0;False;0,0,0;-22.06,2.03,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-3302.654,1075.839;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;1.5,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-4617.972,-908.7768;Inherit;False;Property;_HitSpread1;HitSpread;1;0;Create;True;0;0;False;0;False;0;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;81;-4264.588,-1101.374;Inherit;False;float hit_result@$$for(int j = 0@j < AffectorAmount@j++)${$$float distance_mask = distance(HitPosition[j].xyz,WorldPos)@$$float hit_range = -clamp((distance_mask - HitSize[j] + HitNoise) / HitSpread,-1,0)@$$float2 ramp_uv = float2(hit_range,0.5)@$$float hit_wave = tex2D(RampTex,ramp_uv).r@ $$float hit_fade = saturate((1.0 - distance_mask / HitFadeDistance) * HitFadePower)@$$hit_result = hit_result + hit_fade * hit_wave@$}$$return saturate(hit_result)@;1;False;6;True;RampTex;SAMPLER2D;;In;;Inherit;False;True;WorldPos;FLOAT3;0,0,0;In;;Inherit;False;True;HitNoise;FLOAT;0;In;;Inherit;False;True;HitSpread;FLOAT;0;In;;Inherit;False;True;HitFadeDistance;FLOAT;0;In;;Inherit;False;True;HitFadePower;FLOAT;0;In;;Inherit;False;HitWaveFunction;True;False;0;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;49;-3017.815,997.9954;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;131;-3287.761,2485.273;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;130;-3294.761,2631.273;Inherit;False;Property;_DissolveAmount1;DissolveAmount;27;0;Create;True;0;0;False;0;False;0;32.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;48;-2779.373,997.4578;Inherit;True;Property;_AuraTex1;AuraTex;24;0;Create;True;0;0;False;0;False;-1;None;57451d90cad4e93448f1dbe1a84a7c70;True;0;False;white;Auto;False;Instance;39;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;38;-971.1365,-184.0475;Inherit;False;1642.076;650.0495;LineColor;14;30;32;23;31;29;22;33;35;24;34;36;94;95;96;LineColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;82;-3998.146,-1087.168;Inherit;False;HitWave;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-2795.619,2727.36;Inherit;False;Property;_DissolveSpread1;DissolveSpread;29;0;Create;True;0;0;False;0;False;1;-4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;133;-3091.193,2553.68;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-2445.371,1016.542;Inherit;False;Constant;_Float1;Float 1;14;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-2619.675,639.5898;Inherit;False;82;HitWave;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;-936.1319,1.649948;Inherit;False;82;HitWave;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;137;-2512.985,2595.53;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;53;-2460.17,878.0991;Inherit;False;FLOAT2;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-757.4783,21.95125;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;138;-2263.648,2633.024;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;30;-921.1366,157.6149;Inherit;False;2;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-2280.271,926.8424;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-2452.675,712.5898;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;55;-2444.758,1133.083;Inherit;False;3;54;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-2279.24,641.197;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;96;-614.0143,72.02808;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;32;-910.3796,305.002;Inherit;False;Property;_LineMaskSpeed;LineMaskSpeed;22;0;Create;True;0;0;False;0;False;0.1,0.1;0.015,0.015;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.OneMinusNode;173;-2062.567,2618.154;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;149;-2048.648,2902.017;Inherit;False;2;0;FLOAT;0.01;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;31;-448.2664,98.89748;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;4;-2887.681,-137.2011;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;161;-1675.746,2818.498;Inherit;False;Property;_DissolveEdgeIntensity1;DissolveEdgeIntensity;28;0;Create;True;0;0;False;0;False;1;15.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;56;-2126.758,1163.083;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.02;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-844.7155,-122.838;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;174;-1806.814,2702.731;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;41;-2072.739,670.653;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;29;-400.9958,241.5969;Inherit;True;Property;_LineEmissMask;LineEmissMask;21;0;Create;True;0;0;False;0;False;-1;None;b2ebe4a36fc94024d91fe15b52fe5772;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;58;-1559.612,1194.308;Inherit;False;Constant;_Float0;Float 0;14;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;162;-1328.114,2676.578;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1;-2314.737,-193.1971;Inherit;False;1223.452;626.6119;RimFactor;6;16;14;9;8;12;10;RimFactor;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;22;-448.0119,-134.0475;Inherit;True;Property;_LineHexagon;LineHexagon;18;0;Create;True;0;0;False;0;False;-1;None;373bb7a955475ea4a82cd75a31359196;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;5;-2659.684,38.33688;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1737.18,869.5765;Inherit;False;Property;_AuraIntensity;AuraIntensity;30;0;Create;True;0;0;False;0;False;1;0.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;39;-1870.882,659.4355;Inherit;True;Property;_AuraTex;AuraTex;24;0;Create;True;0;0;False;0;False;-1;57451d90cad4e93448f1dbe1a84a7c70;57451d90cad4e93448f1dbe1a84a7c70;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;54;-1853.238,1106.366;Inherit;True;Property;_AuraTexMask;AuraTexMask;31;0;Create;True;0;0;False;0;False;-1;None;aeb46886909512e41842722f15bb898b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-108.5419,-71.33612;Inherit;False;HexagonLine;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-1419.204,1018.126;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwitchByFaceNode;10;-2302.556,-135.1841;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-101.364,249.0595;Inherit;False;Property;_LineEmissIntensity;LineEmissIntensity;23;0;Create;True;0;0;False;0;False;1;1.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-2264.737,-42.87506;Inherit;False;Property;_RimBias1;RimBias;15;0;Create;True;0;0;False;0;False;0;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;150;-999.851,2638.599;Inherit;False;DissolveEmiss;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-16.37412,86.61081;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-2075.737,96.12498;Inherit;False;Property;_Rimpower1;Rimpower;13;0;Create;True;0;0;False;0;False;2;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-2122.737,16.12496;Inherit;False;Property;_RimScale1;RimScale;14;0;Create;True;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-1446.957,710.2272;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;14;-1735.555,-143.1971;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;187.9412,-431.098;Inherit;False;24;HexagonLine;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;183.7281,185.5862;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;178.4959,-538.1154;Inherit;False;150;DissolveEmiss;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;59;-1234.482,917.5452;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;174.1524,-808.5485;Inherit;False;Property;_HexagonLineIntensity;HexagonLineIntensity;20;0;Create;True;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-1363.064,-153.8176;Inherit;False;RimFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;-4869.127,-1241.323;Inherit;False;117;HexagonCenter;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;158;434.9412,-463.098;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;-1149.99,721.3161;Inherit;False;AuraColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;427.9391,218.9366;Inherit;False;LineEmiss;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;257.2124,-954.236;Inherit;False;24;HexagonLine;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;522.9572,-1029.253;Inherit;False;16;RimFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;103;-4199.914,-1415.311;Inherit;False;float hit_result@$$for(int j = 0@j < AffectorAmount@j++)${$$float distance_mask = distance(HitPosition[j].xyz,WorldPos)@$$float hit_range = -clamp((distance_mask - HitSize[j] + HitNoise) / HitSpread,-1,0)@$$float2 ramp_uv = float2(hit_range,0.5)@$$float hit_wave = tex2Dlod(RampTex,float4(ramp_uv,0,0)).r@ $$float hit_fade = saturate((1.0 - distance_mask / HitFadeDistance) * HitFadePower)@$$hit_result = hit_result + hit_fade * hit_wave@$}$$return saturate(hit_result)@;1;False;6;True;RampTex;SAMPLER2D;;In;;Inherit;False;True;WorldPos;FLOAT3;0,0,0;In;;Inherit;False;True;HitNoise;FLOAT;0;In;;Inherit;False;True;HitSpread;FLOAT;0;In;;Inherit;False;True;HitFadeDistance;FLOAT;0;In;;Inherit;False;True;HitFadePower;FLOAT;0;In;;Inherit;False;HitWaveFunction_VS;True;False;0;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;166;-2304.377,2466.005;Inherit;False;113;PointToCenter;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;464.9498,-739.9307;Inherit;False;36;LineEmiss;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;491.1555,-870.7343;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;159;595.9412,-527.098;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;366.2831,-632.6476;Inherit;False;44;AuraColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;167;-2490.108,2382.325;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;26;715.0759,-1024.997;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;165;-1985.543,2448.078;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;87;797.5604,-826.2371;Inherit;False;Property;_HitWaveIntensity;HitWaveIntensity;19;0;Create;True;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;104;-3928.922,-1405.324;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;105;-3744.323,-1305.224;Inherit;False;HitWave_VS;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;918.4441,-720.8041;Inherit;False;82;HitWave;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;1075.794,-968.3317;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;168;-1844.96,2381.005;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;97;802.0941,-194.8888;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;100;898.0941,-33.88879;Inherit;False;Constant;_Float2;Float 2;23;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;705.3983,-416.6173;Inherit;False;Property;_DepthFade;DepthFade;32;0;Create;True;0;0;False;0;False;1;2.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;854.0941,-289.8888;Inherit;False;105;HitWave_VS;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;1199.046,-825.5793;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;169;-1711.96,2392.416;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DepthFade;63;913.5195,-490.8178;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;1205.771,-1081.852;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;148;-1817.101,2938.556;Inherit;False;DissolveAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;170;-1345.057,2397.379;Inherit;False;DissolveVertexPosition;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;102;1089.094,-46.88879;Inherit;False;Property;_HitVertexOffset;HitVertexOffset;7;0;Create;True;0;0;False;0;False;0.1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;1094.094,-263.8888;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;21;1366.501,-774.0885;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;1317.094,-112.8888;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;172;1143.819,97.45948;Inherit;False;170;DissolveVertexPosition;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;66;1201.97,-586.2792;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;767.2443,-1151.212;Inherit;False;Property;_EmissIntensity1;EmissIntensity;17;0;Create;True;0;0;False;0;False;1;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;18;842.4486,-1351.272;Inherit;False;Property;_EmissColor1;EmissColor;16;0;Create;True;0;0;False;0;False;0,0,0,0;0.09558821,0.550913,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;156;1185.931,-390.7603;Inherit;False;148;DissolveAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;1399.33,-624.4582;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GlobalArrayNode;83;-4812.808,-1519.111;Inherit;False;HitSize;0;20;0;False;False;0;1;True;Object;-1;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GlobalArrayNode;85;-5071.026,-1518.047;Inherit;False;HitPosition;0;20;2;False;False;0;1;True;Object;-1;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;1359.546,-1248.74;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;171;1498.539,-45.97074;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-4585.24,-1509.854;Inherit;False;Global;AffectorAmount;AffectorAmount;4;0;Create;False;0;0;True;0;False;20;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1769.493,-1001.275;Float;False;True;-1;6;ASEMaterialInspector;0;0;Unlit;Hexagon;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;-1;-1;8;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;107;0;106;0
WireConnection;107;1;109;0
WireConnection;110;3;107;0
WireConnection;110;4;111;0
WireConnection;115;0;110;0
WireConnection;113;0;115;0
WireConnection;70;0;68;0
WireConnection;70;1;69;0
WireConnection;116;0;114;0
WireConnection;116;1;113;0
WireConnection;72;0;71;0
WireConnection;72;9;70;0
WireConnection;117;0;116;0
WireConnection;74;0;72;1
WireConnection;76;0;74;0
WireConnection;76;1;73;0
WireConnection;50;0;40;0
WireConnection;128;0;147;0
WireConnection;128;1;125;0
WireConnection;51;0;43;0
WireConnection;81;0;77;0
WireConnection;81;1;79;0
WireConnection;81;2;76;0
WireConnection;81;3;78;0
WireConnection;81;4;80;0
WireConnection;81;5;75;0
WireConnection;49;0;50;0
WireConnection;49;2;51;0
WireConnection;131;0;128;0
WireConnection;131;1;127;0
WireConnection;48;1;49;0
WireConnection;82;0;81;0
WireConnection;133;0;131;0
WireConnection;133;1;130;0
WireConnection;137;0;133;0
WireConnection;137;1;136;0
WireConnection;53;0;48;0
WireConnection;95;0;94;0
WireConnection;138;0;137;0
WireConnection;60;0;53;0
WireConnection;60;1;61;0
WireConnection;92;0;91;0
WireConnection;52;0;40;0
WireConnection;52;1;60;0
WireConnection;52;2;92;0
WireConnection;96;0;95;0
WireConnection;96;1;30;0
WireConnection;173;0;138;0
WireConnection;149;1;138;0
WireConnection;31;0;96;0
WireConnection;31;2;32;0
WireConnection;56;0;55;0
WireConnection;174;0;173;0
WireConnection;174;1;149;0
WireConnection;41;0;52;0
WireConnection;41;2;43;0
WireConnection;29;1;31;0
WireConnection;162;0;174;0
WireConnection;162;1;161;0
WireConnection;22;1;23;0
WireConnection;5;0;4;0
WireConnection;39;1;41;0
WireConnection;54;1;56;0
WireConnection;24;0;22;1
WireConnection;57;0;39;1
WireConnection;57;1;54;1
WireConnection;57;2;58;0
WireConnection;10;0;4;0
WireConnection;10;1;5;0
WireConnection;150;0;162;0
WireConnection;33;0;22;1
WireConnection;33;1;29;1
WireConnection;45;0;39;1
WireConnection;45;1;46;0
WireConnection;14;0;10;0
WireConnection;14;1;8;0
WireConnection;14;2;9;0
WireConnection;14;3;12;0
WireConnection;34;0;33;0
WireConnection;34;1;35;0
WireConnection;59;0;45;0
WireConnection;59;1;57;0
WireConnection;16;0;14;0
WireConnection;158;0;151;0
WireConnection;158;1;157;0
WireConnection;44;0;59;0
WireConnection;36;0;34;0
WireConnection;103;0;77;0
WireConnection;103;1;121;0
WireConnection;103;2;76;0
WireConnection;103;3;78;0
WireConnection;103;4;80;0
WireConnection;103;5;75;0
WireConnection;27;0;25;0
WireConnection;27;1;28;0
WireConnection;159;0;151;0
WireConnection;159;1;158;0
WireConnection;26;0;20;0
WireConnection;26;1;27;0
WireConnection;26;2;37;0
WireConnection;26;3;47;0
WireConnection;26;4;159;0
WireConnection;165;0;166;0
WireConnection;165;1;173;0
WireConnection;104;0;103;0
WireConnection;105;0;104;0
WireConnection;88;0;26;0
WireConnection;88;1;87;0
WireConnection;168;0;167;0
WireConnection;168;1;165;0
WireConnection;89;0;88;0
WireConnection;89;1;86;0
WireConnection;169;0;168;0
WireConnection;63;0;64;0
WireConnection;90;0;26;0
WireConnection;90;1;89;0
WireConnection;148;0;149;0
WireConnection;170;0;169;0
WireConnection;98;0;99;0
WireConnection;98;1;97;0
WireConnection;98;2;100;0
WireConnection;21;0;90;0
WireConnection;101;0;98;0
WireConnection;101;1;102;0
WireConnection;66;0;63;0
WireConnection;65;0;21;0
WireConnection;65;1;66;0
WireConnection;65;2;156;0
WireConnection;19;0;18;0
WireConnection;19;1;17;0
WireConnection;19;2;90;0
WireConnection;171;0;101;0
WireConnection;171;1;172;0
WireConnection;0;2;19;0
WireConnection;0;9;65;0
WireConnection;0;11;171;0
ASEEND*/
//CHKSM=6DDDA4F0A3FEE58A78B35620F02C4330AA70C39E