// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Scene_WindowGlass"
{
	Properties
	{
		_MatCap("MatCap", 2D) = "white" {}
		_Alpha("Alpha", Range( 0 , 2)) = 0
		_Reflect("Reflect", 2D) = "white" {}
		_GlassMask("GlassMask", 2D) = "white" {}
		_FresnelScale("FresnelScale", Float) = 1
		_FresnelBias("FresnelBias", Float) = 0
		_FresnelPower("FresnelPower", Float) = 3
		_Center("Center", Vector) = (0,0,0,0)
		_ReflectionIntensity("ReflectionIntensity", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
		};

		uniform sampler2D _Reflect;
		uniform float3 _Center;
		uniform float _ReflectionIntensity;
		uniform sampler2D _GlassMask;
		uniform float4 _GlassMask_ST;
		uniform float _FresnelBias;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform sampler2D _MatCap;
		uniform float _Alpha;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToWorldDir108 = mul( unity_ObjectToWorld, float4( ( ase_vertex3Pos - _Center ), 0 ) ).xyz;
			float3 normalizeResult109 = normalize( objToWorldDir108 );
			float2 temp_output_116_0 = ((mul( UNITY_MATRIX_V, float4( normalizeResult109 , 0.0 ) ).xyz).xy*0.5 + 0.5);
			float2 uv_GlassMask = i.uv_texcoord * _GlassMask_ST.xy + _GlassMask_ST.zw;
			float4 tex2DNode39 = tex2D( _GlassMask, uv_GlassMask );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV48 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode48 = ( _FresnelBias + _FresnelScale * pow( max( 1.0 - fresnelNdotV48 , 0.0001 ), _FresnelPower ) );
			o.Emission = ( ( tex2D( _Reflect, temp_output_116_0 ) * _ReflectionIntensity ) + tex2DNode39.r + fresnelNode48 ).rgb;
			float saferPower117 = max( tex2D( _MatCap, temp_output_116_0 ).r , 0.0001 );
			float clampResult27 = clamp( ( ( max( pow( saferPower117 , 4.0 ) , tex2DNode39.r ) * _Alpha ) + fresnelNode48 ) , 0.0 , 1.0 );
			o.Alpha = clampResult27;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
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
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
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
				o.worldNormal = worldNormal;
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
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
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
281;577;1906;1044;1846.319;36.49149;1.6;True;False
Node;AmplifyShaderEditor.PosVertexDataNode;107;-2181.922,353.7567;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;105;-2154.842,566.3868;Inherit;False;Property;_Center;Center;7;0;Create;True;0;0;False;0;False;0,0,0;0,0,2;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;106;-1958.013,471.5128;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;108;-1764.872,476.3563;Inherit;False;Object;World;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;109;-1518.579,486.4938;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewMatrixNode;14;-1484.296,169.8881;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-1291.296,200.888;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;115;-1136.901,195.9896;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;116;-945.217,198.3956;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;12;-542.6082,407.0748;Inherit;True;Property;_MatCap;MatCap;0;0;Create;True;0;0;False;0;False;-1;None;0b3a0bd16fbc18e40a22fc28ef6ef753;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;117;-175.6591,440.647;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;39;-302.3348,660.9808;Inherit;True;Property;_GlassMask;GlassMask;3;0;Create;True;0;0;False;0;False;-1;None;6d07541d5ffcdae4592b0d3f3f301995;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;44;145.0494,453.2599;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;37.71059,686.6262;Inherit;False;Property;_Alpha;Alpha;1;0;Create;True;0;0;False;0;False;0;0.02;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-384.9642,954.6057;Inherit;False;Property;_FresnelBias;FresnelBias;5;0;Create;True;0;0;False;0;False;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-380.8246,1124.402;Inherit;False;Property;_FresnelPower;FresnelPower;6;0;Create;True;0;0;False;0;False;3;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-376.515,1042.707;Inherit;False;Property;_FresnelScale;FresnelScale;4;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;413.5501,544.9865;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;104;-549.4745,105.6449;Inherit;True;Property;_Reflect;Reflect;2;0;Create;True;0;0;False;0;False;-1;None;a6593136a8ff4d34094ffd0928960e81;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;48;-141.0962,952.5595;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-166.6454,173.5044;Inherit;False;Property;_ReflectionIntensity;ReflectionIntensity;8;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;59.53885,106.6519;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;120;534.1998,785.202;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;27;718.2613,657.8785;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;13;-1704.994,241.8474;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;56;458.9157,122.3715;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;863.1724,131.3487;Float;False;True;-1;6;ASEMaterialInspector;0;0;Unlit;Scene_WindowGlass;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;106;0;107;0
WireConnection;106;1;105;0
WireConnection;108;0;106;0
WireConnection;109;0;108;0
WireConnection;15;0;14;0
WireConnection;15;1;109;0
WireConnection;115;0;15;0
WireConnection;116;0;115;0
WireConnection;12;1;116;0
WireConnection;117;0;12;1
WireConnection;44;0;117;0
WireConnection;44;1;39;1
WireConnection;35;0;44;0
WireConnection;35;1;36;0
WireConnection;104;1;116;0
WireConnection;48;1;50;0
WireConnection;48;2;54;0
WireConnection;48;3;53;0
WireConnection;113;0;104;0
WireConnection;113;1;114;0
WireConnection;120;0;35;0
WireConnection;120;1;48;0
WireConnection;27;0;120;0
WireConnection;56;0;113;0
WireConnection;56;1;39;1
WireConnection;56;2;48;0
WireConnection;0;2;56;0
WireConnection;0;9;27;0
ASEEND*/
//CHKSM=16FB0A6DD2F59C04C56FD2B5F390DF1C4BA4551D