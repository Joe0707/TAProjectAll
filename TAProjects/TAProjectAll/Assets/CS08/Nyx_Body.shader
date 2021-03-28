// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Nyx_Body"
{
	Properties
	{
		_NormalMap("NormalMap", 2D) = "bump" {}
		_RimPower("RimPower", Float) = 5
		_RimScale("RimScale", Float) = 1
		_RimBias("RimBias", Float) = 0
		_RimColor("RimColor", Color) = (1,0.759,0.494,0)
		_FlowTillingSpeed("FlowTillingSpeed", Vector) = (1,1,0,0)
		_EmissMap("EmissMap", 2D) = "white" {}
		_FlowLightColor("FlowLightColor", Color) = (1,0.706,0.475,0)
		_FlowRimScale("FlowRimScale", Float) = 2
		_FlowRimBias("FlowRimBias", Float) = 0
		_NebulaTilling("NebulaTilling", Vector) = (1,1,0,0)
		_NebulaTex("NebulaTex", 2D) = "white" {}
		_NebulaDistort("NebulaDistort", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
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
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _RimPower;
		uniform float _RimScale;
		uniform float _RimBias;
		uniform float4 _RimColor;
		uniform float4 _FlowLightColor;
		uniform sampler2D _EmissMap;
		uniform float4 _FlowTillingSpeed;
		uniform float _FlowRimScale;
		uniform float _FlowRimBias;
		uniform sampler2D _NebulaTex;
		uniform float _NebulaDistort;
		uniform float2 _NebulaTilling;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 normalizeResult57 = normalize( (WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) ) )) );
			float3 NormalWorld7 = normalizeResult57;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult3 = dot( NormalWorld7 , ase_worldViewDir );
			float NdotV5 = dotResult3;
			float clampResult12 = clamp( NdotV5 , 0.0 , 1.0 );
			float4 RimColor22 = ( ( ( pow( ( 1.0 - clampResult12 ) , _RimPower ) * _RimScale ) + _RimBias ) * _RimColor );
			float3 objToWorld27 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 panner33 = ( 1.0 * _Time.y * (_FlowTillingSpeed).zw + ( ( (NdotV5*0.5 + 0.5) + (( ase_worldPos - objToWorld27 )).xy ) * (_FlowTillingSpeed).xy ));
			float FlowLight37 = tex2D( _EmissMap, panner33 ).r;
			float4 FlowLightColor46 = ( _FlowLightColor * ( FlowLight37 * ( ( ( 1.0 - NdotV5 ) * _FlowRimScale ) + _FlowRimBias ) ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToView59 = mul( UNITY_MATRIX_MV, float4( ase_vertex3Pos, 1 ) ).xyz;
			float3 objToView61 = mul( UNITY_MATRIX_MV, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float3 worldToViewDir69 = normalize( mul( UNITY_MATRIX_V, float4( NormalWorld7, 0 ) ).xyz );
			float4 NebulaColor66 = tex2D( _NebulaTex, ( ( (( objToView59 - objToView61 )).xy + ( (worldToViewDir69).xy * _NebulaDistort ) ) * _NebulaTilling ) );
			float4 saferPower79 = max( NebulaColor66 , 0.0001 );
			float saferPower81 = max( FlowLight37 , 0.0001 );
			o.Emission = ( ( RimColor22 + FlowLightColor46 + ( NebulaColor66 * FlowLight37 ) ) + ( pow( saferPower79 , 5.0 ) * pow( saferPower81 , 3.0 ) * 10.0 ) ).rgb;
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
				Input customInputData;
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
7;29;1522;788;1653.001;161.7957;2.070772;True;False
Node;AmplifyShaderEditor.CommentaryNode;9;-2098.171,-335.1684;Inherit;False;894.485;281.0677;NormalMap;4;1;6;7;57;NormalMap;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;6;-2048.171,-285.1684;Inherit;True;Property;_NormalMap;NormalMap;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;1;-1753.344,-238.1007;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;57;-1545.153,-221.7265;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;7;-1404.685,-210.3285;Inherit;False;NormalWorld;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;10;-2096.344,26.67157;Inherit;False;692;354.2278;NdotV;4;8;3;2;5;NdotV;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;2;-2046.344,196.8994;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;8;-2042.686,76.67157;Inherit;False;7;NormalWorld;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;3;-1816.344,133.8994;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;38;-2091.538,1230.621;Inherit;False;1935.374;928.6323;FlowLight;13;32;28;26;37;36;33;29;34;31;25;27;40;42;FlowLight;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;25;-2032.869,1730.605;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;27;-2044.153,1926.77;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;5;-1647.344,143.8994;Inherit;False;NdotV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;26;-1773.983,1751.801;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-1918.192,1501.319;Inherit;False;5;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;74;-2097.696,3235.868;Inherit;False;2447.034;695.2922;NebulaColor;15;58;68;69;61;59;72;70;60;62;71;63;73;64;65;66;NebulaColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;31;-1702.536,1900.225;Inherit;False;Property;_FlowTillingSpeed;FlowTillingSpeed;5;0;Create;True;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;28;-1543.047,1763.569;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;42;-1626.648,1510.585;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;-2011.545,3665.794;Inherit;False;7;NormalWorld;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;58;-2047.696,3285.868;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;23;-2118.603,534.2363;Inherit;False;1834.152;595.5967;RimColor;12;13;12;15;18;11;14;17;16;19;21;20;22;RimColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-1334.888,1611.303;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;32;-1451,1877.432;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TransformPositionNode;59;-1809.326,3289.018;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;61;-1812.326,3470.018;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;69;-1745.848,3667.254;Inherit;False;World;View;True;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;55;-2082.622,2339.573;Inherit;False;1690.956;677.5916;FlowLightColor;11;48;49;51;50;53;43;52;45;44;54;46;FlowLightColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;11;-2068.603,584.2364;Inherit;False;5;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1238.326,1791.117;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;34;-1427.612,1997.161;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;70;-1459.712,3709.59;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;60;-1518.326,3366.018;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-1481.611,3816.161;Inherit;False;Property;_NebulaDistort;NebulaDistort;12;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;33;-1048.789,1804.368;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;12;-1859.069,591.8282;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-2032.622,2674.041;Inherit;False;5;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;49;-1804.5,2712.946;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;62;-1333.326,3405.018;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-1253.871,3753.386;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-1802.731,2831.427;Inherit;False;Property;_FlowRimScale;FlowRimScale;8;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;36;-808.6412,1779;Inherit;True;Property;_EmissMap;EmissMap;6;0;Create;True;0;0;False;0;False;-1;c98a33b1056d6a54284eafdaa8181eea;c98a33b1056d6a54284eafdaa8181eea;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;-1616.129,831.7309;Inherit;False;Property;_RimPower;RimPower;1;0;Create;True;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;13;-1643.459,596.3834;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1348.895,813.5104;Inherit;False;Property;_RimScale;RimScale;2;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;73;-1055.328,3452.653;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;63;-857.3554,3541.893;Inherit;False;Property;_NebulaTilling;NebulaTilling;10;0;Create;True;0;0;False;0;False;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-1549.852,2765.998;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-389.3237,1633.234;Inherit;False;FlowLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;14;-1348.895,687.4855;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-1541.01,2902.164;Inherit;False;Property;_FlowRimBias;FlowRimBias;9;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-1149.988,745.1837;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-598.6338,3446.698;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-1327.369,2633.103;Inherit;False;37;FlowLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1156.058,859.0616;Inherit;False;Property;_RimBias;RimBias;3;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-1286.359,2811.976;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;21;-996.6287,922.8331;Inherit;False;Property;_RimColor;RimColor;4;0;Create;True;0;0;False;0;False;1,0.759,0.494,0;1,0.759,0.494,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;65;-392.6338,3381.698;Inherit;True;Property;_NebulaTex;NebulaTex;11;0;Create;True;0;0;False;0;False;-1;c98a33b1056d6a54284eafdaa8181eea;c98a33b1056d6a54284eafdaa8181eea;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;44;-1377.579,2389.573;Inherit;False;Property;_FlowLightColor;FlowLightColor;7;0;Create;True;0;0;False;0;False;1,0.706,0.475,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-1088.965,2640.948;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-966.2621,772.5143;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;84;-133.1734,552.4399;Inherit;False;758.6199;537.0081;Blingking;6;78;77;79;82;81;80;Blingking;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;106.3378,3426.179;Inherit;False;NebulaColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-912.9271,2493.518;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-733.9505,813.5104;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-638.6665,2490.728;Inherit;False;FlowLightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-163.5844,392.2002;Inherit;False;37;FlowLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;67;-161.8743,289.949;Inherit;False;66;NebulaColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-527.4519,860.5799;Inherit;False;RimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;77;-52.41207,602.4399;Inherit;False;66;NebulaColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;-83.17336,863.1517;Inherit;False;37;FlowLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;117.2324,20.80829;Inherit;False;22;RimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;76.41565,341.2002;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;103.9468,179.6483;Inherit;False;46;FlowLightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;79;246.4872,611.3099;Inherit;False;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;5;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;81;192.3459,841.0773;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;198.9487,974.4481;Inherit;False;Constant;_Float0;Float 0;13;0;Create;True;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;380.6329,196.3352;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;456.4466,732.7961;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;83;589.4289,317.9487;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;841.5756,46.14185;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Nyx_Body;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;1;0;6;0
WireConnection;57;0;1;0
WireConnection;7;0;57;0
WireConnection;3;0;8;0
WireConnection;3;1;2;0
WireConnection;5;0;3;0
WireConnection;26;0;25;0
WireConnection;26;1;27;0
WireConnection;28;0;26;0
WireConnection;42;0;40;0
WireConnection;41;0;42;0
WireConnection;41;1;28;0
WireConnection;32;0;31;0
WireConnection;59;0;58;0
WireConnection;69;0;68;0
WireConnection;29;0;41;0
WireConnection;29;1;32;0
WireConnection;34;0;31;0
WireConnection;70;0;69;0
WireConnection;60;0;59;0
WireConnection;60;1;61;0
WireConnection;33;0;29;0
WireConnection;33;2;34;0
WireConnection;12;0;11;0
WireConnection;49;0;48;0
WireConnection;62;0;60;0
WireConnection;71;0;70;0
WireConnection;71;1;72;0
WireConnection;36;1;33;0
WireConnection;13;0;12;0
WireConnection;73;0;62;0
WireConnection;73;1;71;0
WireConnection;50;0;49;0
WireConnection;50;1;51;0
WireConnection;37;0;36;1
WireConnection;14;0;13;0
WireConnection;14;1;15;0
WireConnection;17;0;14;0
WireConnection;17;1;16;0
WireConnection;64;0;73;0
WireConnection;64;1;63;0
WireConnection;52;0;50;0
WireConnection;52;1;53;0
WireConnection;65;1;64;0
WireConnection;45;0;43;0
WireConnection;45;1;52;0
WireConnection;18;0;17;0
WireConnection;18;1;19;0
WireConnection;66;0;65;0
WireConnection;54;0;44;0
WireConnection;54;1;45;0
WireConnection;20;0;18;0
WireConnection;20;1;21;0
WireConnection;46;0;54;0
WireConnection;22;0;20;0
WireConnection;76;0;67;0
WireConnection;76;1;75;0
WireConnection;79;0;77;0
WireConnection;81;0;78;0
WireConnection;56;0;24;0
WireConnection;56;1;47;0
WireConnection;56;2;76;0
WireConnection;80;0;79;0
WireConnection;80;1;81;0
WireConnection;80;2;82;0
WireConnection;83;0;56;0
WireConnection;83;1;80;0
WireConnection;0;2;83;0
ASEEND*/
//CHKSM=F37037028CF216DDB32CE22843FB69E189053099