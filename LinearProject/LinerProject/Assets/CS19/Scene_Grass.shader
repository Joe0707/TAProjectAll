// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Scene_Grass"
{
	Properties
	{
		_Color1("Color1", Color) = (1,1,1,1)
		_Color2("Color2", Color) = (1,1,1,1)
		_FlowerColor("FlowerColor", Color) = (0,0,0,0)
		_Roughness("Roughness", Range( 0 , 1)) = 0
		_WindDirection("WindDirection", Vector) = (0,0,0,0)
		_WindSpeed("WindSpeed", Float) = 1
		_WindIntensity("WindIntensity", Float) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			float4 vertexColor : COLOR;
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

		uniform float3 _WindDirection;
		uniform float _WindSpeed;
		uniform float _WindIntensity;
		uniform float4 _FlowerColor;
		uniform float4 _Color1;
		uniform float4 _Color2;
		uniform float _Roughness;


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
			float3 temp_output_7_0_g1 = _WindDirection;
			float3 RotateAxis34_g1 = cross( temp_output_7_0_g1 , float3(0,1,0) );
			float3 wind_direction31_g1 = temp_output_7_0_g1;
			float3 wind_speed40_g1 = ( ( _Time.y * _WindSpeed ) * float3(0.5,-0.5,-0.5) );
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
			v.vertex.xyz += ( v.color.r * ( worldToObj81_g1 - ase_vertex3Pos ) * _WindIntensity );
			v.vertex.w = 1;
			v.normal = float3(0,0,1);
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			SurfaceOutputStandard s1 = (SurfaceOutputStandard ) 0;
			float4 lerpResult4 = lerp( _Color1 , _Color2 , i.vertexColor.r);
			float4 lerpResult6 = lerp( _FlowerColor , lerpResult4 , i.vertexColor.a);
			s1.Albedo = lerpResult6.rgb;
			float3 ase_worldNormal = i.worldNormal;
			s1.Normal = ase_worldNormal;
			s1.Emission = float3( 0,0,0 );
			s1.Metallic = 0.0;
			s1.Smoothness = ( 1.0 - _Roughness );
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
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
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
				o.worldNormal = worldNormal;
				o.worldPos = worldPos;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				surfIN.vertexColor = IN.color;
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
7;29;1522;788;1802.852;339.8573;1.866612;True;False
Node;AmplifyShaderEditor.ColorNode;2;-1083.185,86.62231;Inherit;False;Property;_Color1;Color1;0;0;Create;True;0;0;False;0;False;1,1,1,1;0.2235292,0.5058824,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;3;-1221.511,238.5213;Inherit;False;Property;_Color2;Color2;1;0;Create;True;0;0;False;0;False;1,1,1,1;0.5019608,0.7333333,0.2627451,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;5;-1070.511,503.5213;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;14;-1093.588,754.1339;Inherit;False;Property;_WindSpeed;WindSpeed;5;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;13;-1122.588,895.1339;Inherit;False;Property;_WindDirection;WindDirection;4;0;Create;True;0;0;False;0;False;0,0,0;0,0,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;4;-868.5112,284.5213;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-791.5112,389.5213;Inherit;False;Property;_Roughness;Roughness;3;0;Create;True;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;7;-822.5112,54.5213;Inherit;False;Property;_FlowerColor;FlowerColor;2;0;Create;True;0;0;False;0;False;0,0,0,0;0.9862068,1,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;12;-745.5881,849.1339;Inherit;False;SimpleGrassWind;-1;;1;22350d6ace565734d907ae88fac2a4fe;0;2;1;FLOAT;1;False;7;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-696.5881,961.1339;Inherit;False;Property;_WindIntensity;WindIntensity;6;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;6;-559.5112,103.5213;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-628.5112,268.5213;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;10;-494.5112,358.5213;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;11;-238.511,393.5213;Inherit;False;Constant;_Vector0;Vector 0;3;0;Create;True;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-389.5881,842.1339;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomStandardSurface;1;-288,175;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;173.5948,225.8601;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Scene_Grass;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;2;0
WireConnection;4;1;3;0
WireConnection;4;2;5;1
WireConnection;12;1;14;0
WireConnection;12;7;13;0
WireConnection;6;0;7;0
WireConnection;6;1;4;0
WireConnection;6;2;5;4
WireConnection;10;0;9;0
WireConnection;15;0;5;1
WireConnection;15;1;12;0
WireConnection;15;2;16;0
WireConnection;1;0;6;0
WireConnection;1;3;8;0
WireConnection;1;4;10;0
WireConnection;0;13;1;0
WireConnection;0;11;15;0
WireConnection;0;12;11;0
ASEEND*/
//CHKSM=57B4BB47E3719CF64B188333A85E50860E822AEB