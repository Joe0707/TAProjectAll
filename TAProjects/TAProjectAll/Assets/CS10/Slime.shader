// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Slime"
{
	Properties
	{
		_Matcap("Matcap", 2D) = "white" {}
		_BaseMap("BaseMap", 2D) = "white" {}
		_Contrast("Contrast", Float) = 5
		_EmissTex("EmissTex", 2D) = "white" {}
		_RimPower("RimPower", Float) = 1
		_RimScale("RimScale", Float) = 1
		_RimBias("RimBias", Float) = 0
		_RimColor("RimColor", Color) = (1,1,1,1)
		_NormalMap("NormalMap", 2D) = "bump" {}
		_SlimeTilling("SlimeTilling", Vector) = (1,1,1,0)
		_VertexNoiseTilling("VertexNoiseTilling", Vector) = (1,1,1,0)
		_SlimeNormal("SlimeNormal", 2D) = "white" {}
		_VertexNoiseSpeed("VertexNoiseSpeed", Vector) = (0,0.3,-0.2,0)
		_NoiseSpeed("NoiseSpeed", Vector) = (0,0,0,0)
		_VertexAnimNoise("VertexAnimNoise", 2D) = "white" {}
		_VertexAnimIntensity("VertexAnimIntensity", Float) = 5
		_VertexBias("VertexBias", Vector) = (0,-0.2,0,0)
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
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _VertexAnimNoise;
		uniform float3 _VertexNoiseTilling;
		uniform float3 _VertexNoiseSpeed;
		uniform float3 _VertexBias;
		uniform float _VertexAnimIntensity;
		uniform sampler2D _BaseMap;
		uniform float4 _BaseMap_ST;
		uniform sampler2D _Matcap;
		uniform sampler2D _SlimeNormal;
		uniform float _Contrast;
		uniform float3 _SlimeTilling;
		uniform float3 _NoiseSpeed;
		uniform sampler2D _EmissTex;
		uniform float4 _EmissTex_ST;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _RimBias;
		uniform float _RimScale;
		uniform float _RimPower;
		uniform float4 _RimColor;


		inline float4 TriplanarSampling95( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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


		inline float3 TriplanarSampling92( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			xNorm.xyz  = half3( UnpackNormal( xNorm ).xy * float2(  nsign.x, 1.0 ) + worldNormal.zy, worldNormal.x ).zyx;
			yNorm.xyz  = half3( UnpackNormal( yNorm ).xy * float2(  nsign.y, 1.0 ) + worldNormal.xz, worldNormal.y ).xzy;
			zNorm.xyz  = half3( UnpackNormal( zNorm ).xy * float2( -nsign.z, 1.0 ) + worldNormal.xy, worldNormal.z ).xyz;
			return normalize( xNorm.xyz * projNormal.x + yNorm.xyz * projNormal.y + zNorm.xyz * projNormal.z );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float3 objToWorld97 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float4 triplanar95 = TriplanarSampling95( _VertexAnimNoise, ( ( ( ase_worldPos - objToWorld97 ) * _VertexNoiseTilling ) + ( _Time.y * _VertexNoiseSpeed ) ), ase_worldNormal, 5.0, float2( 1,1 ), 1.0, 0 );
			float4 VertexNoise106 = triplanar95;
			float dotResult121 = dot( ase_worldNormal , _VertexBias );
			float clampResult122 = clamp( dotResult121 , 0.0 , 1.0 );
			float3 worldToObj127 = mul( unity_WorldToObject, float4( ( ( ( VertexNoise106 * float4( ( ase_worldNormal + _VertexBias ) , 0.0 ) * ( clampResult122 + 1.0 ) * v.color.r ) * _VertexAnimIntensity * 0.01 ) + float4( ase_worldPos , 0.0 ) ).xyz, 1 ) ).xyz;
			float3 FinalVertexPosition113 = worldToObj127;
			v.vertex.xyz = FinalVertexPosition113;
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_BaseMap = i.uv_texcoord * _BaseMap_ST.xy + _BaseMap_ST.zw;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 objToWorld57 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float3 temp_output_88_0 = ( ( ( ase_worldPos - objToWorld57 ) * _SlimeTilling ) + ( _Time.y * _NoiseSpeed ) );
			float3 triplanar92 = TriplanarSampling92( _SlimeNormal, temp_output_88_0, ase_worldNormal, _Contrast, float2( 1,1 ), 1.0, 0 );
			float4 MatcapColor22 = tex2D( _Matcap, ((mul( UNITY_MATRIX_V, float4( triplanar92 , 0.0 ) ).xyz).xy*0.5 + 0.5) );
			float2 uv_EmissTex = i.uv_texcoord * _EmissTex_ST.xy + _EmissTex_ST.zw;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float fresnelNdotV11 = dot( (WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) ) )), ase_worldViewDir );
			float fresnelNode11 = ( _RimBias + _RimScale * pow( max( 1.0 - fresnelNdotV11 , 0.0001 ), _RimPower ) );
			float4 RimColor24 = ( tex2D( _EmissTex, uv_EmissTex ) * ( fresnelNode11 * _RimColor ) );
			o.Emission = ( ( tex2D( _BaseMap, uv_BaseMap ) * MatcapColor22 ) + RimColor24 ).rgb;
			o.Alpha = 1;
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
-1529;29;1522;788;5184.72;633.0676;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;107;-2250.509,1178.352;Inherit;False;1682.421;866.3904;VertexNoise;12;106;96;97;98;99;105;94;95;102;100;103;101;VertexNoise;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;93;-4861.518,-816.9767;Inherit;False;1560.942;888.0078;TriPlanarNormalMap1;12;57;55;58;78;89;90;91;87;54;51;88;92;TriPlanarNormalMap1;1,1,1,1;0;0
Node;AmplifyShaderEditor.TransformPositionNode;97;-2200.509,1551.991;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;55;-4783.517,-583.7209;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;57;-4811.518,-421.7211;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;96;-2172.508,1389.991;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;100;-1965.935,1608.713;Inherit;False;Property;_VertexNoiseTilling;VertexNoiseTilling;10;0;Create;True;0;0;False;0;False;1,1,1;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;101;-2186.5,1860.743;Inherit;False;Property;_VertexNoiseSpeed;VertexNoiseSpeed;12;0;Create;True;0;0;False;0;False;0,0.3,-0.2;0,0.3,-0.2;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;78;-4605.232,-338.1987;Inherit;False;Property;_SlimeTilling;SlimeTilling;9;0;Create;True;0;0;False;0;False;1,1,1;1,1,2;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;99;-2179.444,1777.226;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;90;-4797.509,-112.9693;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;13;0;Create;True;0;0;False;0;False;0,0,0;0,0.3,-0.2;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;89;-4790.453,-196.4863;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;98;-1932.509,1432.991;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;58;-4543.517,-540.7209;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-4534.231,-137.746;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-2000.648,1841.922;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-1783.535,1529.282;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-4394.543,-444.4301;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;117;-2263.485,2178.912;Inherit;False;2544.284;679.7493;VertexAnimation;17;113;112;111;115;109;110;118;123;116;122;124;121;108;119;125;126;127;VertexAnimation;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;-4368.166,-271.7693;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;51;-4447.451,-766.9768;Inherit;True;Property;_SlimeNormal;SlimeNormal;11;0;Create;True;0;0;False;0;False;None;9d5e7418195c7f641baa981f14baf621;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;105;-1675.792,1647.231;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-4253.249,-162.1144;Inherit;False;Property;_Contrast;Contrast;2;0;Create;True;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;21;-3242.61,-563.3336;Inherit;False;1899.812;446.7372;MatcapColor;6;22;1;6;5;3;4;MatcapColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;94;-1623.813,1228.352;Inherit;True;Property;_VertexAnimNoise;VertexAnimNoise;14;0;Create;True;0;0;False;0;False;None;7d534315937abbc4aa085902bc92f9ec;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.WorldNormalVector;108;-2195.104,2327.443;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;119;-2179.084,2492.501;Inherit;False;Property;_VertexBias;VertexBias;16;0;Create;True;0;0;False;0;False;0,-0.2,0;0,-0.2,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TriplanarNode;92;-4023.576,-445.0061;Inherit;True;Spherical;World;True;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;World;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;23;-3095.049,203.7805;Inherit;False;2083.963;838.163;RimColor;12;19;9;17;18;11;12;13;16;15;14;20;24;RimColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewMatrixNode;4;-2859.272,-513.3335;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.TriplanarNode;95;-1276.772,1365.826;Inherit;True;Spherical;World;False;Top Texture 1;_TopTexture1;white;-1;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;5;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;121;-1911.411,2493.703;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;122;-1779.363,2428.334;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;20;-3045.049,253.7805;Inherit;True;Property;_NormalMap;NormalMap;8;0;Create;True;0;0;False;0;False;-1;None;d8a5f76ae71b01242a5880ec829d0206;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-2711.23,-453.5417;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;-811.0883,1382.725;Inherit;False;VertexNoise;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-1801.589,2624.443;Inherit;False;Constant;_Float1;Float 1;17;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;116;-1613.919,2645.24;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;16;-2353.626,926.9434;Inherit;False;Property;_RimPower;RimPower;4;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;5;-2541.272,-439.3336;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-2456.81,746.373;Inherit;False;Property;_RimBias;RimBias;6;0;Create;True;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;13;-2613.794,577.7247;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;15;-2412.957,837.9478;Inherit;False;Property;_RimScale;RimScale;5;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;12;-2566.073,404.8934;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;123;-1642.085,2539.462;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;118;-1912.255,2362.302;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;-1714.813,2235.341;Inherit;False;106;VertexNoise;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;6;-2381.71,-407.9442;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;11;-2063.348,533.2449;Inherit;False;Standard;WorldNormal;ViewDir;False;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;18;-1987.384,739.0162;Inherit;False;Property;_RimColor;RimColor;7;0;Create;True;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;111;-1354.464,2457.117;Inherit;False;Property;_VertexAnimIntensity;VertexAnimIntensity;15;0;Create;True;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-1338.834,2562.953;Inherit;False;Constant;_Float0;Float 0;16;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-1443.318,2309.285;Inherit;False;4;4;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;1;-2153.226,-444.0649;Inherit;True;Property;_Matcap;Matcap;0;0;Create;True;0;0;False;0;False;-1;None;e66ff971217fd9b41bec579c2a0eac0b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;9;-2170.379,294.0673;Inherit;True;Property;_EmissTex;EmissTex;3;0;Create;True;0;0;False;0;False;-1;None;cd03d8d8d2294f941a24771282b1ccd6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;-1101.819,2382.01;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-1704.629,612.2362;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;126;-1088.963,2667.601;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-1829.254,-427.98;Inherit;False;MatcapColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;125;-867.1632,2535.159;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-1572.417,455.5884;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-190.1353,62.24951;Inherit;False;22;MatcapColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;7;-257.2879,-209.3346;Inherit;True;Property;_BaseMap;BaseMap;1;0;Create;True;0;0;False;0;False;-1;None;d5e0dc36f0b94a049b1763710d08ba0d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-1388.378,500.5508;Inherit;False;RimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TransformPositionNode;127;-693.2338,2522.393;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;81;-6910.621,1337.569;Inherit;False;3927.225;1957.164;TriPlanarNormalMap;24;48;46;43;44;42;80;79;77;74;75;76;72;70;71;73;68;64;60;62;61;59;56;53;52;TriPlanarNormalMap;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-32.13916,220.2457;Inherit;False;24;RimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;84.09602,-59.65095;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;113;-398.7953,2446.499;Inherit;False;FinalVertexPosition;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.AbsOpNode;53;-6054.6,1452.894;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;52;-6264.457,1387.569;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-4761.688,2017.692;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;72;-5144.313,1497.226;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;114;438.9719,343.6246;Inherit;False;113;FinalVertexPosition;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;59;-5662.013,1645.992;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SwizzleNode;64;-6131.421,1979.037;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;60;-6124.667,2241.071;Inherit;False;FLOAT2;1;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-3877.228,1771.405;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;61;-6118.026,2396.485;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-3886.895,1892.427;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;79;-4306.676,1997.28;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;68;-5322.903,1500.895;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;80;-4213.693,1861.332;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;62;-5388.689,1637.815;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;48;-3567.287,1816.225;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;56;-5831.864,1497.31;Inherit;False;True;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-4477.888,1965.092;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;71;-5759.978,2159.659;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;70;-5754.929,1862.524;Inherit;True;Property;_TextureSample2;Texture Sample 2;11;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;46;-3720.895,1803.427;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-4787.181,2292.646;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;307.9322,113.1356;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-4802.089,1836.592;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;73;-5778.788,2466.135;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;42;-4145.068,1682.82;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;706.5997,89.77197;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Slime;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;98;0;96;0
WireConnection;98;1;97;0
WireConnection;58;0;55;0
WireConnection;58;1;57;0
WireConnection;91;0;89;0
WireConnection;91;1;90;0
WireConnection;103;0;99;0
WireConnection;103;1;101;0
WireConnection;102;0;98;0
WireConnection;102;1;100;0
WireConnection;87;0;58;0
WireConnection;87;1;78;0
WireConnection;88;0;87;0
WireConnection;88;1;91;0
WireConnection;105;0;102;0
WireConnection;105;1;103;0
WireConnection;92;0;51;0
WireConnection;92;9;88;0
WireConnection;92;4;54;0
WireConnection;95;0;94;0
WireConnection;95;9;105;0
WireConnection;121;0;108;0
WireConnection;121;1;119;0
WireConnection;122;0;121;0
WireConnection;3;0;4;0
WireConnection;3;1;92;0
WireConnection;106;0;95;0
WireConnection;5;0;3;0
WireConnection;12;0;20;0
WireConnection;123;0;122;0
WireConnection;123;1;124;0
WireConnection;118;0;108;0
WireConnection;118;1;119;0
WireConnection;6;0;5;0
WireConnection;11;0;12;0
WireConnection;11;4;13;0
WireConnection;11;1;14;0
WireConnection;11;2;15;0
WireConnection;11;3;16;0
WireConnection;109;0;110;0
WireConnection;109;1;118;0
WireConnection;109;2;123;0
WireConnection;109;3;116;1
WireConnection;1;1;6;0
WireConnection;112;0;109;0
WireConnection;112;1;111;0
WireConnection;112;2;115;0
WireConnection;17;0;11;0
WireConnection;17;1;18;0
WireConnection;22;0;1;0
WireConnection;125;0;112;0
WireConnection;125;1;126;0
WireConnection;19;0;9;0
WireConnection;19;1;17;0
WireConnection;24;0;19;0
WireConnection;127;0;125;0
WireConnection;8;0;7;0
WireConnection;8;1;25;0
WireConnection;113;0;127;0
WireConnection;53;0;52;0
WireConnection;76;0;72;0
WireConnection;76;1;71;0
WireConnection;72;0;68;0
WireConnection;59;0;56;0
WireConnection;64;0;88;0
WireConnection;60;0;88;0
WireConnection;43;0;42;1
WireConnection;43;1;80;0
WireConnection;61;0;88;0
WireConnection;44;0;42;2
WireConnection;44;1;80;1
WireConnection;79;0;77;0
WireConnection;68;0;56;0
WireConnection;68;1;62;0
WireConnection;80;0;79;0
WireConnection;62;0;59;0
WireConnection;62;1;59;1
WireConnection;62;2;59;2
WireConnection;48;0;46;0
WireConnection;56;0;53;0
WireConnection;56;1;54;0
WireConnection;77;0;75;0
WireConnection;77;1;76;0
WireConnection;77;2;74;0
WireConnection;71;0;51;0
WireConnection;71;1;60;0
WireConnection;70;0;51;0
WireConnection;70;1;64;0
WireConnection;46;0;43;0
WireConnection;46;1;44;0
WireConnection;46;2;42;3
WireConnection;74;0;72;1
WireConnection;74;1;73;0
WireConnection;10;0;8;0
WireConnection;10;1;26;0
WireConnection;75;0;72;2
WireConnection;75;1;70;0
WireConnection;73;0;51;0
WireConnection;73;1;61;0
WireConnection;0;2;10;0
WireConnection;0;11;114;0
ASEEND*/
//CHKSM=7C5AAED8487959DA3C902C8EA12E1FA407B047D1