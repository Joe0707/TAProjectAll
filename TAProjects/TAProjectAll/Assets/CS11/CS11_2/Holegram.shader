// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Holegram"
{
	Properties
	{
		[HDR]_MainColor("MainColor", Color) = (0,0,0,0)
		[Toggle]_ZWriteMode("ZWriteMode", Float) = 0
		_NormalMap("NormalMap", 2D) = "bump" {}
		_RimPower("RimPower", Float) = 2
		_RimScale("RimScale", Float) = 1
		_RimBias("RimBias", Float) = 0
		_WireFrame("WireFrame", 2D) = "white" {}
		_WireFrameIntensity("WireFrameIntensity", Float) = 1
		_FlickControl("FlickControl", Range( 0 , 1)) = 0
		_Alpha("Alpha", Range( 0 , 1)) = 1
		[HDR]_ScanlineColor("ScanlineColor", Color) = (0,0,0,0)
		_Line1Freq("Line 1 Freq", Float) = 2
		_Line1Speed("Line 1 Speed", Float) = 0
		_Line1Width("Line 1 Width", Float) = 0
		_Line1Hardness("Line 1 Hardness", Float) = 1
		_Line1Alpha("Line 1 Alpha", Float) = 0
		_Line2Speed("Line 2 Speed", Float) = 0
		_Line2Width("Line 2 Width", Float) = 0
		_Line2Hardness("Line 2 Hardness", Float) = 1
		_Line2Freq("Line 2 Freq", Float) = 2
		_Line2Alpha("Line 2 Alpha", Float) = 0
		_Scanline2("Scanline2", 2D) = "white" {}
		_Scanline1("Scanline1", 2D) = "white" {}
		_GlicthTex("GlicthTex", 2D) = "white" {}
		_GlicthWidth("GlicthWidth", Float) = 0
		_GlicthHardness("GlicthHardness", Float) = 1
		_GlicthSpeed("GlicthSpeed", Float) = 0
		_GlicthFreq("GlicthFreq", Float) = 2
		_ScanlineVertexOffset("ScanlineVertexOffset", Vector) = (0,0,0,0)
		_RandomTilling("RandomTilling", Float) = 3
		_RandomVertexOffset("RandomVertexOffset", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
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
		uniform float _GlicthFreq;
		uniform float _GlicthSpeed;
		uniform float _GlicthWidth;
		uniform float _GlicthHardness;
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
			float3 viewToObjDir115 = mul( UNITY_MATRIX_T_MV, float4( _RandomVertexOffset, 0 ) ).xyz;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float mulTime102 = _Time.y * -2.5;
			float mulTime105 = _Time.y * -2.0;
			float2 appendResult103 = (float2((ase_worldPos.y*_RandomTilling + mulTime102) , mulTime105));
			float simplePerlin2D104 = snoise( appendResult103 );
			simplePerlin2D104 = simplePerlin2D104*0.5 + 0.5;
			float3 objToWorld116 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime117 = _Time.y * -5.0;
			float mulTime120 = _Time.y * -1.0;
			float2 appendResult122 = (float2((( objToWorld116.x + objToWorld116.y + objToWorld116.z )*200.0 + mulTime117) , mulTime120));
			float simplePerlin2D123 = snoise( appendResult122 );
			simplePerlin2D123 = simplePerlin2D123*0.5 + 0.5;
			float clampResult130 = clamp( (simplePerlin2D123*2.0 + -1.0) , 0.0 , 1.0 );
			float temp_output_131_0 = ( (simplePerlin2D104*2.0 + -1.0) * clampResult130 );
			float2 break132 = appendResult103;
			float2 appendResult135 = (float2(( 20.0 * break132.x ) , break132.y));
			float simplePerlin2D136 = snoise( appendResult135 );
			simplePerlin2D136 = simplePerlin2D136*0.5 + 0.5;
			float clampResult138 = clamp( (simplePerlin2D136*2.0 + -1.0) , 0.0 , 1.0 );
			float3 GlitchVertexOffset111 = ( ( viewToObjDir115 * 0.01 ) * ( temp_output_131_0 + ( temp_output_131_0 * clampResult138 ) ) );
			float3 viewToObjDir151 = mul( UNITY_MATRIX_T_MV, float4( _ScanlineVertexOffset, 0 ) ).xyz;
			float3 objToWorld2_g20 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime7_g20 = _Time.y * _GlicthSpeed;
			float2 appendResult9_g20 = (float2(0.5 , (( ase_worldPos.y - objToWorld2_g20.y )*_GlicthFreq + mulTime7_g20)));
			float clampResult23_g20 = clamp( ( ( tex2Dlod( _GlicthTex, float4( appendResult9_g20, 0, 0.0) ).r - _GlicthWidth ) * _GlicthHardness ) , 0.0 , 1.0 );
			float3 ScanlineGlitch154 = ( ( viewToObjDir151 * 0.01 ) * clampResult23_g20 );
			v.vertex.xyz += ( GlitchVertexOffset111 + ScanlineGlitch154 );
			v.vertex.w = 1;
			float3 objToWorld8 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime7 = _Time.y * 15.0;
			float mulTime15 = _Time.y * 0.5;
			float2 appendResult14 = (float2((( objToWorld8.x + objToWorld8.y + objToWorld8.z )*200.0 + mulTime7) , mulTime15));
			float simplePerlin2D10 = snoise( appendResult14 );
			simplePerlin2D10 = simplePerlin2D10*0.5 + 0.5;
			float clampResult19 = clamp( (-0.5 + (simplePerlin2D10 - 0.0) * (2.0 - -0.5) / (1.0 - 0.0)) , 0.0 , 1.0 );
			float lerpResult44 = lerp( 1.0 , clampResult19 , _FlickControl);
			o.vertexToFrag161 = lerpResult44;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			float Flicking17 = i.vertexToFrag161;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float fresnelNdotV22 = dot( normalize( (WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) ) )) ), ase_worldViewDir );
			float fresnelNode22 = ( _RimBias + _RimScale * pow( max( 1.0 - fresnelNdotV22 , 0.0001 ), _RimPower ) );
			float FresnelFactor29 = max( fresnelNode22 , 0.0 );
			float3 objToWorld1_g19 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime6_g19 = _Time.y * _Line1Speed;
			float2 appendResult9_g19 = (float2(0.5 , (( ase_worldPos.y - objToWorld1_g19.y )*_Line1Freq + mulTime6_g19)));
			float clampResult22_g19 = clamp( ( ( tex2D( _Scanline1, appendResult9_g19 ).r - _Line1Width ) * _Line1Hardness ) , 0.0 , 1.0 );
			float temp_output_160_0 = clampResult22_g19;
			float3 objToWorld1_g18 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime6_g18 = _Time.y * _Line2Speed;
			float2 appendResult9_g18 = (float2(0.5 , (( ase_worldPos.y - objToWorld1_g18.y )*_Line2Freq + mulTime6_g18)));
			float clampResult22_g18 = clamp( ( ( tex2D( _Scanline2, appendResult9_g18 ).r - _Line2Width ) * _Line2Hardness ) , 0.0 , 1.0 );
			float temp_output_159_0 = clampResult22_g18;
			float4 ScanlineColor85 = ( ( temp_output_160_0 * temp_output_159_0 ) * _ScanlineColor );
			o.Emission = ( Flicking17 * ( _MainColor + ( _MainColor * FresnelFactor29 ) + max( ScanlineColor85 , float4( 0,0,0,0 ) ) ) ).rgb;
			float temp_output_92_0 = ( temp_output_159_0 * _Line2Alpha );
			float ScanlineAlpha88 = ( ( ( temp_output_160_0 * _Line1Alpha ) * temp_output_92_0 ) + temp_output_92_0 );
			float clampResult41 = clamp( ( _MainColor.a + FresnelFactor29 + ScanlineAlpha88 ) , 0.0 , 1.0 );
			float2 uv_WireFrame = i.uv_texcoord * _WireFrame_ST.xy + _WireFrame_ST.zw;
			float WireFrame34 = ( tex2D( _WireFrame, uv_WireFrame ).r * _WireFrameIntensity );
			o.Alpha = ( clampResult41 * WireFrame34 * _Alpha );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
