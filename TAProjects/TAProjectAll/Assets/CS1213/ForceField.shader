// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ForceField"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", Float) = 0
		_HitRampTex("HitRampTex", 2D) = "white" {}
		_HitSpread("HitSpread", Float) = 0
		_HitNoise("HitNoise", 2D) = "white" {}
		_HitNoiseTilling("HitNoiseTilling", Vector) = (1,1,1,0)
		_HitNoiseIntensity("HitNoiseIntensity", Float) = 0
		_HitFadePower("HitFadePower", Float) = 1
		_HitFadeDistance("HitFadeDistance", Float) = 6
		_HitWaveIntensity("HitWaveIntensity", Float) = 0.5
		_Rimpower("Rimpower", Float) = 2
		_RimScale("RimScale", Float) = 1
		_RimBias("RimBias", Float) = 0
		_EmissColor("EmissColor", Color) = (0,0,0,0)
		_EmissIntensity("EmissIntensity", Float) = 1
		_Size("Size", Range( 0 , 10)) = 1
		_FlowLight("FlowLight", 2D) = "white" {}
		_FlowStrength("FlowStrength", Vector) = (0.2,0.2,0,0)
		_FlowMap("FlowMap", 2D) = "white" {}
		_FlowSpeed("FlowSpeed", Float) = 0.2
		_DepthFadePower("DepthFadePower", Float) = 1
		_DepthFade("DepthFade", Float) = 1
		_DissolvePoint("DissolvePoint", Vector) = (0,0,0,0)
		_DissolveAmount("DissolveAmount", Float) = 0
		_DissolveSpread("DissolveSpread", Float) = 1
		_DissolveNoise("DissolveNoise", Float) = 1
		_DissolveEdgeIntensity("DissolveEdgeIntensity", Float) = 1
		_DissolveRampTex("DissolveRampTex", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull [_CullMode]
		CGPROGRAM
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit alpha:fade keepalpha noshadow 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			half ASEVFace : VFACE;
			float4 screenPos;
			float2 uv_texcoord;
		};

		uniform float AffectorAmount;
		uniform float _CullMode;
		uniform float HitSize[20];
		uniform float4 HitPosition[20];
		uniform float4 _EmissColor;
		uniform float _EmissIntensity;
		uniform float _RimBias;
		uniform float _RimScale;
		uniform float _Rimpower;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DepthFade;
		uniform float _DepthFadePower;
		uniform sampler2D _FlowLight;
		uniform float4 _FlowLight_ST;
		uniform float _Size;
		uniform sampler2D _FlowMap;
		uniform sampler2D _HitRampTex;
		uniform sampler2D _HitNoise;
		uniform float3 _HitNoiseTilling;
		uniform float _HitNoiseIntensity;
		uniform float _HitSpread;
		uniform float _HitFadeDistance;
		uniform float _HitFadePower;
		uniform float2 _FlowStrength;
		uniform float _FlowSpeed;
		uniform float _HitWaveIntensity;
		uniform sampler2D _DissolveRampTex;
		uniform float3 _DissolvePoint;
		uniform float _DissolveAmount;
		uniform float _DissolveNoise;
		uniform float _DissolveSpread;
		uniform float _DissolveEdgeIntensity;


		inline float4 TriplanarSampling42( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		float HitWaveFunction35( sampler2D RampTex, float3 WorldPos, float HitNoise, float HitSpread, float HitFadeDistance, float HitFadePower )
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
			float3 switchResult212 = (((i.ASEVFace>0)?(ase_worldNormal):(-ase_worldNormal)));
			float fresnelNdotV132 = dot( switchResult212, ase_worldViewDir );
			float fresnelNode132 = ( _RimBias + _RimScale * pow( 1.0 - fresnelNdotV132, _Rimpower ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth170 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth170 = abs( ( screenDepth170 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFade ) );
			float clampResult172 = clamp( ( 1.0 - distanceDepth170 ) , 0.0 , 1.0 );
			float RimFactor136 = ( fresnelNode132 + pow( clampResult172 , _DepthFadePower ) );
			float2 uv_FlowLight = i.uv_texcoord * _FlowLight_ST.xy + _FlowLight_ST.zw;
			float2 temp_output_4_0_g1 = (( uv_FlowLight / _Size )).xy;
			float2 temp_cast_0 = (0.5).xx;
			sampler2D RampTex35 = _HitRampTex;
			float3 WorldPos35 = ase_worldPos;
			float4 triplanar42 = TriplanarSampling42( _HitNoise, ( ase_worldPos * _HitNoiseTilling ), ase_worldNormal, 5.0, float2( 1,1 ), 1.0, 0 );
			float WaveNoise123 = triplanar42.x;
			float HitNoise35 = ( WaveNoise123 * _HitNoiseIntensity );
			float HitSpread35 = _HitSpread;
			float HitFadeDistance35 = _HitFadeDistance;
			float HitFadePower35 = _HitFadePower;
			float localHitWaveFunction35 = HitWaveFunction35( RampTex35 , WorldPos35 , HitNoise35 , HitSpread35 , HitFadeDistance35 , HitFadePower35 );
			float HitWave47 = localHitWaveFunction35;
			float2 temp_output_41_0_g1 = ( ( ( (tex2D( _FlowMap, i.uv_texcoord )).rg - temp_cast_0 ) + HitWave47 ) + 0.5 );
			float2 temp_output_17_0_g1 = _FlowStrength;
			float mulTime22_g1 = _Time.y * _FlowSpeed;
			float temp_output_27_0_g1 = frac( mulTime22_g1 );
			float2 temp_output_11_0_g1 = ( temp_output_4_0_g1 + ( temp_output_41_0_g1 * temp_output_17_0_g1 * temp_output_27_0_g1 ) );
			float2 temp_output_12_0_g1 = ( temp_output_4_0_g1 + ( temp_output_41_0_g1 * temp_output_17_0_g1 * frac( ( mulTime22_g1 + 0.5 ) ) ) );
			float4 lerpResult9_g1 = lerp( tex2D( _FlowLight, temp_output_11_0_g1 ) , tex2D( _FlowLight, temp_output_12_0_g1 ) , ( abs( ( temp_output_27_0_g1 - 0.5 ) ) / 0.5 ));
			float4 temp_cast_1 = (RimFactor136).xxxx;
			float smoothstepResult164 = smoothstep( 0.85 , 1.0 , i.uv_texcoord.y);
			float4 lerpResult162 = lerp( lerpResult9_g1 , temp_cast_1 , smoothstepResult164);
			float4 FlowColor156 = lerpResult162;
			float4 temp_output_167_0 = ( RimFactor136 * FlowColor156 );
			float3 objToWorld188 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float clampResult194 = clamp( ( ( ( distance( _DissolvePoint , ( ase_worldPos - objToWorld188 ) ) - _DissolveAmount ) - ( WaveNoise123 * _DissolveNoise ) ) / _DissolveSpread ) , 0.0 , 1.0 );
			float temp_output_198_0 = ( 1.0 - clampResult194 );
			float2 appendResult197 = (float2(temp_output_198_0 , 0.5));
			float DissolveEdge189 = ( tex2D( _DissolveRampTex, appendResult197 ).r * _DissolveEdgeIntensity );
			float4 temp_output_178_0 = ( temp_output_167_0 + ( ( temp_output_167_0 + _HitWaveIntensity ) * HitWave47 ) + DissolveEdge189 );
			o.Emission = ( ( _EmissColor * _EmissIntensity ) * temp_output_178_0 ).rgb;
			float grayscale169 = Luminance(temp_output_178_0.rgb);
			float smoothstepResult199 = smoothstep( 0.0 , 0.1 , temp_output_198_0);
			float DissolveAlpha200 = smoothstepResult199;
			float clampResult143 = clamp( ( grayscale169 * DissolveAlpha200 ) , 0.0 , 1.0 );
			o.Alpha = clampResult143;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
7;29;1522;788;1841.222;-2605.407;1.320925;True;False
Node;AmplifyShaderEditor.CommentaryNode;41;-3148.643,-294.2226;Inherit;False;2291.384;1279.597;HitWave;18;37;35;40;39;28;13;30;36;16;5;17;42;43;46;44;45;47;123;HitWave;0.489655,1,0,1;0;0
Node;AmplifyShaderEditor.Vector3Node;45;-3066.004,530.9434;Inherit;False;Property;_HitNoiseTilling;HitNoiseTilling;4;0;Create;True;0;0;False;0;False;1,1,1;0.1,0.1,0.1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;44;-3093.004,362.9435;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;43;-3092.004,128.9434;Inherit;True;Property;_HitNoise;HitNoise;3;0;Create;True;0;0;False;0;False;None;aeb46886909512e41842722f15bb898b;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CommentaryNode;137;-3035.823,1058.004;Inherit;False;2781.638;649.1218;RimFactor;13;136;132;134;133;135;175;172;170;171;173;177;176;212;RimFactor;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-2818.005,355.9434;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;210;-3069.253,2742.716;Inherit;False;3052.204;676.084;Dissolve;22;188;185;184;187;207;205;186;190;206;191;203;193;192;194;198;197;196;209;208;189;199;200;Dissolve;1,1,1,1;0;0
Node;AmplifyShaderEditor.TriplanarNode;42;-2653.765,326.4727;Inherit;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;5;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;171;-2333.313,1477.356;Inherit;False;Property;_DepthFade;DepthFade;22;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;123;-2250.359,355.5001;Inherit;False;WaveNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;185;-3011.253,2976.541;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;188;-3019.253,3174.541;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;17;-2313.652,566.4393;Inherit;False;Property;_HitNoiseIntensity;HitNoiseIntensity;5;0;Create;True;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;170;-2032.529,1379.492;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;211;-3608.767,1114;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;166;-3043.056,1800.161;Inherit;False;1976.329;851.8621;FlowLightColor;17;154;153;155;161;147;163;160;146;151;149;164;165;144;162;156;182;183;FlowLightColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1931.486,654.4937;Inherit;False;Property;_HitFadeDistance;HitFadeDistance;7;0;Create;True;0;0;False;0;False;6;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;154;-2993.056,2190.387;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;187;-2774.253,3071.541;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;184;-3012.859,2792.716;Inherit;False;Property;_DissolvePoint;DissolvePoint;23;0;Create;True;0;0;False;0;False;0,0,0;9.54,4.3,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;5;-1962.659,219.8757;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;213;-3380.77,1289.538;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;175;-1767.717,1401.503;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1888.486,804.4941;Inherit;False;Property;_HitFadePower;HitFadePower;6;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1893.352,544.2117;Inherit;False;Property;_HitSpread;HitSpread;2;0;Create;True;0;0;False;0;False;0;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;36;-1941.921,-5.445163;Inherit;True;Property;_HitRampTex;HitRampTex;1;0;Create;True;0;0;False;0;False;None;256d86d8496a4e0f947100121f1fafb2;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-2030.821,478.9484;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;186;-2588.253,2875.541;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;207;-2559.873,3303.8;Inherit;False;Property;_DissolveNoise;DissolveNoise;26;0;Create;True;0;0;False;0;False;1;1.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;205;-2548.437,3169.103;Inherit;False;123;WaveNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;190;-2595.253,3021.541;Inherit;False;Property;_DissolveAmount;DissolveAmount;24;0;Create;True;0;0;False;0;False;0;17.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;173;-1506.224,1599.155;Inherit;False;Property;_DepthFadePower;DepthFadePower;21;0;Create;True;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;-2796.823,1347.326;Inherit;False;Property;_Rimpower;Rimpower;9;0;Create;True;0;0;False;0;False;2;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-2843.823,1267.326;Inherit;False;Property;_RimScale;RimScale;10;0;Create;True;0;0;False;0;False;1;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;133;-2985.823,1208.326;Inherit;False;Property;_RimBias;RimBias;11;0;Create;True;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;35;-1586.767,173.5148;Inherit;False;float hit_result@$$for(int j = 0@j < AffectorAmount@j++)${$$float distance_mask = distance(HitPosition[j].xyz,WorldPos)@$$float hit_range = -clamp((distance_mask - HitSize[j] + HitNoise) / HitSpread,-1,0)@$$float2 ramp_uv = float2(hit_range,0.5)@$$float hit_wave = tex2D(RampTex,ramp_uv).r@ $$float hit_fade = saturate((1.0 - distance_mask / HitFadeDistance) * HitFadePower)@$$hit_result = hit_result + hit_fade * hit_wave@$}$$return saturate(hit_result)@;1;False;6;True;RampTex;SAMPLER2D;;In;;Inherit;False;True;WorldPos;FLOAT3;0,0,0;In;;Inherit;False;True;HitNoise;FLOAT;0;In;;Inherit;False;True;HitSpread;FLOAT;0;In;;Inherit;False;True;HitFadeDistance;FLOAT;0;In;;Inherit;False;True;HitFadePower;FLOAT;0;In;;Inherit;False;HitWaveFunction;True;False;0;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;153;-2732.788,2174.274;Inherit;True;Property;_FlowMap;FlowMap;19;0;Create;True;0;0;False;0;False;-1;None;f4a4b1c04c15a784ca546dc6c403e249;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;172;-1565.295,1434.192;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwitchByFaceNode;212;-3023.642,1116.017;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;177;-1285.309,1459.136;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;155;-2429.727,2189.251;Inherit;False;FLOAT2;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;132;-2456.641,1108.004;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;-2315.895,3238.993;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;191;-2391.685,2943.948;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;161;-2398.638,2291.022;Inherit;False;Constant;_Float1;Float 1;18;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-1215.024,159.1205;Inherit;False;HitWave;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;203;-2155.232,3065.927;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;160;-2220.638,2222.022;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;193;-1837.518,3117.627;Inherit;False;Property;_DissolveSpread;DissolveSpread;25;0;Create;True;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;-2264.962,2360.04;Inherit;False;47;HitWave;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;176;-630.8086,1343.664;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;147;-2338.583,2042.161;Inherit;False;0;146;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;149;-2289.583,2454.16;Inherit;False;Property;_FlowStrength;FlowStrength;18;0;Create;True;0;0;False;0;False;0.2,0.2;-0.5,0.3;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TexturePropertyNode;146;-2264.583,1850.161;Inherit;True;Property;_FlowLight;FlowLight;17;0;Create;True;0;0;False;0;False;None;aeb46886909512e41842722f15bb898b;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;136;-790.9462,1203.078;Inherit;False;RimFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;151;-2289.583,2581.16;Inherit;False;Property;_FlowSpeed;FlowSpeed;20;0;Create;True;0;0;False;0;False;0.2;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;192;-1602.519,3026.627;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;182;-2073.962,2190.04;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;163;-1947.638,2492.022;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;194;-1402.519,3072.627;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;164;-1648.638,2496.022;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.85;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;165;-1853.638,2319.022;Inherit;False;136;RimFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;144;-1891.34,2103.311;Inherit;False;Flow;14;;1;acad10cc8145e1f4eb8042bebe2d9a42;2,51,0,50,0;5;5;SAMPLER2D;;False;2;FLOAT2;0,0;False;18;FLOAT2;0,0;False;17;FLOAT2;1,1;False;24;FLOAT;0.2;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;198;-1276.591,3005.985;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;162;-1485.638,2240.022;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;156;-1309.727,2145.251;Inherit;False;FlowColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;197;-1042.9,3046.134;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;209;-868.6055,3284.653;Inherit;False;Property;_DissolveEdgeIntensity;DissolveEdgeIntensity;27;0;Create;True;0;0;False;0;False;1;0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;196;-850.0385,3025.078;Inherit;True;Property;_DissolveRampTex;DissolveRampTex;28;0;Create;True;0;0;False;0;False;-1;None;bfb5d11eb2154099bda5558461f45026;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;138;-429.7356,482.6036;Inherit;False;136;RimFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;-436.869,631.9621;Inherit;False;156;FlowColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;167;-195.2347,501.6719;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;208;-530.4886,3172.315;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;181;-213.9705,701.1677;Inherit;False;Property;_HitWaveIntensity;HitWaveIntensity;8;0;Create;True;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;189;-229.6677,3048.597;Inherit;False;DissolveEdge;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;180;-5.171153,640.5999;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-156.6806,845.5913;Inherit;False;47;HitWave;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;199;-1079.973,2835.22;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;143.0607,728.2642;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;198.2484,866.0094;Inherit;False;189;DissolveEdge;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-844.9727,2860.22;Inherit;False;DissolveAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;178;427.5248,642.2126;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCGrayscale;169;511.8831,775.9805;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;140;125.3613,266.8087;Inherit;False;Property;_EmissColor;EmissColor;12;0;Create;True;0;0;False;0;False;0,0,0,0;0.9313589,0.759029,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;195;491.8063,987.3209;Inherit;False;200;DissolveAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;141;157.5294,474.3593;Inherit;False;Property;_EmissIntensity;EmissIntensity;13;0;Create;True;0;0;False;0;False;1;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;413.4837,385.7933;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;131;-718.2159,-183.3618;Inherit;False;228;165;Properties;1;130;Properties;1,0,0,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;201;693.2977,860.1175;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;578.1159,473.8169;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-1907.419,-234.9648;Inherit;False;Global;AffectorAmount;AffectorAmount;6;0;Create;False;0;0;True;0;False;20;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GlobalArrayNode;37;-2393.205,-243.1586;Inherit;False;HitPosition;0;20;2;False;False;0;1;True;Object;-1;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;130;-668.2159,-133.3618;Inherit;False;Property;_CullMode;CullMode;0;1;[Enum];Create;True;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;143;841.8118,748.6334;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GlobalArrayNode;39;-2134.987,-244.2226;Inherit;False;HitSize;0;20;0;False;False;0;1;True;Object;-1;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;983.5447,380.6408;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;ForceField;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;True;130;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;46;0;44;0
WireConnection;46;1;45;0
WireConnection;42;0;43;0
WireConnection;42;9;46;0
WireConnection;123;0;42;1
WireConnection;170;0;171;0
WireConnection;187;0;185;0
WireConnection;187;1;188;0
WireConnection;213;0;211;0
WireConnection;175;0;170;0
WireConnection;16;0;123;0
WireConnection;16;1;17;0
WireConnection;186;0;184;0
WireConnection;186;1;187;0
WireConnection;35;0;36;0
WireConnection;35;1;5;0
WireConnection;35;2;16;0
WireConnection;35;3;13;0
WireConnection;35;4;28;0
WireConnection;35;5;30;0
WireConnection;153;1;154;0
WireConnection;172;0;175;0
WireConnection;212;0;211;0
WireConnection;212;1;213;0
WireConnection;177;0;172;0
WireConnection;177;1;173;0
WireConnection;155;0;153;0
WireConnection;132;0;212;0
WireConnection;132;1;133;0
WireConnection;132;2;134;0
WireConnection;132;3;135;0
WireConnection;206;0;205;0
WireConnection;206;1;207;0
WireConnection;191;0;186;0
WireConnection;191;1;190;0
WireConnection;47;0;35;0
WireConnection;203;0;191;0
WireConnection;203;1;206;0
WireConnection;160;0;155;0
WireConnection;160;1;161;0
WireConnection;176;0;132;0
WireConnection;176;1;177;0
WireConnection;136;0;176;0
WireConnection;192;0;203;0
WireConnection;192;1;193;0
WireConnection;182;0;160;0
WireConnection;182;1;183;0
WireConnection;194;0;192;0
WireConnection;164;0;163;2
WireConnection;144;5;146;0
WireConnection;144;2;147;0
WireConnection;144;18;182;0
WireConnection;144;17;149;0
WireConnection;144;24;151;0
WireConnection;198;0;194;0
WireConnection;162;0;144;0
WireConnection;162;1;165;0
WireConnection;162;2;164;0
WireConnection;156;0;162;0
WireConnection;197;0;198;0
WireConnection;196;1;197;0
WireConnection;167;0;138;0
WireConnection;167;1;157;0
WireConnection;208;0;196;1
WireConnection;208;1;209;0
WireConnection;189;0;208;0
WireConnection;180;0;167;0
WireConnection;180;1;181;0
WireConnection;199;0;198;0
WireConnection;179;0;180;0
WireConnection;179;1;48;0
WireConnection;200;0;199;0
WireConnection;178;0;167;0
WireConnection;178;1;179;0
WireConnection;178;2;202;0
WireConnection;169;0;178;0
WireConnection;142;0;140;0
WireConnection;142;1;141;0
WireConnection;201;0;169;0
WireConnection;201;1;195;0
WireConnection;139;0;142;0
WireConnection;139;1;178;0
WireConnection;143;0;201;0
WireConnection;0;2;139;0
WireConnection;0;9;143;0
ASEEND*/
//CHKSM=3ECFED1071BE32327326F039F1CB2B28D9389173