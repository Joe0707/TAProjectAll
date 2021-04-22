// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Teleport_Body"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.05
		_NormalMap("NormalMap", 2D) = "bump" {}
		_BaseMap("BaseMap", 2D) = "white" {}
		_CompMask("CompMask", 2D) = "white" {}
		_MetallicAdjust("MetallicAdjust", Range( -1 , 1)) = 0
		_SmoothnessAdjust("SmoothnessAdjust", Range( -1 , 1)) = 0
		_DissolveAmount1("DissolveAmount", Float) = 0
		_DissolveOffset("DissolveOffset", Float) = 0
		_DissolveSpread("DissolveSpread", Float) = 1
		_NoiseScale("NoiseScale", Vector) = (1,1,1,0)
		_EdgeOffset("EdgeOffset", Float) = 0
		[HDR]_EdgeEmissColor("EdgeEmissColor", Color) = (0,0.7119167,0.7426471,0)
		_VertexEffectOffset("VertexEffectOffset", Float) = 0
		_VertexEffectSpread("VertexEffectSpread", Float) = 1
		_VertexOffsetIntensity("VertexOffsetIntensity", Float) = 5
		_VertexOffsetNoise("VertexOffsetNoise", Vector) = (10,10,10,0)
		_RimIntensity("RimIntensity", Float) = 1
		[HDR]_RimColor("RimColor", Color) = (0,0,0,0)
		_RimControl("RimControl", Range( 0 , 1)) = 0
		_EmissTex("EmissTex", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
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
			float3 worldPos;
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

		uniform float _DissolveAmount1;
		uniform float _VertexEffectOffset;
		uniform float _VertexEffectSpread;
		uniform float _VertexOffsetIntensity;
		uniform float3 _VertexOffsetNoise;
		uniform float _DissolveOffset;
		uniform float _DissolveSpread;
		uniform float3 _NoiseScale;
		uniform sampler2D _BaseMap;
		uniform float4 _BaseMap_ST;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _MetallicAdjust;
		uniform sampler2D _CompMask;
		uniform float4 _CompMask_ST;
		uniform float _SmoothnessAdjust;
		uniform float _RimControl;
		uniform float _EdgeOffset;
		uniform float4 _EdgeEmissColor;
		uniform float _RimIntensity;
		uniform sampler2D _EmissTex;
		uniform float4 _EmissTex_ST;
		uniform float4 _RimColor;
		uniform float _Cutoff = 0.05;


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


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 objToWorld20 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float temp_output_19_0 = ( ase_worldPos.y - objToWorld20.y );
			float simplePerlin2D72 = snoise( ( ase_worldPos * _VertexOffsetNoise ).xy );
			simplePerlin2D72 = simplePerlin2D72*0.5 + 0.5;
			float3 worldToObj67 = mul( unity_WorldToObject, float4( ( ( max( ( ( ( temp_output_19_0 + _DissolveAmount1 ) - _VertexEffectOffset ) / _VertexEffectSpread ) , 0.0 ) * float3(0,1,0) * _VertexOffsetIntensity * simplePerlin2D72 ) + ase_worldPos ), 1 ) ).xyz;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 FinalVertexOffset70 = ( worldToObj67 - ase_vertex3Pos );
			v.vertex.xyz += FinalVertexOffset70;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld20 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float temp_output_19_0 = ( ase_worldPos.y - objToWorld20.y );
			float temp_output_25_0 = ( ( ( ( 1.0 - temp_output_19_0 ) - _DissolveAmount1 ) - _DissolveOffset ) / _DissolveSpread );
			float smoothstepResult50 = smoothstep( 0.8 , 1.0 , temp_output_25_0);
			float simplePerlin3D33 = snoise( ( ase_worldPos * _NoiseScale ) );
			simplePerlin3D33 = simplePerlin3D33*0.5 + 0.5;
			float clampResult27 = clamp( ( smoothstepResult50 + ( temp_output_25_0 - simplePerlin3D33 ) ) , 0.0 , 1.0 );
			float Disslove48 = clampResult27;
			SurfaceOutputStandard s1 = (SurfaceOutputStandard ) 0;
			float2 uv_BaseMap = i.uv_texcoord * _BaseMap_ST.xy + _BaseMap_ST.zw;
			float3 gammaToLinear13 = GammaToLinearSpace( tex2D( _BaseMap, uv_BaseMap ).rgb );
			s1.Albedo = gammaToLinear13;
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 tex2DNode4 = UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) );
			s1.Normal = WorldNormalVector( i , tex2DNode4 );
			s1.Emission = float3( 0,0,0 );
			float2 uv_CompMask = i.uv_texcoord * _CompMask_ST.xy + _CompMask_ST.zw;
			float4 tex2DNode5 = tex2D( _CompMask, uv_CompMask );
			float clampResult8 = clamp( ( _MetallicAdjust + tex2DNode5.r ) , 0.0 , 1.0 );
			s1.Metallic = clampResult8;
			float clampResult12 = clamp( ( ( 1.0 - tex2DNode5.g ) + _SmoothnessAdjust ) , 0.0 , 1.0 );
			s1.Smoothness = clampResult12;
			s1.Occlusion = 1.0;

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
			float3 linearToGamma14 = LinearToGammaSpace( surfResult1 );
			float3 PBRLighting15 = ( linearToGamma14 * _RimControl );
			float smoothstepResult41 = smoothstep( 0.0 , 1.0 , ( pow( ( 1.0 - distance( temp_output_25_0 , _EdgeOffset ) ) , 1.0 ) - simplePerlin3D33 ));
			float4 DissolveEdgeColor44 = ( smoothstepResult41 * _EdgeEmissColor );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult78 = dot( (WorldNormalVector( i , tex2DNode4 )) , ase_worldViewDir );
			float clampResult83 = clamp( ( ( 1.0 - (dotResult78*0.5 + 0.5) ) - (_RimControl*2.0 + -1.0) ) , 0.0 , 1.0 );
			float2 uv_EmissTex = i.uv_texcoord * _EmissTex_ST.xy + _EmissTex_ST.zw;
			float4 RimEmiss86 = ( _RimIntensity * ( clampResult83 + ( clampResult83 * tex2D( _EmissTex, uv_EmissTex ).r ) ) * _RimColor );
			c.rgb = ( float4( PBRLighting15 , 0.0 ) + DissolveEdgeColor44 + RimEmiss86 ).rgb;
			c.a = 1;
			clip( Disslove48 - _Cutoff );
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
7;29;1522;788;4683.063;-317.6755;3.427639;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;18;-7257.173,1345.486;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;20;-7274.971,1542.732;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;19;-6937.971,1437.732;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;76;-7169.306,2307.188;Inherit;False;2544.975;1079.057;VertexOffset;20;61;55;56;57;75;73;58;74;72;64;63;60;65;62;66;69;67;68;70;53;VertexOffset;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;17;-2651.347,-214.0692;Inherit;False;1666.223;976.0077;PBRLighting;15;5;11;9;7;10;3;6;8;13;4;12;1;14;15;92;PBRLighting;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-7119.306,2357.188;Inherit;False;Property;_DissolveAmount1;DissolveAmount;6;0;Create;True;0;0;False;0;False;0;-3.99;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;59;-6592.758,1453.623;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;52;-5975.018,1093.884;Inherit;False;3226.478;955.0532;Dissolve;23;21;24;26;23;25;38;34;37;36;35;39;33;40;47;41;43;32;50;42;51;44;27;48;Dissolve;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;96;-2548.74,1333.134;Inherit;False;2006.059;830.572;RimEmiss;16;77;79;78;80;89;81;90;91;83;93;95;94;85;87;84;86;RimEmiss;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;4;-2615.064,6.485949;Inherit;True;Property;_NormalMap;NormalMap;1;0;Create;True;0;0;False;0;False;-1;None;77b91526e481d164aa4fee6e8b5fc94c;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;79;-2498.74,1615.014;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;77;-2497.724,1390.957;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;24;-5285.15,1389.994;Inherit;False;Property;_DissolveOffset;DissolveOffset;7;0;Create;True;0;0;False;0;False;0;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;21;-5356.017,1253.13;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;78;-2235.174,1502.294;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-5094.009,1445.697;Inherit;False;Property;_DissolveSpread;DissolveSpread;8;0;Create;True;0;0;False;0;False;1;2.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;23;-5050.319,1309.168;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-4701.07,1616.162;Inherit;False;Property;_EdgeOffset;EdgeOffset;10;0;Create;True;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;80;-2051.174,1527.159;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-2167.244,1746.065;Inherit;False;Property;_RimControl;RimControl;18;0;Create;True;0;0;True;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-6781.497,2359.136;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;25;-4856.995,1345.212;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-6841.563,2495.502;Inherit;False;Property;_VertexEffectOffset;VertexEffectOffset;12;0;Create;True;0;0;False;0;False;0;-0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-2601.347,373.7442;Inherit;True;Property;_CompMask;CompMask;3;0;Create;True;0;0;False;0;False;-1;None;a7f745220fb33f946a159d308f6c7308;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;73;-6782.205,2954.216;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;90;-1849.965,1776.639;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;81;-1789.726,1552.356;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;57;-6531.623,2428.513;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;37;-4427.082,1548.736;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;34;-5420.223,1588.173;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;7;-2558.469,270.8368;Inherit;False;Property;_MetallicAdjust;MetallicAdjust;4;0;Create;True;0;0;False;0;False;0;0.5;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;9;-2230.145,531.7804;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;36;-5479.223,1824.173;Inherit;False;Property;_NoiseScale;NoiseScale;9;0;Create;True;0;0;False;0;False;1,1,1;200,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;11;-2382.056,646.9384;Inherit;False;Property;_SmoothnessAdjust;SmoothnessAdjust;5;0;Create;True;0;0;False;0;False;0;0.52;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;75;-6837.347,3202.245;Inherit;False;Property;_VertexOffsetNoise;VertexOffsetNoise;15;0;Create;True;0;0;False;0;False;10,10,10;10,10,10;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;56;-6575.313,2565.04;Inherit;False;Property;_VertexEffectSpread;VertexEffectSpread;13;0;Create;True;0;0;False;0;False;1;1.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;91;-1613.707,1639.604;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-2057.407,588.1343;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;6;-2197.067,397.0209;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-2254.648,-164.0692;Inherit;True;Property;_BaseMap;BaseMap;2;0;Create;True;0;0;False;0;False;-1;None;f7549f6cf82871c439168b7599da3968;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;58;-6338.298,2486.298;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-5194.223,1744.173;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;39;-4240.488,1574.714;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-6565.646,3107.345;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;93;-1653.547,1933.706;Inherit;True;Property;_EmissTex;EmissTex;19;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;83;-1443.659,1599.46;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;33;-4993.223,1654.173;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;72;-6388.604,3107.517;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;60;-6153.946,2560.271;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;63;-6247.387,2681.266;Inherit;False;Constant;_Vector0;Vector 0;14;0;Create;True;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;40;-4040.897,1594.426;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GammaToLinearNode;13;-1951.652,-159.1928;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-6354.348,2836.049;Inherit;False;Property;_VertexOffsetIntensity;VertexOffsetIntensity;14;0;Create;True;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;8;-2065.983,395.7957;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;12;-1927.548,533.0052;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;47;-3902.833,1724.53;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-1391.123,1793.996;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;65;-5748.475,2841.977;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-5814.328,2567.129;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomStandardSurface;1;-1753.586,-39.11021;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-1306.539,1383.134;Inherit;False;Property;_RimIntensity;RimIntensity;16;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;87;-1000.975,1807.525;Inherit;False;Property;_RimColor;RimColor;17;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0,2.870587,3,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;43;-3463.102,1841.937;Inherit;False;Property;_EdgeEmissColor;EdgeEmissColor;11;1;[HDR];Create;True;0;0;False;0;False;0,0.7119167,0.7426471,0;0,2.87586,3,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;94;-1233.072,1767.654;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LinearToGammaNode;14;-1505.694,35.3728;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;66;-5545.375,2695.976;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;50;-4692.592,1146.319;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.8;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;41;-3460.721,1643.929;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;32;-4620.661,1331.624;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;51;-4463.591,1245.319;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-3228.958,1738.183;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-1314.28,157.6865;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-1021.035,1538.135;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TransformPositionNode;67;-5349.975,2718.176;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;69;-5363.129,2973.089;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;-3021.538,1773.628;Inherit;False;DissolveEdgeColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;68;-5064.129,2859.089;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;27;-4232.21,1292.058;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;86;-785.6807,1560.03;Inherit;False;RimEmiss;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-1214.124,67.91432;Inherit;False;PBRLighting;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-311.2586,429.976;Inherit;False;86;RimEmiss;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;70;-4891.331,2737.48;Inherit;False;FinalVertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-313.8332,286.2124;Inherit;False;44;DissolveEdgeColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;16;-250.9651,159.1049;Inherit;False;15;PBRLighting;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-3853.721,1357.087;Inherit;False;Disslove;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;5.166809,256.2124;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;-0.2089386,131.3215;Inherit;False;48;Disslove;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;-16.10364,498.3816;Inherit;False;70;FinalVertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;254.2057,39.6809;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Teleport_Body;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.05;True;True;0;True;Opaque;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;19;0;18;2
WireConnection;19;1;20;2
WireConnection;59;0;19;0
WireConnection;77;0;4;0
WireConnection;21;0;59;0
WireConnection;21;1;53;0
WireConnection;78;0;77;0
WireConnection;78;1;79;0
WireConnection;23;0;21;0
WireConnection;23;1;24;0
WireConnection;80;0;78;0
WireConnection;61;0;19;0
WireConnection;61;1;53;0
WireConnection;25;0;23;0
WireConnection;25;1;26;0
WireConnection;90;0;89;0
WireConnection;81;0;80;0
WireConnection;57;0;61;0
WireConnection;57;1;55;0
WireConnection;37;0;25;0
WireConnection;37;1;38;0
WireConnection;9;0;5;2
WireConnection;91;0;81;0
WireConnection;91;1;90;0
WireConnection;10;0;9;0
WireConnection;10;1;11;0
WireConnection;6;0;7;0
WireConnection;6;1;5;1
WireConnection;58;0;57;0
WireConnection;58;1;56;0
WireConnection;35;0;34;0
WireConnection;35;1;36;0
WireConnection;39;0;37;0
WireConnection;74;0;73;0
WireConnection;74;1;75;0
WireConnection;83;0;91;0
WireConnection;33;0;35;0
WireConnection;72;0;74;0
WireConnection;60;0;58;0
WireConnection;40;0;39;0
WireConnection;13;0;3;0
WireConnection;8;0;6;0
WireConnection;12;0;10;0
WireConnection;47;0;40;0
WireConnection;47;1;33;0
WireConnection;95;0;83;0
WireConnection;95;1;93;1
WireConnection;62;0;60;0
WireConnection;62;1;63;0
WireConnection;62;2;64;0
WireConnection;62;3;72;0
WireConnection;1;0;13;0
WireConnection;1;1;4;0
WireConnection;1;3;8;0
WireConnection;1;4;12;0
WireConnection;94;0;83;0
WireConnection;94;1;95;0
WireConnection;14;0;1;0
WireConnection;66;0;62;0
WireConnection;66;1;65;0
WireConnection;50;0;25;0
WireConnection;41;0;47;0
WireConnection;32;0;25;0
WireConnection;32;1;33;0
WireConnection;51;0;50;0
WireConnection;51;1;32;0
WireConnection;42;0;41;0
WireConnection;42;1;43;0
WireConnection;92;0;14;0
WireConnection;92;1;89;0
WireConnection;84;0;85;0
WireConnection;84;1;94;0
WireConnection;84;2;87;0
WireConnection;67;0;66;0
WireConnection;44;0;42;0
WireConnection;68;0;67;0
WireConnection;68;1;69;0
WireConnection;27;0;51;0
WireConnection;86;0;84;0
WireConnection;15;0;92;0
WireConnection;70;0;68;0
WireConnection;48;0;27;0
WireConnection;45;0;16;0
WireConnection;45;1;46;0
WireConnection;45;2;88;0
WireConnection;0;10;49;0
WireConnection;0;13;45;0
WireConnection;0;11;71;0
ASEEND*/
//CHKSM=DC034B8849FC998447215A4903169F3BF6BD6AF4