7;29;1522;788;2062.635;-3573.696;1.420941;True;False
Node;AmplifyShaderEditor.CommentaryNode;141;-2995.785,3027.287;Inherit;False;3100.969;1493.713;GlicthVertexOffset;35;101;99;102;100;105;116;119;103;118;117;120;121;134;132;133;122;135;123;136;129;104;130;106;137;131;138;108;110;139;115;140;109;107;111;162;RandomGlicth;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;99;-2928.247,3077.287;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;102;-2909.357,3387.873;Inherit;False;1;0;FLOAT;-2.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-2945.785,3282.459;Inherit;False;Property;_RandomTilling;RandomTilling;30;0;Create;True;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;100;-2695.908,3203.377;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;105;-2659.366,3378.867;Inherit;False;1;0;FLOAT;-2;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;103;-2428.357,3164.873;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TransformPositionNode;116;-2736.191,3547.304;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;132;-2304.774,4104.756;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;134;-2195.671,4015.196;Inherit;False;Constant;_Float1;Float 1;26;0;Create;True;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;119;-2494.191,3568.304;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;117;-2598.191,3840.304;Inherit;False;1;0;FLOAT;-5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;16;-2451.642,-125.4233;Inherit;False;1756.878;591.9169;Flcking;14;17;18;10;14;15;13;7;9;12;8;19;44;45;161;Flcking;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-2598.191,3715.304;Inherit;False;Constant;_Tilling1;Tilling;2;0;Create;True;0;0;False;0;False;200;200;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-1998.635,4083.589;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;120;-2289.191,3867.304;Inherit;False;1;0;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;8;-2401.642,-75.42335;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;121;-2331.191,3573.304;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;98;-2925.649,1219.31;Inherit;False;2061.876;1469.073;Scanline;21;79;80;81;73;74;52;57;78;82;72;86;93;87;92;97;94;84;95;83;85;88;Scanline;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;135;-1813.23,4126.613;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;122;-2104.826,3596.316;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-2263.642,92.57666;Inherit;False;Constant;_Tilling;Tilling;2;0;Create;True;0;0;False;0;False;200;200;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;7;-2263.642,217.5767;Inherit;False;1;0;FLOAT;15;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;9;-2159.642,-54.42334;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;82;-2662.156,2117.476;Inherit;True;Property;_Scanline2;Scanline2;22;0;Create;True;0;0;False;0;False;None;4bbf045a9f687084ea4bc84d53c39623;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;79;-2647.23,2446.383;Inherit;False;Property;_Line2Hardness;Line 2 Hardness;19;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-2875.649,2296.548;Inherit;False;Property;_Line2Speed;Line 2 Speed;17;0;Create;True;0;0;False;0;False;0;-3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-2681.18,1543.475;Inherit;False;Property;_Line1Freq;Line 1 Freq;12;0;Create;True;0;0;False;0;False;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;136;-1540.647,4157.121;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-2616.23,2573.383;Inherit;False;Property;_Line2Width;Line 2 Width;18;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-2451.459,1725.217;Inherit;False;Property;_Line1Width;Line 1 Width;14;0;Create;True;0;0;False;0;False;0;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-2845.951,2391.641;Inherit;False;Property;_Line2Freq;Line 2 Freq;20;0;Create;True;0;0;False;0;False;2;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-2710.878,1448.382;Inherit;False;Property;_Line1Speed;Line 1 Speed;13;0;Create;True;0;0;False;0;False;0;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-2482.459,1598.217;Inherit;False;Property;_Line1Hardness;Line 1 Hardness;15;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;72;-2497.385,1269.31;Inherit;True;Property;_Scanline1;Scanline1;23;0;Create;True;0;0;False;0;False;None;afb16754b93daf04187b10b438f7a250;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.NoiseGeneratorNode;123;-1967.568,3618.057;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;30;-2914.53,537.6409;Inherit;False;1480;485;Fresnel;8;24;25;27;23;26;22;28;29;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;13;-1996.642,-49.42335;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;15;-1954.642,244.5767;Inherit;False;1;0;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-1994.152,2021.901;Inherit;False;Property;_Line1Alpha;Line 1 Alpha;16;0;Create;True;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;24;-2864.53,587.6409;Inherit;True;Property;_NormalMap;NormalMap;3;0;Create;True;0;0;False;0;False;-1;None;fc1b48efdc94a08459a77ba560e287f7;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;137;-1249.467,4201.35;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;160;-2153.704,1402.382;Inherit;False;Scanline;-1;;19;286f607daedd2a74f8f8429a6f23fc0a;0;6;15;FLOAT;0;False;19;SAMPLER2D;0;False;18;FLOAT;1;False;17;FLOAT;2;False;21;FLOAT;1;False;20;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;159;-2318.475,2250.548;Inherit;False;Scanline;-1;;18;286f607daedd2a74f8f8429a6f23fc0a;0;6;15;FLOAT;0;False;19;SAMPLER2D;0;False;18;FLOAT;1;False;17;FLOAT;2;False;21;FLOAT;1;False;20;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;129;-1693.766,3667.24;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-1978.042,2347.106;Inherit;False;Property;_Line2Alpha;Line 2 Alpha;21;0;Create;True;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;104;-2214.357,3179.873;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;14;-1770.277,-26.41148;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2518.53,817.6409;Inherit;False;Property;_RimScale;RimScale;5;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;23;-2438.531,609.6409;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;25;-2560.53,732.6409;Inherit;False;Property;_RimBias;RimBias;6;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;138;-967.786,4249.528;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2459.531,907.6409;Inherit;False;Property;_RimPower;RimPower;4;0;Create;True;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;130;-1475.766,3710.24;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;106;-1903.367,3289.867;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-1754.324,1988.639;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;10;-1633.018,-4.670631;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-1772.01,2254.444;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;155;-654.8555,1947.828;Inherit;False;1439.854;963.3514;ScanlineOffset;12;150;151;154;149;142;152;153;144;147;148;145;146;ScanlineOffset;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-1554.534,2123.45;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-1719.095,1405.41;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;162;-731.2135,4309.744;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;-1338.705,3439.902;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;108;-1245.603,3097.901;Inherit;False;Property;_RandomVertexOffset;RandomVertexOffset;31;0;Create;True;0;0;False;0;False;0,0,0;-3,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;84;-1735.396,1556.249;Inherit;False;Property;_ScanlineColor;ScanlineColor;11;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0,0.2156863,1,0.04313726;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;18;-1404.184,144.2424;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.5;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;22;-2125.086,649.485;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;149;-373.7462,1997.828;Inherit;False;Property;_ScanlineVertexOffset;ScanlineVertexOffset;29;0;Create;True;0;0;False;0;False;0,0,0;-2.5,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;146;-541.1345,2720.179;Inherit;False;Property;_GlicthWidth;GlicthWidth;25;0;Create;True;0;0;False;0;False;0;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-503.1345,2796.179;Inherit;False;Property;_GlicthHardness;GlicthHardness;26;0;Create;True;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-961.1365,3358.749;Inherit;False;Constant;_Float0;Float 0;26;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;35;-1384.513,591.9983;Inherit;False;867.2646;379.2349;WireFrame;4;34;31;33;32;WireFrame;1,1,1,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;19;-1206.998,192.2067;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-645.6473,3758.466;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-89.27958,2258.676;Inherit;False;Constant;_Float2;Float 0;26;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;115;-1001.013,3115.391;Inherit;False;View;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;147;-604.8555,2555.438;Inherit;False;Property;_GlicthFreq;GlicthFreq;28;0;Create;True;0;0;False;0;False;2;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;95;-1316.337,2159.292;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;144;-586.6027,2333.235;Inherit;True;Property;_GlicthTex;GlicthTex;24;0;Create;True;0;0;False;0;False;None;afb16754b93daf04187b10b438f7a250;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;45;-1397.161,359.9866;Inherit;False;Property;_FlickControl;FlickControl;9;0;Create;True;0;0;False;0;False;0;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;28;-1853.532,690.6409;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-1511.709,1416.167;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;148;-595.5535,2636.344;Inherit;False;Property;_GlicthSpeed;GlicthSpeed;27;0;Create;True;0;0;False;0;False;0;-0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;151;-129.1561,2015.318;Inherit;False;View;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;31;-1334.513,641.9984;Inherit;True;Property;_WireFrame;WireFrame;7;0;Create;True;0;0;False;0;False;-1;None;92f284b27dea88e41885444624ec2963;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;130.1978,2130.794;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;142;-143.843,2412.169;Inherit;True;Scanline;-1;;20;41d3502ec500f8841bf8ae0f314f26cf;0;6;20;SAMPLER2D;0;False;16;FLOAT;0;False;18;FLOAT;2;False;19;FLOAT;1;False;21;FLOAT;0;False;22;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;88;-1107.773,2146.392;Inherit;False;ScanlineAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;140;-564.6893,3553.131;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;-1216.529,1533.732;Inherit;False;ScanlineColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;44;-1053.953,192.4439;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-1677.532,734.6409;Inherit;False;FresnelFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-741.6591,3230.867;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-1300.045,856.2332;Inherit;False;Property;_WireFrameIntensity;WireFrameIntensity;8;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-570.3595,375.0629;Inherit;False;29;FresnelFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;-363.3762,3346.439;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-243.0827,294.2723;Inherit;False;85;ScanlineColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexToFragmentNode;161;-902.1802,166.5184;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-973.325,758.9822;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;-611.1353,62.13282;Inherit;False;Property;_MainColor;MainColor;1;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0,3.57013,16.699,0.042;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;36;-381.0447,167.3811;Inherit;False;29;FresnelFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;330.4039,2315.154;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-538.4795,451.337;Inherit;False;88;ScanlineAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-198.5216,103.5181;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;-281.6801,371.7013;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;-166.8164,3384.51;Inherit;False;GlitchVertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-760.2481,796.1341;Inherit;False;WireFrame;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;-896.1511,323.075;Inherit;True;Flicking;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;154;540.9985,2350.123;Inherit;False;ScanlineGlitch;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;91;-6.921753,345.695;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;229.0512,518.9487;Inherit;False;111;GlitchVertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-169.0668,-63.7229;Inherit;False;17;Flicking;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;225.9836,666.4054;Inherit;False;154;ScanlineGlitch;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;38;-3.792804,25.48196;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-246.7533,568.1572;Inherit;False;34;WireFrame;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;41;-144.106,427.5097;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-360.1717,666.0945;Inherit;False;Property;_Alpha;Alpha;10;0;Create;True;0;0;False;0;False;1;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-922.478,-523.1979;Inherit;False;Property;_ZWriteMode;ZWriteMode;2;1;[Toggle];Create;True;0;1;;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;101.1023,-54.44732;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;156;488.9836,593.4054;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;39.34275,483.6143;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;567.6025,5.55265;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Holegram;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;True;21;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;100;0;99;2
WireConnection;100;1;101;0
WireConnection;100;2;102;0
WireConnection;103;0;100;0
WireConnection;103;1;105;0
WireConnection;132;0;103;0
WireConnection;119;0;116;1
WireConnection;119;1;116;2
WireConnection;119;2;116;3
WireConnection;133;0;134;0
WireConnection;133;1;132;0
WireConnection;121;0;119;0
WireConnection;121;1;118;0
WireConnection;121;2;117;0
WireConnection;135;0;133;0
WireConnection;135;1;132;1
WireConnection;122;0;121;0
WireConnection;122;1;120;0
WireConnection;9;0;8;1
WireConnection;9;1;8;2
WireConnection;9;2;8;3
WireConnection;136;0;135;0
WireConnection;123;0;122;0
WireConnection;13;0;9;0
WireConnection;13;1;12;0
WireConnection;13;2;7;0
WireConnection;137;0;136;0
WireConnection;160;19;72;0
WireConnection;160;18;57;0
WireConnection;160;17;52;0
WireConnection;160;21;74;0
WireConnection;160;20;73;0
WireConnection;159;19;82;0
WireConnection;159;18;80;0
WireConnection;159;17;81;0
WireConnection;159;21;79;0
WireConnection;159;20;78;0
WireConnection;129;0;123;0
WireConnection;104;0;103;0
WireConnection;14;0;13;0
WireConnection;14;1;15;0
WireConnection;23;0;24;0
WireConnection;138;0;137;0
WireConnection;130;0;129;0
WireConnection;106;0;104;0
WireConnection;87;0;160;0
WireConnection;87;1;86;0
WireConnection;10;0;14;0
WireConnection;92;0;159;0
WireConnection;92;1;93;0
WireConnection;94;0;87;0
WireConnection;94;1;92;0
WireConnection;97;0;160;0
WireConnection;97;1;159;0
WireConnection;162;0;138;0
WireConnection;131;0;106;0
WireConnection;131;1;130;0
WireConnection;18;0;10;0
WireConnection;22;0;23;0
WireConnection;22;1;25;0
WireConnection;22;2;26;0
WireConnection;22;3;27;0
WireConnection;19;0;18;0
WireConnection;139;0;131;0
WireConnection;139;1;162;0
WireConnection;115;0;108;0
WireConnection;95;0;94;0
WireConnection;95;1;92;0
WireConnection;28;0;22;0
WireConnection;83;0;97;0
WireConnection;83;1;84;0
WireConnection;151;0;149;0
WireConnection;152;0;151;0
WireConnection;152;1;150;0
WireConnection;142;20;144;0
WireConnection;142;18;147;0
WireConnection;142;19;148;0
WireConnection;142;21;146;0
WireConnection;142;22;145;0
WireConnection;88;0;95;0
WireConnection;140;0;131;0
WireConnection;140;1;139;0
WireConnection;85;0;83;0
WireConnection;44;1;19;0
WireConnection;44;2;45;0
WireConnection;29;0;28;0
WireConnection;109;0;115;0
WireConnection;109;1;110;0
WireConnection;107;0;109;0
WireConnection;107;1;140;0
WireConnection;161;0;44;0
WireConnection;32;0;31;1
WireConnection;32;1;33;0
WireConnection;153;0;152;0
WireConnection;153;1;142;0
WireConnection;37;0;1;0
WireConnection;37;1;36;0
WireConnection;40;0;1;4
WireConnection;40;1;39;0
WireConnection;40;2;89;0
WireConnection;111;0;107;0
WireConnection;34;0;32;0
WireConnection;17;0;161;0
WireConnection;154;0;153;0
WireConnection;91;0;90;0
WireConnection;38;0;1;0
WireConnection;38;1;37;0
WireConnection;38;2;91;0
WireConnection;41;0;40;0
WireConnection;4;0;20;0
WireConnection;4;1;38;0
WireConnection;156;0;112;0
WireConnection;156;1;157;0
WireConnection;42;0;41;0
WireConnection;42;1;43;0
WireConnection;42;2;46;0
WireConnection;0;2;4;0
WireConnection;0;9;42;0
WireConnection;0;11;156;0
ASEEND*/
//CHKSM=B3D904271DB984AFEF92873EC69B43B19D0177A1