// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Scene_Tree"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_BaseColor_Branch("BaseColor_Branch", 2D) = "white" {}
		_BaseColor_Beaf("BaseColor_Beaf", 2D) = "white" {}
		_Normal_Branch("Normal_Branch", 2D) = "bump" {}
		_Normal_Beaf("Normal_Beaf", 2D) = "bump" {}
		_SSSColor("SSSColor", Color) = (1,1,1,1)
		_SSSIntensity("SSSIntensity", Float) = 1
		_SSSDistort("SSSDistort", Range( 0 , 1)) = 0
		_GlobalWindSpeed("GlobalWindSpeed", Float) = 1
		_GlobalWindDirection("GlobalWindDirection", Vector) = (1,0,0,0)
		_GlobalWindIntensity("GlobalWindIntensity", Float) = 1
		_SmallWindSpeed("SmallWindSpeed", Float) = 1
		_SmallWindDirection("SmallWindDirection", Vector) = (0,0,1,0)
		_SmallWindIntensity("SmallWindIntensity", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "DisableBatching" = "True" }
		Cull Off
		AlphaToMask On
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
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
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
			float3 worldNormal;
			INTERNAL_DATA
			half ASEVFace : VFACE;
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

		uniform float _GlobalWindSpeed;
		uniform float _GlobalWindIntensity;
		uniform float3 _GlobalWindDirection;
		uniform float3 _SmallWindDirection;
		uniform float _SmallWindSpeed;
		uniform float _SmallWindIntensity;
		uniform sampler2D _BaseColor_Beaf;
		uniform float4 _BaseColor_Beaf_ST;
		uniform sampler2D _BaseColor_Branch;
		uniform float4 _BaseColor_Branch_ST;
		uniform sampler2D _Normal_Beaf;
		uniform float4 _Normal_Beaf_ST;
		uniform sampler2D _Normal_Branch;
		uniform float4 _Normal_Branch_ST;
		uniform float _SSSDistort;
		uniform float4 _SSSColor;
		uniform float _SSSIntensity;
		uniform float _Cutoff = 0.5;


		float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
		{
			original -= center;
			float C = cos( angle );
			float S = sin( angle );
			float t = 1 - C;
			float m00 = t * u.x * u.x + C;
			float m01 = t * u.x * u.y - S * u.z;
			float m02 = t * u.x * u.z + S * u.y;
			float m10 = t * u.x * u.y + S * u.z;
			float m11 = t * u.y * u.y + C;
			float m12 = t * u.y * u.z - S * u.x;
			float m20 = t * u.x * u.z - S * u.y;
			float m21 = t * u.y * u.z + S * u.x;
			float m22 = t * u.z * u.z + C;
			float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
			return mul( finalMatrix, original ) + center;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float temp_output_56_0 = ( ( _GlobalWindSpeed * _Time.y ) * UNITY_PI );
			float temp_output_67_0 = ( _GlobalWindIntensity * 0.1 );
			float3 temp_output_7_0_g1 = _SmallWindDirection;
			float3 RotateAxis34_g1 = cross( temp_output_7_0_g1 , float3(0,1,0) );
			float3 wind_direction31_g1 = temp_output_7_0_g1;
			float3 wind_speed40_g1 = ( ( _Time.y * _SmallWindSpeed ) * float3(0.5,-0.5,-0.5) );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 temp_cast_0 = (1.0).xxx;
			float3 temp_output_22_0_g1 = abs( ( ( frac( ( ( ( wind_direction31_g1 * wind_speed40_g1 ) + ( ase_worldPos / 10.0 ) ) + 0.5 ) ) * 2.0 ) - temp_cast_0 ) );
			float3 temp_cast_1 = (3.0).xxx;
			float dotResult30_g1 = dot( ( ( temp_output_22_0_g1 * temp_output_22_0_g1 ) * ( temp_cast_1 - ( temp_output_22_0_g1 * 2.0 ) ) ) , wind_direction31_g1 );
			float BigTriangleWave42_g1 = dotResult30_g1;
			float3 temp_cast_2 = (1.0).xxx;
			float3 temp_output_59_0_g1 = abs( ( ( frac( ( ( wind_speed40_g1 + ( ase_worldPos / 2.0 ) ) + 0.5 ) ) * 2.0 ) - temp_cast_2 ) );
			float3 temp_cast_3 = (3.0).xxx;
			float SmallTriangleWave52_g1 = distance( ( ( temp_output_59_0_g1 * temp_output_59_0_g1 ) * ( temp_cast_3 - ( temp_output_59_0_g1 * 2.0 ) ) ) , float3(0,0,0) );
			float3 rotatedValue72_g1 = RotateAroundAxis( ( ase_worldPos - float3(0,0.1,0) ), ase_worldPos, normalize( RotateAxis34_g1 ), ( ( BigTriangleWave42_g1 + SmallTriangleWave52_g1 ) * ( 2.0 * UNITY_PI ) ) );
			float3 worldToObj81_g1 = mul( unity_WorldToObject, float4( rotatedValue72_g1, 1 ) ).xyz;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 WindVertexOffset60 = ( ( v.color.r * ( sin( temp_output_56_0 ) * temp_output_67_0 ) * _GlobalWindDirection ) + ( _GlobalWindDirection * ( cos( temp_output_56_0 ) * temp_output_67_0 ) * v.color.g ) + ( v.color.g * ( worldToObj81_g1 - ase_vertex3Pos ) * _SmallWindIntensity ) );
			v.vertex.xyz += WindVertexOffset60;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_BaseColor_Beaf = i.uv_texcoord * _BaseColor_Beaf_ST.xy + _BaseColor_Beaf_ST.zw;
			float4 tex2DNode4 = tex2D( _BaseColor_Beaf, uv_BaseColor_Beaf );
			float lerpResult19 = lerp( tex2DNode4.a , 1.0 , i.vertexColor.a);
			float AlphaMask20 = lerpResult19;
			SurfaceOutputStandard s2 = (SurfaceOutputStandard ) 0;
			float2 uv_BaseColor_Branch = i.uv_texcoord * _BaseColor_Branch_ST.xy + _BaseColor_Branch_ST.zw;
			float4 lerpResult5 = lerp( tex2DNode4 , tex2D( _BaseColor_Branch, uv_BaseColor_Branch ) , i.vertexColor.a);
			float4 BaseColor7 = ( lerpResult5 * 1.4 );
			s2.Albedo = BaseColor7.rgb;
			float2 uv_Normal_Beaf = i.uv_texcoord * _Normal_Beaf_ST.xy + _Normal_Beaf_ST.zw;
			float3 tex2DNode11 = UnpackNormal( tex2D( _Normal_Beaf, uv_Normal_Beaf ) );
			float3 appendResult25 = (float3(tex2DNode11.r , tex2DNode11.g , -tex2DNode11.b));
			float3 switchResult24 = (((i.ASEVFace>0)?(tex2DNode11):(appendResult25)));
			float2 uv_Normal_Branch = i.uv_texcoord * _Normal_Branch_ST.xy + _Normal_Branch_ST.zw;
			float3 lerpResult8 = lerp( switchResult24 , UnpackNormal( tex2D( _Normal_Branch, uv_Normal_Branch ) ) , i.vertexColor.a);
			float3 Normal10 = lerpResult8;
			s2.Normal = WorldNormalVector( i , Normal10 );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult28 = normalize( ( ase_worldlightDir + ( (WorldNormalVector( i , Normal10 )) * _SSSDistort ) ) );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult30 = dot( -normalizeResult28 , ase_worldViewDir );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 SSSColor38 = ( (( ( max( dotResult30 , 0.0 ) * ( i.vertexColor.b * ( 1.0 - i.vertexColor.a ) ) ) * _SSSColor * _SSSIntensity * BaseColor7 * float4( ase_lightColor.rgb , 0.0 ) )).rgb * (ase_lightAtten*0.5 + 0.5) );
			s2.Emission = SSSColor38;
			s2.Metallic = 0.0;
			s2.Smoothness = ( 1.0 - 1.0 );
			s2.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi2 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g2 = UnityGlossyEnvironmentSetup( s2.Smoothness, data.worldViewDir, s2.Normal, float3(0,0,0));
			gi2 = UnityGlobalIllumination( data, s2.Occlusion, s2.Normal, g2 );
			#endif

			float3 surfResult2 = LightingStandard ( s2, viewDir, gi2 ).rgb;
			surfResult2 += s2.Emission;

			#ifdef UNITY_PASS_FORWARDADD//2
			surfResult2 -= s2.Emission;
			#endif//2
			c.rgb = surfResult2;
			c.a = 1;
			clip( AlphaMask20 - _Cutoff );
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
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			AlphaToMask Off
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
				vertexDataFunc( v, customInputData );
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
7;29;1522;788;237.1658;-1740.935;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;13;-1755.849,720.1098;Inherit;False;1286.092;855.8914;Normal;8;10;8;11;12;9;25;26;24;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;11;-1725.955,781.8378;Inherit;True;Property;_Normal_Beaf;Normal_Beaf;4;0;Create;True;0;0;False;0;False;-1;None;883ca5cff2de98b4cb817aa096c9e98b;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;26;-1403.209,926.0931;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;25;-1250.745,899.2863;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;9;-1660.55,1299.407;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwitchByFaceNode;24;-1086.553,822.2166;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;12;-1702.524,994.1872;Inherit;True;Property;_Normal_Branch;Normal_Branch;3;0;Create;True;0;0;False;0;False;-1;None;43520584e864461408803208856e7bcd;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;8;-937.8632,1045.914;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-722.4776,1071.483;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;40;-2022.529,1633.538;Inherit;False;2865.538;963.6248;SSSColor;23;49;47;38;39;33;35;34;37;32;36;30;31;29;28;45;43;27;42;44;41;51;80;82;SSSColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-1940.541,2038.667;Inherit;False;10;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1860.456,2311.244;Inherit;False;Property;_SSSDistort;SSSDistort;7;0;Create;True;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;42;-1745.434,2042.854;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;27;-1867.028,1738.194;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-1493.466,2199.753;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;6;-1776.317,-186.8136;Inherit;False;992.0184;810.1243;BaseColor;8;1;5;4;3;7;19;20;23;BaseColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-1468.031,1801.062;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;4;-1726.317,-136.8136;Inherit;True;Property;_BaseColor_Beaf;BaseColor_Beaf;2;0;Create;True;0;0;False;0;False;-1;None;31ffef35b562b2b41b6e20ed299038b7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-1739.389,82.34468;Inherit;True;Property;_BaseColor_Branch;BaseColor_Branch;1;0;Create;True;0;0;False;0;False;-1;None;6208389e206b0ba45a8fb7c13d8e8822;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;1;-1681.018,392.4837;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;28;-1301.337,1752.672;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;61;-1792.492,2688.18;Inherit;False;2402.028;1301.116;Wind;24;60;73;58;71;72;70;59;63;65;69;67;55;68;56;66;57;53;52;54;74;75;76;77;78;Wind;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;47;-998.3925,2098.394;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;5;-1352.057,95.42917;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1363.478,226.3946;Inherit;False;Constant;_Float1;Float 1;5;0;Create;True;0;0;False;0;False;1.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;29;-1135.137,1738.311;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;31;-1083.874,1921.457;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;54;-1763.207,2855.387;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1748.077,2753.705;Inherit;False;Property;_GlobalWindSpeed;GlobalWindSpeed;8;0;Create;True;0;0;False;0;False;1;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;30;-922.1372,1771.311;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-1149.478,168.3946;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;49;-777.8141,2271.708;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-1475.207,2800.387;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;57;-1473.015,2923.532;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;7;-990.356,128.7003;Inherit;False;BaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-624.7588,2141.161;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;32;-751.088,1803.525;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-1697.798,3117.189;Inherit;False;Property;_GlobalWindIntensity;GlobalWindIntensity;10;0;Create;True;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-1656.38,3295.438;Inherit;False;Constant;_Float2;Float 2;11;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-1283.651,2832.726;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-455.9479,1931.835;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-174.798,2169.571;Inherit;False;Property;_SSSIntensity;SSSIntensity;6;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;34;-179.5984,1990.371;Inherit;False;Property;_SSSColor;SSSColor;5;0;Create;True;0;0;False;0;False;1,1,1,1;0.9843137,1,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;37;-176.3981,2401.572;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;36;-185.9977,2270.371;Inherit;False;7;BaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SinOpNode;55;-1124.238,2821.832;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-1459.38,3200.438;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;80;98.8342,2136.935;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;76;-926.0325,3660.878;Inherit;False;Property;_SmallWindDirection;SmallWindDirection;12;0;Create;True;0;0;False;0;False;0,0,1;0,0,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CosOpNode;69;-1085.739,3127.92;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;138.8015,1838.371;Inherit;False;5;5;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;4;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-907.0325,3565.878;Inherit;False;Property;_SmallWindSpeed;SmallWindSpeed;11;0;Create;True;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-829.5469,2859.38;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;74;-628.008,3603.244;Inherit;False;SimpleGrassWind;-1;;1;22350d6ace565734d907ae88fac2a4fe;0;2;1;FLOAT;1;False;7;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;82;328.8342,2178.935;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;63;-580.3634,2755.824;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-950.941,3204.37;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-535.0325,3747.878;Inherit;False;Property;_SmallWindIntensity;SmallWindIntensity;13;0;Create;True;0;0;False;0;False;1;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;39;319.602,1863.971;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;59;-669.88,3067.135;Inherit;False;Property;_GlobalWindDirection;GlobalWindDirection;9;0;Create;True;0;0;False;0;False;1,0,0;1,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.VertexColorNode;72;-615.8786,3286.468;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-330.0111,2939.449;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;531.8342,2024.935;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-352.9792,3205.358;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-246.0325,3643.878;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;17;109.4638,545.2098;Inherit;False;Constant;_Roughness;Roughness;4;0;Create;True;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;619.002,1893.171;Inherit;False;SSSColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;73;-104.037,3074.596;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;19;-1293.503,309.102;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-1078.704,333.6976;Inherit;False;AlphaMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;214.4638,461.2098;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;162.5775,3048.97;Inherit;False;WindVertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;211.0657,334.9001;Inherit;False;38;SSSColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;18;350.4638,572.2098;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;15;268.4639,243.2098;Inherit;False;10;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;14;276.4639,177.2098;Inherit;False;7;BaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomStandardSurface;2;515.2559,270.1887;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;565.28,144.8304;Inherit;False;20;AlphaMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;62;517.7298,484.5763;Inherit;False;60;WindVertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;835.6888,84.37244;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Scene_Tree;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;True;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;True;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;26;0;11;3
WireConnection;25;0;11;1
WireConnection;25;1;11;2
WireConnection;25;2;26;0
WireConnection;24;0;11;0
WireConnection;24;1;25;0
WireConnection;8;0;24;0
WireConnection;8;1;12;0
WireConnection;8;2;9;4
WireConnection;10;0;8;0
WireConnection;42;0;41;0
WireConnection;43;0;42;0
WireConnection;43;1;44;0
WireConnection;45;0;27;0
WireConnection;45;1;43;0
WireConnection;28;0;45;0
WireConnection;5;0;4;0
WireConnection;5;1;3;0
WireConnection;5;2;1;4
WireConnection;29;0;28;0
WireConnection;30;0;29;0
WireConnection;30;1;31;0
WireConnection;22;0;5;0
WireConnection;22;1;23;0
WireConnection;49;0;47;4
WireConnection;53;0;52;0
WireConnection;53;1;54;0
WireConnection;7;0;22;0
WireConnection;51;0;47;3
WireConnection;51;1;49;0
WireConnection;32;0;30;0
WireConnection;56;0;53;0
WireConnection;56;1;57;0
WireConnection;50;0;32;0
WireConnection;50;1;51;0
WireConnection;55;0;56;0
WireConnection;67;0;66;0
WireConnection;67;1;68;0
WireConnection;69;0;56;0
WireConnection;33;0;50;0
WireConnection;33;1;34;0
WireConnection;33;2;35;0
WireConnection;33;3;36;0
WireConnection;33;4;37;1
WireConnection;65;0;55;0
WireConnection;65;1;67;0
WireConnection;74;1;75;0
WireConnection;74;7;76;0
WireConnection;82;0;80;0
WireConnection;70;0;69;0
WireConnection;70;1;67;0
WireConnection;39;0;33;0
WireConnection;58;0;63;1
WireConnection;58;1;65;0
WireConnection;58;2;59;0
WireConnection;81;0;39;0
WireConnection;81;1;82;0
WireConnection;71;0;59;0
WireConnection;71;1;70;0
WireConnection;71;2;72;2
WireConnection;77;0;72;2
WireConnection;77;1;74;0
WireConnection;77;2;78;0
WireConnection;38;0;81;0
WireConnection;73;0;58;0
WireConnection;73;1;71;0
WireConnection;73;2;77;0
WireConnection;19;0;4;4
WireConnection;19;2;1;4
WireConnection;20;0;19;0
WireConnection;60;0;73;0
WireConnection;18;0;17;0
WireConnection;2;0;14;0
WireConnection;2;1;15;0
WireConnection;2;2;46;0
WireConnection;2;3;16;0
WireConnection;2;4;18;0
WireConnection;0;10;21;0
WireConnection;0;13;2;0
WireConnection;0;11;62;0
ASEEND*/
//CHKSM=68FA2E601E1A893F3D26D207D902C4573EE203A6