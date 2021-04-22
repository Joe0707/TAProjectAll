// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hologram"
{
	Properties
	{
		[HDR]_MainColor("MainColor", Color) = (0,0,0,0)
		[Toggle]_ZWriteMode("ZWriteMode", Float) = 0
		_NormalMap("NormalMap", 2D) = "bump" {}
		_RimBias("RimBias", Float) = 0
		_RimScale("RimScale", Float) = 1
		_RimPower("RimPower", Float) = 2
		_WireFrame("WireFrame", 2D) = "white" {}
		_WireFrameIntensity("WireFrameIntensity", Float) = 1
		_FlickControl("FlickControl", Range( 0 , 1)) = 0
		_Alpha("Alpha", Range( 0 , 1)) = 0
		[HDR]_ScanlineColor("ScanlineColor", Color) = (0,0,0,0)
		_Scanline1("Scanline1", 2D) = "white" {}
		_Line1Freq("Line 1 Freq", Float) = 2
		_Line1Speed("Line 1 Speed", Float) = 0
		_Line1Width("Line 1 Width", Float) = 0
		_Line1Hardness("Line 1 Hardness", Float) = 1
		_Line1Alpha("Line 1 Alpha", Float) = 1
		_Scanline2("Scanline2", 2D) = "white" {}
		_Line2Freq("Line 2 Freq", Float) = 2
		_Line2Speed("Line 2 Speed", Float) = 0
		_Line2Width("Line 2 Width", Float) = 0
		_Line2Hardness("Line 2 Hardness", Float) = 1
		_Line2Alpha("Line 2 Alpha", Float) = 1
		_RandomVertexOffset("RandomVertexOffset", Vector) = (0,0,0,0)
		_RandomTilling("RandomTilling", Float) = 0
		_ScanlineVertexOffset("ScanlineVertexOffset", Vector) = (0,0,0,0)
		_GlicthTex("GlicthTex", 2D) = "white" {}
		_GlitchFreq("GlitchFreq", Float) = 2
		_GlitchSpeed("Glitch Speed", Float) = 0
		_GlitchWidth("GlitchWidth", Float) = 0
		_GlitchHardness("GlitchHardness", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Back
		ZWrite [_ZWriteMode]
		Blend SrcAlpha OneMinusSrcAlpha
		
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
			float3 worldPos;
			float vertexToFrag161;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
		};

		uniform float _ZWriteMode;
		uniform float3 _RandomVertexOffset;
		uniform float _RandomTilling;
		uniform float3 _ScanlineVertexOffset;
		uniform sampler2D _GlicthTex;
		uniform float _GlitchFreq;
		uniform float _GlitchSpeed;
		uniform float _GlitchWidth;
		uniform float _GlitchHardness;
		uniform float _FlickControl;
		uniform float4 _MainColor;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _RimBias;
		uniform float _RimScale;
		uniform float _RimPower;
		uniform sampler2D _Scanline1;
		uniform float _Line1Freq;
		uniform float _Line1Speed;
		uniform float _Line1Width;
		uniform float _Line1Hardness;
		uniform sampler2D _Scanline2;
		uniform float _Line2Freq;
		uniform float _Line2Speed;
		uniform float _Line2Width;
		uniform float _Line2Hardness;
		uniform float4 _ScanlineColor;
		uniform float _Line1Alpha;
		uniform float _Line2Alpha;
		uniform sampler2D _WireFrame;
		uniform float4 _WireFrame_ST;
		uniform float _WireFrameIntensity;
		uniform float _Alpha;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 viewToObjDir116 = mul( UNITY_MATRIX_T_MV, float4( _RandomVertexOffset, 0 ) ).xyz;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float mulTime105 = _Time.y * -2.5;
			float mulTime108 = _Time.y * -2.0;
			float2 appendResult106 = (float2((ase_worldPos.y*_RandomTilling + mulTime105) , mulTime108));
			float simplePerlin2D107 = snoise( appendResult106 );
			simplePerlin2D107 = simplePerlin2D107*0.5 + 0.5;
			float3 objToWorld117 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime119 = _Time.y * -5.0;
			float mulTime122 = _Time.y * -1.0;
			float2 appendResult123 = (float2((( objToWorld117.x + objToWorld117.y + objToWorld117.z )*200.0 + mulTime119) , mulTime122));
			float simplePerlin2D124 = snoise( appendResult123 );
			simplePerlin2D124 = simplePerlin2D124*0.5 + 0.5;
			float clampResult130 = clamp( (simplePerlin2D124*2.0 + -1.0) , 0.0 , 1.0 );
			float temp_output_131_0 = ( (simplePerlin2D107*2.0 + -1.0) * clampResult130 );
			float2 break132 = appendResult106;
			float2 appendResult135 = (float2(( 20.0 * break132.x ) , break132.y));
			float simplePerlin2D136 = snoise( appendResult135 );
			simplePerlin2D136 = simplePerlin2D136*0.5 + 0.5;
			float clampResult138 = clamp( (simplePerlin2D136*2.0 + -1.0) , 0.0 , 1.0 );
			float3 GlitchVertexOffset114 = ( ( viewToObjDir116 * 0.01 ) * ( temp_output_131_0 + ( temp_output_131_0 * clampResult138 ) ) );
			float3 viewToObjDir150 = mul( UNITY_MATRIX_T_MV, float4( _ScanlineVertexOffset, 0 ) ).xyz;
			float3 objToWorld2_g15 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime7_g15 = _Time.y * _GlitchSpeed;
			float2 appendResult9_g15 = (float2(0.5 , (( ase_worldPos.y - objToWorld2_g15.y )*_GlitchFreq + mulTime7_g15)));
			float clampResult23_g15 = clamp( ( ( tex2Dlod( _GlicthTex, float4( appendResult9_g15, 0, 0.0) ).r - _GlitchWidth ) * _GlitchHardness ) , 0.0 , 1.0 );
			float3 ScanlineGlitch154 = ( ( viewToObjDir150 * 0.01 ) * clampResult23_g15 );
			v.vertex.xyz += ( GlitchVertexOffset114 + ScanlineGlitch154 );
			v.vertex.w = 1;
			float3 objToWorld9 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime8 = _Time.y * 15.0;
			float mulTime17 = _Time.y * 0.5;
			float2 appendResult16 = (float2((( objToWorld9.x + objToWorld9.y + objToWorld9.z )*200.0 + mulTime8) , mulTime17));
			float simplePerlin2D12 = snoise( appendResult16 );
			simplePerlin2D12 = simplePerlin2D12*0.5 + 0.5;
			float clampResult22 = clamp( (-0.5 + (simplePerlin2D12 - 0.0) * (2.0 - -0.5) / (1.0 - 0.0)) , 0.0 , 1.0 );
			float lerpResult48 = lerp( 1.0 , clampResult22 , _FlickControl);
			o.vertexToFrag161 = lerpResult48;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float Flicking20 = i.vertexToFrag161;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float fresnelNdotV26 = dot( normalize( (WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) ) )) ), ase_worldViewDir );
			float fresnelNode26 = ( _RimBias + _RimScale * pow( max( 1.0 - fresnelNdotV26 , 0.0001 ), _RimPower ) );
			float FresnelFactor33 = max( fresnelNode26 , 0.0 );
			float3 objToWorld2_g13 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime7_g13 = _Time.y * _Line1Speed;
			float2 appendResult9_g13 = (float2(0.5 , (( ase_worldPos.y - objToWorld2_g13.y )*_Line1Freq + mulTime7_g13)));
			float clampResult23_g13 = clamp( ( ( tex2D( _Scanline1, appendResult9_g13 ).r - _Line1Width ) * _Line1Hardness ) , 0.0 , 1.0 );
			float temp_output_159_0 = clampResult23_g13;
			float3 objToWorld2_g14 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime7_g14 = _Time.y * _Line2Speed;
			float2 appendResult9_g14 = (float2(0.5 , (( ase_worldPos.y - objToWorld2_g14.y )*_Line2Freq + mulTime7_g14)));
			float clampResult23_g14 = clamp( ( ( tex2D( _Scanline2, appendResult9_g14 ).r - _Line2Width ) * _Line2Hardness ) , 0.0 , 1.0 );
			float temp_output_158_0 = clampResult23_g14;
			float4 ScanlineColor87 = ( ( temp_output_159_0 * temp_output_158_0 ) * _ScanlineColor );
			o.Emission = ( Flicking20 * ( _MainColor + ( _MainColor * FresnelFactor33 ) + max( ScanlineColor87 , float4( 0,0,0,0 ) ) ) ).rgb;
			float temp_output_97_0 = ( temp_output_158_0 * _Line2Alpha );
			float ScanlineAlpha90 = ( ( ( temp_output_159_0 * _Line1Alpha ) * temp_output_97_0 ) + temp_output_97_0 );
			float clampResult45 = clamp( ( _MainColor.a + FresnelFactor33 + ScanlineAlpha90 ) , 0.0 , 1.0 );
			float2 uv_WireFrame = i.uv_texcoord * _WireFrame_ST.xy + _WireFrame_ST.zw;
			float WireFrame38 = ( tex2D( _WireFrame, uv_WireFrame ).r * _WireFrameIntensity );
			o.Alpha = ( clampResult45 * WireFrame38 * _Alpha );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				float3 customPack1 : TEXCOORD1;
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
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.x = customInputData.vertexToFrag161;
				o.customPack1.yz = customInputData.uv_texcoord;
				o.customPack1.yz = v.texcoord;
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
				surfIN.vertexToFrag161 = IN.customPack1.x;
				surfIN.uv_texcoord = IN.customPack1.yz;
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
7;29;1906;1044;2115.531;-1410.013;3.003511;True;False
Node;AmplifyShaderEditor.CommentaryNode;141;-1454.728,2470.686;Inherit;False;3642.201;1540.254;RandomGlicth;35;105;104;102;117;103;108;106;120;118;119;132;134;122;121;123;133;135;124;136;107;129;109;137;130;111;131;113;116;139;112;140;110;114;138;162;RandomGlicth;0.07586217,1,0,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;105;-1324.728,2963.933;Inherit;False;1;0;FLOAT;-2.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;117;-936.635,3150.512;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;104;-1400.728,2813.933;Inherit;False;Property;_RandomTilling;RandomTilling;25;0;Create;True;0;0;False;0;False;0;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;102;-1404.728,2649.933;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;120;-698.5827,3311.681;Inherit;False;Constant;_Float3;Float 3;2;0;Create;True;0;0;False;0;False;200;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;119;-646.6347,3405.512;Inherit;False;1;0;FLOAT;-5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;118;-658.6347,3176.512;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;108;-1072.728,2981.933;Inherit;False;1;0;FLOAT;-2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;103;-1111.729,2712.933;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;122;-443.5828,3510.681;Inherit;False;1;0;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;121;-450.5828,3180.681;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;19;-3436.101,-280.3636;Inherit;False;2011.279;535.8098;Flicking;14;20;48;22;49;21;12;16;15;17;11;14;8;9;161;Flicking;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;106;-817.7288,2744.933;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;132;-641.0099,3786.444;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;123;-175.5838,3236.681;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-533.2615,3689.772;Inherit;False;Constant;_Float1;Float 1;26;0;Create;True;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;9;-3386.101,-230.3636;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-340.9255,3705.884;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;124;-25.6998,3233.268;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;101;-3454.457,919.459;Inherit;False;1772.25;1273.287;Scanline;22;77;83;60;78;80;76;55;79;81;82;96;89;97;88;86;98;100;99;85;90;87;159;Scanline;0,0.9586205,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-3148.049,-69.19508;Inherit;False;Constant;_Tilling;Tilling;2;0;Create;True;0;0;False;0;False;200;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;8;-3152.101,38.63644;Inherit;False;1;0;FLOAT;15;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-3108.101,-204.3636;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-3359.346,1340.459;Inherit;False;Property;_Line1Width;Line 1 Width;15;0;Create;True;0;0;False;0;False;0;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-3404.108,1150.152;Inherit;False;Property;_Line1Freq;Line 1 Freq;13;0;Create;True;0;0;False;0;False;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-3312.346,1429.46;Inherit;False;Property;_Line1Hardness;Line 1 Hardness;16;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-3357.741,1798.439;Inherit;False;Property;_Line2Freq;Line 2 Freq;19;0;Create;True;0;0;False;0;False;2;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;129;264.8739,3234.084;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;135;-193.9044,3771.339;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-3404.457,1240.404;Inherit;False;Property;_Line1Speed;Line 1 Speed;14;0;Create;True;0;0;False;0;False;0;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;17;-2852.049,-15.1951;Inherit;False;1;0;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-3314.011,1988.746;Inherit;False;Property;_Line2Width;Line 2 Width;21;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;34;-3419.958,286.345;Inherit;False;1289;536;Fresnel;8;27;29;30;31;26;32;28;33;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;79;-3196.98,1617.746;Inherit;True;Property;_Scanline2;Scanline2;18;0;Create;True;0;0;False;0;False;None;4bbf045a9f687084ea4bc84d53c39623;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;83;-3265.98,2077.746;Inherit;False;Property;_Line2Hardness;Line 2 Hardness;22;0;Create;True;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-3357.059,1888.691;Inherit;False;Property;_Line2Speed;Line 2 Speed;20;0;Create;True;0;0;False;0;False;0;-3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;15;-2900.049,-200.1951;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;76;-3243.346,969.459;Inherit;True;Property;_Scanline1;Scanline1;12;0;Create;True;0;0;False;0;False;None;afb16754b93daf04187b10b438f7a250;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.NoiseGeneratorNode;136;17.7717,3752.94;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;107;-475.1577,2745.742;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;130;521.8738,3240.084;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-2618.654,1660.342;Inherit;False;Property;_Line1Alpha;Line 1 Alpha;17;0;Create;True;0;0;False;0;False;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;16;-2625.05,-144.1951;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;158;-2913.251,1763.625;Inherit;False;Scanline;-1;;14;27a06d4223662084e9e433808b2a7679;0;6;20;SAMPLER2D;0;False;16;FLOAT;0;False;18;FLOAT;2;False;19;FLOAT;1;False;21;FLOAT;0;False;22;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;159;-2915.181,1103.291;Inherit;False;Scanline;-1;;13;27a06d4223662084e9e433808b2a7679;0;6;20;SAMPLER2D;0;False;16;FLOAT;0;False;18;FLOAT;2;False;19;FLOAT;1;False;21;FLOAT;0;False;22;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;28;-3369.958,336.345;Inherit;True;Property;_NormalMap;NormalMap;3;0;Create;True;0;0;False;0;False;-1;None;77b91526e481d164aa4fee6e8b5fc94c;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;96;-2621.292,1887.206;Inherit;False;Property;_Line2Alpha;Line 2 Alpha;23;0;Create;True;0;0;False;0;False;1;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;137;289.1331,3751.441;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;27;-3029.958,350.345;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.VertexToFragmentNode;162;666.3201,3237.333;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;109;37.28129,2756.715;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-2426.292,1769.206;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;12;-2457.166,-146.6082;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-3014.958,528.3449;Inherit;False;Property;_RimBias;RimBias;4;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-3000.958,621.3449;Inherit;False;Property;_RimScale;RimScale;5;0;Create;True;0;0;False;0;False;1;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;155;-1352.594,1778.356;Inherit;False;1579.867;677.9792;ScanlieGlitch;12;150;154;149;153;151;152;148;147;145;146;144;160;ScanlieGlitch;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-2426.38,1643.303;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-2998.958,707.3449;Inherit;False;Property;_RimPower;RimPower;6;0;Create;True;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;111;995.4727,2520.686;Inherit;False;Property;_RandomVertexOffset;RandomVertexOffset;24;0;Create;True;0;0;False;0;False;0,0,0;-2.5,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;827.9831,2784.188;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;21;-2220.24,-141.4879;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.5;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-2496.992,1104.306;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;86;-2504.726,1218.411;Inherit;False;Property;_ScanlineColor;ScanlineColor;11;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0.318402,2,15.162,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;26;-2760.958,390.345;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;138;580.1331,3750.441;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;149;-863.6311,1828.356;Inherit;False;Property;_ScanlineVertexOffset;ScanlineVertexOffset;26;0;Create;True;0;0;False;0;False;0,0,0;3,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-2266.292,1702.206;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;-2096.292,1740.206;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;39;-2110.928,308.1802;Inherit;False;843.5527;501.874;WireFrame;4;38;36;35;37;WireFrame;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;972.8409,3014.435;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;146;-1232.582,2349.135;Inherit;False;Property;_GlitchHardness;GlitchHardness;31;0;Create;True;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;144;-1229.211,1875.065;Inherit;True;Property;_GlicthTex;GlicthTex;27;0;Create;True;0;0;False;0;False;None;afb16754b93daf04187b10b438f7a250;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMaxOpNode;32;-2517.958,385.345;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;1324.266,2725.81;Inherit;False;Constant;_Float0;Float 0;26;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;22;-2018.239,-143.5457;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;116;1230.658,2527.651;Inherit;False;View;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;49;-2237.488,60.08549;Inherit;False;Property;_FlickControl;FlickControl;9;0;Create;True;0;0;False;0;False;0;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;151;-534.8378,2033.48;Inherit;False;Constant;_Float2;Float 2;26;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-2222.319,1107.421;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-1246.344,2065.927;Inherit;False;Property;_GlitchFreq;GlitchFreq;28;0;Create;True;0;0;False;0;False;2;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-1231.482,2265.334;Inherit;False;Property;_GlitchWidth;GlitchWidth;30;0;Create;True;0;0;False;0;False;0;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;150;-628.4458,1835.321;Inherit;False;View;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;148;-1246.694,2174.379;Inherit;False;Property;_GlitchSpeed;Glitch Speed;29;0;Create;True;0;0;False;0;False;0;-0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;-2018.751,1112.547;Inherit;False;ScanlineColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-2373.958,392.345;Inherit;False;FresnelFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;35;-2060.928,358.1802;Inherit;True;Property;_WireFrame;WireFrame;7;0;Create;True;0;0;False;0;False;-1;None;92f284b27dea88e41885444624ec2963;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;140;1216.199,2825.076;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;48;-1838.488,-151.9145;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;1546.473,2622.686;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;-1926.207,1734.404;Inherit;False;ScanlineAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-2019.928,593.1799;Inherit;False;Property;_WireFrameIntensity;WireFrameIntensity;8;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;160;-808.9105,2149.965;Inherit;False;Scanline;-1;;15;27a06d4223662084e9e433808b2a7679;0;6;20;SAMPLER2D;0;False;16;FLOAT;0;False;18;FLOAT;2;False;19;FLOAT;1;False;21;FLOAT;0;False;22;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;-367.5807,1929.319;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-491.3136,304.2961;Inherit;False;87;ScanlineColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;1721.473,2782.686;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;1;-916.7689,60.69221;Inherit;False;Property;_MainColor;MainColor;0;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0.60791,1.447218,3.922,0.052;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-1680.928,442.1801;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;161;-1692.93,-230.0479;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-534.9448,183.4576;Inherit;False;33;FresnelFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-759.3841,685.6197;Inherit;False;90;ScanlineAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;-200.2382,2097.647;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-669.3679,451.3809;Inherit;False;33;FresnelFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;154;-16.72649,2113.199;Inherit;False;ScanlineGlitch;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;1915.473,2789.686;Inherit;False;GlitchVertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;95;-259.6695,299.5029;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-1488.638,-69.2493;Inherit;True;Flicking;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-366.5988,443.5348;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-319.9451,125.4576;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-1488.928,451.1801;Inherit;False;WireFrame;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;25;-1372.048,-279.8993;Inherit;False;249;165;ProPerties;1;24;ProPerties;1,0,0,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;-280.497,889.9765;Inherit;False;114;GlitchVertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;-305.5988,588.5349;Inherit;False;38;WireFrame;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;-252.1876,1014.205;Inherit;False;154;ScanlineGlitch;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-141.945,61.4576;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-161.049,-27.23957;Inherit;False;20;Flicking;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-332.9597,700.8967;Inherit;False;Property;_Alpha;Alpha;10;0;Create;True;0;0;False;0;False;0;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;45;-191.5988,465.5348;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;156;155.8124,934.2051;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;48.70567,63.20506;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;2.401282,505.5348;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1322.048,-229.8993;Inherit;False;Property;_ZWriteMode;ZWriteMode;2;1;[Toggle];Create;True;0;1;;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;283.0519,104.2823;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Hologram;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;True;24;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;118;0;117;1
WireConnection;118;1;117;2
WireConnection;118;2;117;3
WireConnection;103;0;102;2
WireConnection;103;1;104;0
WireConnection;103;2;105;0
WireConnection;121;0;118;0
WireConnection;121;1;120;0
WireConnection;121;2;119;0
WireConnection;106;0;103;0
WireConnection;106;1;108;0
WireConnection;132;0;106;0
WireConnection;123;0;121;0
WireConnection;123;1;122;0
WireConnection;133;0;134;0
WireConnection;133;1;132;0
WireConnection;124;0;123;0
WireConnection;11;0;9;1
WireConnection;11;1;9;2
WireConnection;11;2;9;3
WireConnection;129;0;124;0
WireConnection;135;0;133;0
WireConnection;135;1;132;1
WireConnection;15;0;11;0
WireConnection;15;1;14;0
WireConnection;15;2;8;0
WireConnection;136;0;135;0
WireConnection;107;0;106;0
WireConnection;130;0;129;0
WireConnection;16;0;15;0
WireConnection;16;1;17;0
WireConnection;158;20;79;0
WireConnection;158;18;80;0
WireConnection;158;19;81;0
WireConnection;158;21;82;0
WireConnection;158;22;83;0
WireConnection;159;20;76;0
WireConnection;159;18;55;0
WireConnection;159;19;60;0
WireConnection;159;21;77;0
WireConnection;159;22;78;0
WireConnection;137;0;136;0
WireConnection;27;0;28;0
WireConnection;162;0;130;0
WireConnection;109;0;107;0
WireConnection;97;0;158;0
WireConnection;97;1;96;0
WireConnection;12;0;16;0
WireConnection;88;0;159;0
WireConnection;88;1;89;0
WireConnection;131;0;109;0
WireConnection;131;1;162;0
WireConnection;21;0;12;0
WireConnection;100;0;159;0
WireConnection;100;1;158;0
WireConnection;26;0;27;0
WireConnection;26;1;29;0
WireConnection;26;2;30;0
WireConnection;26;3;31;0
WireConnection;138;0;137;0
WireConnection;98;0;88;0
WireConnection;98;1;97;0
WireConnection;99;0;98;0
WireConnection;99;1;97;0
WireConnection;139;0;131;0
WireConnection;139;1;138;0
WireConnection;32;0;26;0
WireConnection;22;0;21;0
WireConnection;116;0;111;0
WireConnection;85;0;100;0
WireConnection;85;1;86;0
WireConnection;150;0;149;0
WireConnection;87;0;85;0
WireConnection;33;0;32;0
WireConnection;140;0;131;0
WireConnection;140;1;139;0
WireConnection;48;1;22;0
WireConnection;48;2;49;0
WireConnection;112;0;116;0
WireConnection;112;1;113;0
WireConnection;90;0;99;0
WireConnection;160;20;144;0
WireConnection;160;18;145;0
WireConnection;160;19;148;0
WireConnection;160;21;147;0
WireConnection;160;22;146;0
WireConnection;152;0;150;0
WireConnection;152;1;151;0
WireConnection;110;0;112;0
WireConnection;110;1;140;0
WireConnection;36;0;35;1
WireConnection;36;1;37;0
WireConnection;161;0;48;0
WireConnection;153;0;152;0
WireConnection;153;1;160;0
WireConnection;154;0;153;0
WireConnection;114;0;110;0
WireConnection;95;0;92;0
WireConnection;20;0;161;0
WireConnection;43;0;1;4
WireConnection;43;1;44;0
WireConnection;43;2;91;0
WireConnection;41;0;1;0
WireConnection;41;1;40;0
WireConnection;38;0;36;0
WireConnection;42;0;1;0
WireConnection;42;1;41;0
WireConnection;42;2;95;0
WireConnection;45;0;43;0
WireConnection;156;0;115;0
WireConnection;156;1;157;0
WireConnection;5;0;23;0
WireConnection;5;1;42;0
WireConnection;46;0;45;0
WireConnection;46;1;47;0
WireConnection;46;2;50;0
WireConnection;0;2;5;0
WireConnection;0;9;46;0
WireConnection;0;11;156;0
ASEEND*/
//CHKSM=8992FC1883FC4F57EFAFA0B4560C2F92C9575D5D