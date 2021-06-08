// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Landscape"
{
	Properties
	{
		_Layer1_BaseColor("Layer1_BaseColor", 2D) = "white" {}
		_Layer1_HRA("Layer1_HRA", 2D) = "white" {}
		_Layer1_Normal("Layer1_Normal", 2D) = "bump" {}
		_Layer1_Tilling("Layer1_Tilling", Float) = 1
		_Layer1_HeightContrast("Layer1_HeightContrast", Range( 0 , 1)) = 0
		_Layer2_BaseColor("Layer2_BaseColor", 2D) = "white" {}
		_Layer2_HRA("Layer2_HRA", 2D) = "white" {}
		_Layer2_Normal("Layer2_Normal", 2D) = "bump" {}
		_Layer2_Tilling("Layer2_Tilling", Float) = 1
		_Layer2_HeightContrast("Layer2_HeightContrast", Range( 0 , 1)) = 0
		_Layer3_HRA("Layer3_HRA", 2D) = "white" {}
		_Layer3_Normal("Layer3_Normal", 2D) = "bump" {}
		_Layer3_BaseColor("Layer3_BaseColor", 2D) = "white" {}
		_Layer3_Tilling("Layer3_Tilling", Float) = 1
		_Layer3_HeightContrast("Layer3_HeightContrast", Range( 0 , 1)) = 0
		_BlendContrast("BlendContrast", Range( 0 , 1)) = 0.1
		_BlendMap("BlendMap", 2D) = "white" {}
		_SlopeRange("SlopeRange", Float) = 1
		_SlopeContrast("SlopeContrast", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
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
			float2 uv2_texcoord2;
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

		uniform sampler2D _Layer1_BaseColor;
		uniform float _Layer1_Tilling;
		uniform float _Layer1_HeightContrast;
		uniform sampler2D _Layer1_HRA;
		uniform sampler2D _BlendMap;
		uniform float _Layer2_HeightContrast;
		uniform sampler2D _Layer2_HRA;
		uniform float _Layer2_Tilling;
		uniform float _Layer3_HeightContrast;
		uniform sampler2D _Layer3_HRA;
		uniform float _Layer3_Tilling;
		uniform float _BlendContrast;
		uniform sampler2D _Layer2_BaseColor;
		uniform sampler2D _Layer3_BaseColor;
		uniform float _SlopeContrast;
		uniform float _SlopeRange;
		uniform sampler2D _Layer1_Normal;
		uniform sampler2D _Layer2_Normal;
		uniform sampler2D _Layer3_Normal;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			SurfaceOutputStandard s1 = (SurfaceOutputStandard ) 0;
			float2 LayerUV6 = ( i.uv_texcoord * 0.01 );
			float2 temp_output_10_0 = ( LayerUV6 * _Layer1_Tilling );
			float4 Layer1_BaseColor12 = tex2D( _Layer1_BaseColor, temp_output_10_0 );
			float temp_output_2_0_g7 = _Layer1_HeightContrast;
			float4 tex2DNode3 = tex2D( _Layer1_HRA, temp_output_10_0 );
			float lerpResult4_g7 = lerp( ( 0.0 - temp_output_2_0_g7 ) , ( temp_output_2_0_g7 + 1.0 ) , tex2DNode3.r);
			float clampResult3_g7 = clamp( lerpResult4_g7 , 0.0 , 1.0 );
			float Layer1_Height60 = clampResult3_g7;
			float4 break146 = tex2D( _BlendMap, i.uv2_texcoord2 );
			float temp_output_140_0 = ( Layer1_Height60 + break146.r );
			float temp_output_2_0_g8 = _Layer2_HeightContrast;
			float2 temp_output_25_0 = ( LayerUV6 * _Layer2_Tilling );
			float4 tex2DNode26 = tex2D( _Layer2_HRA, temp_output_25_0 );
			float lerpResult4_g8 = lerp( ( 0.0 - temp_output_2_0_g8 ) , ( temp_output_2_0_g8 + 1.0 ) , tex2DNode26.r);
			float clampResult3_g8 = clamp( lerpResult4_g8 , 0.0 , 1.0 );
			float Layer2_Height59 = clampResult3_g8;
			float temp_output_141_0 = ( Layer2_Height59 + break146.g );
			float temp_output_2_0_g9 = _Layer3_HeightContrast;
			float2 temp_output_73_0 = ( LayerUV6 * _Layer3_Tilling );
			float4 tex2DNode74 = tex2D( _Layer3_HRA, temp_output_73_0 );
			float lerpResult4_g9 = lerp( ( 0.0 - temp_output_2_0_g9 ) , ( temp_output_2_0_g9 + 1.0 ) , tex2DNode74.r);
			float clampResult3_g9 = clamp( lerpResult4_g9 , 0.0 , 1.0 );
			float Layer3_Height75 = clampResult3_g9;
			float temp_output_142_0 = ( Layer3_Height75 + break146.b );
			float temp_output_101_0 = ( max( max( temp_output_140_0 , temp_output_141_0 ) , temp_output_142_0 ) - _BlendContrast );
			float temp_output_106_0 = max( ( temp_output_140_0 - temp_output_101_0 ) , 0.0 );
			float temp_output_107_0 = max( ( temp_output_141_0 - temp_output_101_0 ) , 0.0 );
			float temp_output_108_0 = max( ( temp_output_142_0 - temp_output_101_0 ) , 0.0 );
			float4 appendResult109 = (float4(temp_output_106_0 , temp_output_107_0 , temp_output_108_0 , 0.0));
			float4 BlendWeight112 = ( appendResult109 / ( temp_output_106_0 + temp_output_107_0 + temp_output_108_0 ) );
			float4 break116 = BlendWeight112;
			float4 Layer2_BaseColor31 = tex2D( _Layer2_BaseColor, temp_output_25_0 );
			float4 Layer3_BaseColor81 = tex2D( _Layer3_BaseColor, temp_output_73_0 );
			float temp_output_9_0_g10 = _SlopeContrast;
			float4 break170 = BlendWeight112;
			float HeightCombined178 = ( ( Layer1_Height60 * break170.x ) + ( Layer2_Height59 * break170.y ) + ( Layer3_Height75 * break170.z ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float dotResult159 = dot( float3(0,1,0) , ase_worldNormal );
			float clampResult161 = clamp( ( 1.0 - dotResult159 ) , 0.0 , 1.0 );
			float clampResult8_g10 = clamp( ( ( HeightCombined178 - 1.0 ) + ( pow( clampResult161 , _SlopeRange ) * 2.0 ) ) , 0.0 , 1.0 );
			float lerpResult12_g10 = lerp( ( 0.0 - temp_output_9_0_g10 ) , ( temp_output_9_0_g10 + 1.0 ) , clampResult8_g10);
			float clampResult13_g10 = clamp( lerpResult12_g10 , 0.0 , 1.0 );
			float Slope168 = clampResult13_g10;
			float4 lerpResult181 = lerp( ( ( Layer1_BaseColor12 * break116.x ) + ( break116.y * Layer2_BaseColor31 ) + ( break116.z * Layer3_BaseColor81 ) ) , Layer2_BaseColor31 , Slope168);
			float4 BaseColor38 = lerpResult181;
			s1.Albedo = BaseColor38.rgb;
			float3 Layer1_Normal13 = UnpackNormal( tex2D( _Layer1_Normal, temp_output_10_0 ) );
			float4 break134 = BlendWeight112;
			float3 Layer2_Normal32 = UnpackNormal( tex2D( _Layer2_Normal, temp_output_25_0 ) );
			float3 Layer3_Normal80 = UnpackNormal( tex2D( _Layer3_Normal, temp_output_73_0 ) );
			float3 lerpResult190 = lerp( ( ( Layer1_Normal13 * break134.x ) + ( Layer2_Normal32 * break134.y ) + ( Layer3_Normal80 * break134.z ) ) , Layer2_Normal32 , Slope168);
			float3 Normal57 = lerpResult190;
			s1.Normal = WorldNormalVector( i , Normal57 );
			s1.Emission = float3( 0,0,0 );
			s1.Metallic = 0.0;
			float Layer1_Roughness14 = tex2DNode3.g;
			float4 break122 = BlendWeight112;
			float Layer2_Roughness29 = tex2DNode26.g;
			float Layer3_Roughness76 = tex2DNode74.g;
			float lerpResult184 = lerp( ( ( Layer1_Roughness14 * break122.x ) + ( Layer2_Roughness29 * break122.y ) + ( Layer3_Roughness76 * break122.z ) ) , Layer2_Roughness29 , Slope168);
			float Roughness42 = lerpResult184;
			s1.Smoothness = ( 1.0 - Roughness42 );
			float Layer1_AO15 = tex2DNode3.b;
			float4 break128 = BlendWeight112;
			float Layer2_AO30 = tex2DNode26.b;
			float Layer3_AO79 = tex2DNode74.b;
			float lerpResult187 = lerp( ( ( Layer1_AO15 * break128.x ) + ( Layer2_AO30 * break128.y ) + ( Layer3_AO79 * break128.z ) ) , Layer2_AO30 , Slope168);
			float AO48 = lerpResult187;
			s1.Occlusion = AO48;

			data.light = gi.light;

			UnityGI gi1 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g1 = UnityGlossyEnvironmentSetup( s1.Smoothness, data.worldViewDir, s1.Normal, float3(0,0,0));
			gi1 = UnityGlobalIllumination( data, s1.Occlusion, s1.Normal, g1 );
			#endif

			float3 surfResult1 = LightingStandard ( s1, viewDir, gi1 ).rgb;
			surfResult1 += s1.Emission;

			#ifdef UNITY_PASS_FORWARDADD//1
			surfResult1 -= s1.Emission;
			#endif//1
			c.rgb = surfResult1;
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
				float4 customPack1 : TEXCOORD1;
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
				o.customPack1.zw = customInputData.uv2_texcoord2;
				o.customPack1.zw = v.texcoord1;
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
				surfIN.uv2_texcoord2 = IN.customPack1.zw;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
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
7;29;1522;788;146.1098;-1593.412;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;7;-3715.901,-364.4894;Inherit;False;910.4323;250.9002;LayerUV;4;6;155;5;156;LayerUV;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-3665.901,-314.4894;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;156;-3621.485,-194.2122;Inherit;False;Constant;_Float1;Float 1;14;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;-3363.485,-243.2122;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;8;-3702.636,10.7043;Inherit;False;1620.932;835.9019;Layer01;13;15;14;60;13;12;2;4;3;10;9;11;147;148;Layer01;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;6;-3100.469,-296.5892;Inherit;False;LayerUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;22;-3706.23,1096.519;Inherit;False;1636.74;886.244;Layer02;13;32;31;30;27;29;28;59;26;25;23;24;149;150;Layer02;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-3689.557,1269.782;Inherit;False;Property;_Layer2_Tilling;Layer2_Tilling;8;0;Create;True;0;0;False;0;False;1;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;70;-3726.546,2185.826;Inherit;False;1663.801;838.1905;Layer03;13;80;79;81;77;78;76;75;74;73;71;72;151;152;Layer03;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-3685.963,183.9671;Inherit;False;Property;_Layer1_Tilling;Layer1_Tilling;3;0;Create;True;0;0;False;0;False;1;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;9;-3661.384,78.12765;Inherit;False;6;LayerUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-3664.978,1163.942;Inherit;False;6;LayerUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-3709.873,2359.089;Inherit;False;Property;_Layer3_Tilling;Layer3_Tilling;13;0;Create;True;0;0;False;0;False;1;12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-3412.025,136.3144;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;-3685.294,2253.249;Inherit;False;6;LayerUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-3415.618,1222.129;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;3;-3142.596,285.7044;Inherit;True;Property;_Layer1_HRA;Layer1_HRA;1;0;Create;True;0;0;False;0;False;-1;None;c99234d9562fd4d4093a91230c3b1b07;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;26;-3146.19,1371.519;Inherit;True;Property;_Layer2_HRA;Layer2_HRA;6;0;Create;True;0;0;False;0;False;-1;None;064db50843ef7154c8c0efab87b9a615;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;149;-2932.29,1309.14;Inherit;False;Property;_Layer2_HeightContrast;Layer2_HeightContrast;9;0;Create;True;0;0;False;0;False;0;0.52;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-2906.523,217.4171;Inherit;False;Property;_Layer1_HeightContrast;Layer1_HeightContrast;4;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-3435.934,2311.436;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;148;-2617.523,225.4171;Inherit;False;CheapContrast;-1;;7;e8aacd026e1e6e449b251024d3d28cfa;0;2;6;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;150;-2643.29,1317.14;Inherit;False;CheapContrast;-1;;8;e8aacd026e1e6e449b251024d3d28cfa;0;2;6;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;74;-3166.506,2460.826;Inherit;True;Property;_Layer3_HRA;Layer3_HRA;10;0;Create;True;0;0;False;0;False;-1;None;757acd33b7e838647983fc8e8d0ba919;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;151;-2910.628,2409.32;Inherit;False;Property;_Layer3_HeightContrast;Layer3_HeightContrast;14;0;Create;True;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;154;-4663.518,3610.576;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;153;-4393.806,3609.796;Inherit;True;Property;_BlendMap;BlendMap;16;0;Create;True;0;0;False;0;False;-1;None;b319939d1b8ecba41ba42bdd281b3727;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;152;-2621.628,2417.32;Inherit;False;CheapContrast;-1;;9;e8aacd026e1e6e449b251024d3d28cfa;0;2;6;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;-2345.272,1383.344;Inherit;False;Layer2_Height;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;65;-4334.545,3471.374;Inherit;False;2720.715;1148.92;BlendFactor;22;112;110;109;111;107;108;106;103;105;104;101;114;146;139;143;144;140;141;142;102;100;99;BlendFactor;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-2315.199,281.8956;Inherit;False;Layer1_Height;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;146;-4067.574,3755.539;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;143;-3664.508,3721.039;Inherit;False;59;Layer2_Height;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;139;-3673.743,3584.593;Inherit;False;60;Layer1_Height;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;-2288.602,2475.295;Inherit;False;Layer3_Height;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;140;-3390.225,3605.456;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;144;-3677.706,3845.427;Inherit;False;75;Layer3_Height;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;141;-3393.637,3743.058;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;142;-3499.332,4029.222;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;99;-3190.587,4096.894;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-3164.898,4424.604;Inherit;False;Property;_BlendContrast;BlendContrast;15;0;Create;True;0;0;False;0;False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;100;-3073.34,4244.193;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;101;-2819.755,4157.726;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;114;-2782.843,3975.784;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;103;-2749.652,3684.293;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;104;-2718.045,3848.159;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;105;-2603.609,4074.911;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;107;-2554.728,3900.742;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;108;-2448.839,4079.058;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;106;-2584.004,3741.753;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;111;-2281.151,4027.709;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;109;-2333.085,3830.142;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;110;-2120.324,3909.052;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;179;2031.05,1738.572;Inherit;False;1470.837;454.0751;HeightCombined;10;169;170;171;172;173;174;175;176;177;178;HeightCombined;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;112;-1961.151,3947.709;Inherit;False;BlendWeight;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;169;2081.051,1920.647;Inherit;False;112;BlendWeight;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;164;2032.625,2436.899;Inherit;False;1895.99;630.1833;AutoSlope;11;157;158;162;163;161;159;160;165;167;168;180;AutoSlope;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;173;2624.369,2030.543;Inherit;False;75;Layer3_Height;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;158;2082.625,2679.428;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;157;2085.843,2486.899;Inherit;False;Constant;_Vector0;Vector 0;17;0;Create;True;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;172;2617.162,1922.572;Inherit;False;59;Layer2_Height;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;170;2297.051,1920.647;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;171;2592.162,1788.572;Inherit;False;60;Layer1_Height;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;159;2345.729,2613.96;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;174;2841.051,2059.646;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;176;2864.051,1947.647;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;175;2844.051,1827.647;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;160;2524.838,2663.37;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;177;3106.051,1954.647;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;163;2617.54,2862.259;Inherit;False;Property;_SlopeRange;SlopeRange;17;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;40;-654.71,449.4966;Inherit;False;2157.4;570.5643;Roughness;13;42;126;123;125;124;92;44;122;45;121;184;185;186;Roughness;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;178;3250.493,1967.145;Inherit;False;HeightCombined;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;161;2702.193,2721.511;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;162;2907.539,2767.259;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;167;2883.62,2973.275;Inherit;False;Property;_SlopeContrast;SlopeContrast;18;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;52;-648.3005,1661.148;Inherit;False;2162.974;558.2719;Normal;13;57;138;137;135;136;55;56;98;134;133;190;191;192;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;77;-3159.506,2235.826;Inherit;True;Property;_Layer3_BaseColor;Layer3_BaseColor;12;0;Create;True;0;0;False;0;False;-1;None;43ef035d194e65e4a8d1e8b60d0f5bc1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;46;-650.3538,1030.597;Inherit;False;2156.858;596.546;AO;13;48;132;131;129;130;49;95;128;47;127;187;188;189;AO;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;27;-3137.189,1611.519;Inherit;True;Property;_Layer2_Normal;Layer2_Normal;7;0;Create;True;0;0;False;0;False;-1;None;6ca895ccc8c4288498803f7a977cd7f5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;28;-3139.19,1146.519;Inherit;True;Property;_Layer2_BaseColor;Layer2_BaseColor;5;0;Create;True;0;0;False;0;False;-1;None;3f42953a5ef8d0047ab025ee7078eb93;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-2356.874,1469.173;Inherit;False;Layer2_Roughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-3135.596,60.70428;Inherit;True;Property;_Layer1_BaseColor;Layer1_BaseColor;0;0;Create;True;0;0;False;0;False;-1;None;fbc410215dc498046a53f337147a497d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;39;-671.2408,-127.4561;Inherit;False;2268.768;535.8992;BaseColor;13;38;120;119;117;118;35;116;88;34;115;183;182;181;BaseColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;-624.6873,654.1492;Inherit;False;112;BlendWeight;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;78;-3157.505,2700.826;Inherit;True;Property;_Layer3_Normal;Layer3_Normal;11;0;Create;True;0;0;False;0;False;-1;None;884ad85d61a4615488aa65c12b5f0941;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;180;2819.348,2874.962;Inherit;False;178;HeightCombined;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;76;-2300.203,2561.124;Inherit;False;Layer3_Roughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-2322.628,387.6793;Inherit;False;Layer1_Roughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-3133.596,525.7044;Inherit;True;Property;_Layer1_Normal;Layer1_Normal;2;0;Create;True;0;0;False;0;False;-1;None;694653547afca3948bcb3fb775d80291;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;165;3114.153,2797.287;Inherit;False;HeightLerp;-1;;10;5b7e48aeb672921408225b5478ec5653;0;3;5;FLOAT;0;False;1;FLOAT;0;False;9;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-97.69894,797.3931;Inherit;False;76;Layer3_Roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;-668.1649,66.96564;Inherit;False;112;BlendWeight;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-2772.508,1187.173;Inherit;False;Layer2_BaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;-2768.915,101.3583;Inherit;False;Layer1_BaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-126.2296,632.5215;Inherit;False;29;Layer2_Roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;122;-408.6873,654.1492;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-2766.915,572.3584;Inherit;False;Layer1_Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;-2346.178,1539.059;Inherit;False;Layer2_AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;79;-2289.508,2631.01;Inherit;False;Layer3_AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;127;-626.1699,1273.91;Inherit;False;112;BlendWeight;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;133;-626.4119,1854.223;Inherit;False;112;BlendWeight;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-2311.391,479.6822;Inherit;False;Layer1_AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;-240.4067,497.408;Inherit;False;14;Layer1_Roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;81;-2792.824,2276.48;Inherit;False;Layer3_BaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-2770.508,1658.173;Inherit;False;Layer2_Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-2789.824,2746.48;Inherit;False;Layer3_Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;116;-452.1649,66.96564;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;95;-103.5674,1396.087;Inherit;False;79;Layer3_AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;128;-410.1697,1273.91;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;35;-125.2408,140.5439;Inherit;False;31;Layer2_BaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;83.13463,489.8962;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;-192.4626,1105.822;Inherit;False;15;Layer1_AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;170.1599,887.7313;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;134;-410.4118,1854.223;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;34;-323.2408,-66.45605;Inherit;False;12;Layer1_BaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;138.0713,691.4403;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-236.3485,287.5855;Inherit;False;81;Layer3_BaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-115.3005,1722.148;Inherit;False;13;Layer1_Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;-103.6029,1266.559;Inherit;False;30;Layer2_AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;168;3434.62,2826.275;Inherit;False;Slope;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;-83.0936,1964.119;Inherit;False;80;Layer3_Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;-90.30048,1856.148;Inherit;False;32;Layer2_Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;126;376.1423,712.6781;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;185;447.5916,926.4534;Inherit;False;168;Slope;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;80.9425,1454.689;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;122.5272,-55.57707;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;425.5917,838.4534;Inherit;False;29;Layer2_Roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;98.68624,263.4868;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;133.5881,1993.223;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;136.5881,1761.223;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;156.5881,1881.223;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;113.7553,71.15182;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;29.9425,1121.689;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;86.9425,1318.689;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;192;473.2821,2030.064;Inherit;False;32;Layer2_Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;191;495.2823,2118.063;Inherit;False;168;Slope;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;132;288.9425,1247.689;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;138;398.5881,1888.223;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;120;331.6367,114.8212;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;189;354.8635,1393.344;Inherit;False;30;Layer2_AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;182;332.894,240.9495;Inherit;False;31;Layer2_BaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;354.894,328.9495;Inherit;False;168;Slope;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;184;748.5913,760.4534;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;188;376.8635,1481.344;Inherit;False;168;Slope;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;190;796.2822,1952.064;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;187;677.8635,1315.344;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;181;655.894,162.9495;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;1122.376,624.9862;Inherit;False;Roughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;1102.107,1202.173;Inherit;False;AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;1203.596,1887.13;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;19;1966.891,807.7236;Inherit;False;42;Roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;956.2318,60.27465;Inherit;False;BaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;2178.892,897.7236;Inherit;False;48;AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;16;2112.892,499.7236;Inherit;False;38;BaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;2136.892,599.7236;Inherit;False;57;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;21;2142.892,695.7236;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;20;2222.892,795.7236;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;145;-4572.138,3842.915;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomStandardSurface;1;2520.703,539.2911;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2915.702,445.2911;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Landscape;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;155;0;5;0
WireConnection;155;1;156;0
WireConnection;6;0;155;0
WireConnection;10;0;9;0
WireConnection;10;1;11;0
WireConnection;25;0;23;0
WireConnection;25;1;24;0
WireConnection;3;1;10;0
WireConnection;26;1;25;0
WireConnection;73;0;72;0
WireConnection;73;1;71;0
WireConnection;148;6;3;1
WireConnection;148;2;147;0
WireConnection;150;6;26;1
WireConnection;150;2;149;0
WireConnection;74;1;73;0
WireConnection;153;1;154;0
WireConnection;152;6;74;1
WireConnection;152;2;151;0
WireConnection;59;0;150;0
WireConnection;60;0;148;0
WireConnection;146;0;153;0
WireConnection;75;0;152;0
WireConnection;140;0;139;0
WireConnection;140;1;146;0
WireConnection;141;0;143;0
WireConnection;141;1;146;1
WireConnection;142;0;144;0
WireConnection;142;1;146;2
WireConnection;99;0;140;0
WireConnection;99;1;141;0
WireConnection;100;0;99;0
WireConnection;100;1;142;0
WireConnection;101;0;100;0
WireConnection;101;1;102;0
WireConnection;114;0;101;0
WireConnection;103;0;140;0
WireConnection;103;1;114;0
WireConnection;104;0;141;0
WireConnection;104;1;101;0
WireConnection;105;0;142;0
WireConnection;105;1;101;0
WireConnection;107;0;104;0
WireConnection;108;0;105;0
WireConnection;106;0;103;0
WireConnection;111;0;106;0
WireConnection;111;1;107;0
WireConnection;111;2;108;0
WireConnection;109;0;106;0
WireConnection;109;1;107;0
WireConnection;109;2;108;0
WireConnection;110;0;109;0
WireConnection;110;1;111;0
WireConnection;112;0;110;0
WireConnection;170;0;169;0
WireConnection;159;0;157;0
WireConnection;159;1;158;0
WireConnection;174;0;173;0
WireConnection;174;1;170;2
WireConnection;176;0;172;0
WireConnection;176;1;170;1
WireConnection;175;0;171;0
WireConnection;175;1;170;0
WireConnection;160;0;159;0
WireConnection;177;0;175;0
WireConnection;177;1;176;0
WireConnection;177;2;174;0
WireConnection;178;0;177;0
WireConnection;161;0;160;0
WireConnection;162;0;161;0
WireConnection;162;1;163;0
WireConnection;77;1;73;0
WireConnection;27;1;25;0
WireConnection;28;1;25;0
WireConnection;29;0;26;2
WireConnection;2;1;10;0
WireConnection;78;1;73;0
WireConnection;76;0;74;2
WireConnection;14;0;3;2
WireConnection;4;1;10;0
WireConnection;165;5;162;0
WireConnection;165;1;180;0
WireConnection;165;9;167;0
WireConnection;31;0;28;0
WireConnection;12;0;2;0
WireConnection;122;0;121;0
WireConnection;13;0;4;0
WireConnection;30;0;26;3
WireConnection;79;0;74;3
WireConnection;15;0;3;3
WireConnection;81;0;77;0
WireConnection;32;0;27;0
WireConnection;80;0;78;0
WireConnection;116;0;115;0
WireConnection;128;0;127;0
WireConnection;123;0;45;0
WireConnection;123;1;122;0
WireConnection;125;0;92;0
WireConnection;125;1;122;2
WireConnection;134;0;133;0
WireConnection;124;0;44;0
WireConnection;124;1;122;1
WireConnection;168;0;165;0
WireConnection;126;0;123;0
WireConnection;126;1;124;0
WireConnection;126;2;125;0
WireConnection;131;0;95;0
WireConnection;131;1;128;2
WireConnection;117;0;34;0
WireConnection;117;1;116;0
WireConnection;119;0;116;2
WireConnection;119;1;88;0
WireConnection;137;0;98;0
WireConnection;137;1;134;2
WireConnection;135;0;55;0
WireConnection;135;1;134;0
WireConnection;136;0;56;0
WireConnection;136;1;134;1
WireConnection;118;0;116;1
WireConnection;118;1;35;0
WireConnection;129;0;49;0
WireConnection;129;1;128;0
WireConnection;130;0;47;0
WireConnection;130;1;128;1
WireConnection;132;0;129;0
WireConnection;132;1;130;0
WireConnection;132;2;131;0
WireConnection;138;0;135;0
WireConnection;138;1;136;0
WireConnection;138;2;137;0
WireConnection;120;0;117;0
WireConnection;120;1;118;0
WireConnection;120;2;119;0
WireConnection;184;0;126;0
WireConnection;184;1;186;0
WireConnection;184;2;185;0
WireConnection;190;0;138;0
WireConnection;190;1;192;0
WireConnection;190;2;191;0
WireConnection;187;0;132;0
WireConnection;187;1;189;0
WireConnection;187;2;188;0
WireConnection;181;0;120;0
WireConnection;181;1;182;0
WireConnection;181;2;183;0
WireConnection;42;0;184;0
WireConnection;48;0;187;0
WireConnection;57;0;190;0
WireConnection;38;0;181;0
WireConnection;20;0;19;0
WireConnection;1;0;16;0
WireConnection;1;1;18;0
WireConnection;1;3;21;0
WireConnection;1;4;20;0
WireConnection;1;5;17;0
WireConnection;0;13;1;0
ASEEND*/
//CHKSM=CC8B06D63C1F9C98EFEFEB87A49A34FF01828193