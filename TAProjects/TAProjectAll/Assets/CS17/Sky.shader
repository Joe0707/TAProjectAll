// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Sky"
{
	Properties
	{
		_SkyHDR("SkyHDR", 2D) = "white" {}
		_FogColor1("FogColor", Color) = (0,0.3793104,1,0)
		_FogHeightStart1("Fog Height Start", Range( -1 , 1)) = 0
		_FogHeightEnd1("Fog Height End", Range( -1 , 1)) = 0.2
		_SunFogRange1("Sun Fog Range", Float) = 10
		_SunFogIntensity1("Sun Fog Intensity", Float) = 1
		_SunFogColor1("Sun Fog Color", Color) = (1,0.5172414,0,0)
		_FogIntensity1("FogIntensity", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Background+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 viewDir;
			float3 worldPos;
		};

		uniform sampler2D _SkyHDR;
		uniform float4 _SkyHDR_ST;
		uniform float4 _FogColor1;
		uniform float4 _SunFogColor1;
		uniform float _SunFogRange1;
		uniform float _SunFogIntensity1;
		uniform float _FogHeightEnd1;
		uniform float _FogHeightStart1;
		uniform float _FogIntensity1;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_SkyHDR = i.uv_texcoord * _SkyHDR_ST.xy + _SkyHDR_ST.zw;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult15 = dot( -i.viewDir , ase_worldlightDir );
			float clampResult30 = clamp( pow( (dotResult15*0.5 + 0.5) , _SunFogRange1 ) , 0.0 , 1.0 );
			float SunFog36 = ( clampResult30 * _SunFogIntensity1 );
			float4 lerpResult42 = lerp( _FogColor1 , _SunFogColor1 , SunFog36);
			float temp_output_11_0_g2 = _FogHeightEnd1;
			float3 objToWorld49 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float3 normalizeResult50 = normalize( ( ase_worldPos - objToWorld49 ) );
			float clampResult9_g2 = clamp( ( ( temp_output_11_0_g2 - (normalizeResult50).y ) / ( temp_output_11_0_g2 - _FogHeightStart1 ) ) , 0.0 , 1.0 );
			float FogHorizon27 = ( 1.0 - ( 1.0 - clampResult9_g2 ) );
			float clampResult41 = clamp( ( FogHorizon27 * _FogIntensity1 ) , 0.0 , 1.0 );
			float4 lerpResult43 = lerp( tex2D( _SkyHDR, uv_SkyHDR ) , lerpResult42 , clampResult41);
			o.Emission = lerpResult43.rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

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
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
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
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
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
7;29;1522;788;2056.552;1642.05;2.075023;True;False
Node;AmplifyShaderEditor.CommentaryNode;7;-3751.374,-216.0332;Inherit;False;1699.763;568.6851;FogHorizon;10;27;24;17;13;51;12;50;48;47;49;FogHorizon;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;5;-3272.544,533.9487;Inherit;False;1845.017;671.8921;Sun Fog;11;36;33;30;29;25;21;20;15;10;9;6;Sun Fog;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;47;-3636.178,-162.2088;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;49;-3659.533,-2.742338;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;6;-3222.544,583.9498;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;10;-3082.522,827.6259;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;9;-3033.462,674.8907;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;48;-3387.355,-167.4317;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;50;-3225.355,-134.4317;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;15;-2757.522,708.6259;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-2596.522,900.6259;Inherit;False;Property;_SunFogRange1;Sun Fog Range;5;0;Create;True;0;0;False;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-3143.882,69.38477;Inherit;False;Property;_FogHeightStart1;Fog Height Start;3;0;Create;True;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;21;-2572.522,743.6259;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-3112.838,238.2208;Inherit;False;Property;_FogHeightEnd1;Fog Height End;4;0;Create;True;0;0;False;0;False;0.2;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;51;-3055.355,-104.4317;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;25;-2347.522,783.6259;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;17;-2872.792,-83.11218;Inherit;False;FogLinear;-1;;2;8b9eb64b63c5f9848bc41179a8457d0e;0;3;13;FLOAT;500;False;12;FLOAT;0;False;11;FLOAT;700;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-2254.224,964.0619;Inherit;False;Property;_SunFogIntensity1;Sun Fog Intensity;6;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;24;-2608.092,-8.932251;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;30;-2155.522,793.6259;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;28;-1532.508,-920.047;Inherit;False;854.0399;785.885;FogCombine;9;43;42;41;40;39;38;37;35;32;FogCombine;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-1965.224,866.0619;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-2294.61,-47.07324;Inherit;False;FogHorizon;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-1726.069,903.9379;Inherit;False;SunFog;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-1454.88,-303.4583;Inherit;False;27;FogHorizon;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-1402.522,-221.5962;Inherit;False;Property;_FogIntensity1;FogIntensity;8;0;Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;-1253.443,-602.9384;Inherit;False;36;SunFog;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;39;-1474.304,-870.047;Inherit;False;Property;_FogColor1;FogColor;2;0;Create;True;0;0;False;0;False;0,0.3793104,1,0;0,0.3793104,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-1070.241,-331.0532;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;38;-1482.508,-633.5034;Inherit;False;Property;_SunFogColor1;Sun Fog Color;7;0;Create;True;0;0;False;0;False;1,0.5172414,0,0;0.7971601,0.6323529,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-1600.411,-1061.469;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;41;-861.7849,-307.8333;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1208.411,-1061.469;Inherit;True;Property;_SkyHDR;SkyHDR;1;0;Create;True;0;0;False;0;False;-1;None;99de44b5cf7c75b4da4fcec6feae3c01;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;42;-1085.938,-770.4432;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;43;-862.468,-795.5128;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;4;441.6863,-860.5266;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Sky;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;Background;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;9;0;6;0
WireConnection;48;0;47;0
WireConnection;48;1;49;0
WireConnection;50;0;48;0
WireConnection;15;0;9;0
WireConnection;15;1;10;0
WireConnection;21;0;15;0
WireConnection;51;0;50;0
WireConnection;25;0;21;0
WireConnection;25;1;20;0
WireConnection;17;13;51;0
WireConnection;17;12;13;0
WireConnection;17;11;12;0
WireConnection;24;0;17;0
WireConnection;30;0;25;0
WireConnection;33;0;30;0
WireConnection;33;1;29;0
WireConnection;27;0;24;0
WireConnection;36;0;33;0
WireConnection;40;0;32;0
WireConnection;40;1;35;0
WireConnection;41;0;40;0
WireConnection;1;1;2;0
WireConnection;42;0;39;0
WireConnection;42;1;38;0
WireConnection;42;2;37;0
WireConnection;43;0;1;0
WireConnection;43;1;42;0
WireConnection;43;2;41;0
WireConnection;4;2;43;0
ASEEND*/
//CHKSM=57372A4A024B157E31A9EC71A55E4E8608835722