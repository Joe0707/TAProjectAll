// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Scene_Glass"
{
	Properties
	{
		_Matcap("Matcap", 2D) = "white" {}
		_BaseColor("BaseColor", Color) = (1,1,1,1)
		_Min("Min", Float) = 0
		_Max("Max", Float) = 1
		_Refintensity("Refintensity", Float) = 1
		_RefracMatcap("RefracMatcap", 2D) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			float3 viewDir;
		};

		uniform sampler2D _Matcap;
		uniform float4 _BaseColor;
		uniform sampler2D _RefracMatcap;
		uniform float _Min;
		uniform float _Max;
		uniform float _Refintensity;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float3 normalizeResult24 = normalize( mul( UNITY_MATRIX_V, float4( reflect( -ase_worldViewDir , ase_normWorldNormal ) , 0.0 ) ).xyz );
			float temp_output_46_0 = (normalizeResult24).x;
			float temp_output_49_0 = (normalizeResult24).y;
			float temp_output_26_0 = ( (normalizeResult24).z + 1.0 );
			float2 MatcapImproved43 = ( ( (normalizeResult24).xy / ( sqrt( ( ( temp_output_46_0 * temp_output_46_0 ) + ( temp_output_49_0 * temp_output_49_0 ) + ( temp_output_26_0 * temp_output_26_0 ) ) ) * 2.0 ) ) + 0.5 );
			float4 tex2DNode9 = tex2D( _Matcap, MatcapImproved43 );
			float dotResult73 = dot( ase_worldNormal , i.viewDir );
			float smoothstepResult74 = smoothstep( _Min , _Max , dotResult73);
			float clampResult88 = clamp( ( 1.0 - smoothstepResult74 ) , 0.0 , 1.0 );
			float Thickness89 = clampResult88;
			float temp_output_92_0 = ( Thickness89 * _Refintensity );
			float4 lerpResult95 = lerp( ( _BaseColor * 0.5 ) , ( _BaseColor * tex2D( _RefracMatcap, ( MatcapImproved43 + temp_output_92_0 ) ) ) , temp_output_92_0);
			o.Emission = ( tex2DNode9 + lerpResult95 ).rgb;
			float clampResult106 = clamp( max( tex2DNode9.r , Thickness89 ) , 0.0 , 1.0 );
			o.Alpha = clampResult106;
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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
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
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
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
7;29;1906;1044;5189.547;1734.269;4.09977;True;False
Node;AmplifyShaderEditor.CommentaryNode;42;-3772.654,-172.9219;Inherit;False;2580.158;780.1812;MatcapUV_Improved;24;43;34;35;33;32;52;28;53;48;51;47;50;26;46;49;27;25;24;23;22;20;21;36;19;MatcapUV_Improved;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;19;-3723.654,-23.88438;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;36;-3488.616,-17.16479;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;21;-3582.914,126.0783;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ReflectOpNode;20;-3233.641,-6.862719;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewMatrixNode;22;-3209.913,-122.9219;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-3023.913,-45.92191;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;24;-2872.568,-44.27488;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;25;-2728.203,328.5052;Inherit;False;FLOAT;2;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2763.354,420.505;Inherit;False;Constant;_Float1;Float 1;1;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;46;-2630.382,126.4124;Inherit;False;FLOAT;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-2590.511,345.1519;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;114;-3781.631,1177.048;Inherit;False;1577.787;748.8865;Thickness;9;77;74;76;73;75;70;72;89;88;Thickness;1,1,1,1;0;0
Node;AmplifyShaderEditor.SwizzleNode;49;-2638.382,216.4123;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;70;-3666.284,1329.598;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;72;-3674.355,1566.355;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-2441.281,348.3123;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-2446.882,121.4124;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-2446.382,239.4124;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-3425.01,1598.686;Inherit;False;Property;_Min;Min;3;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-2238.381,218.9125;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;73;-3351.507,1456.049;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-3381.58,1711.169;Inherit;False;Property;_Max;Max;4;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;74;-3192.772,1509.857;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SqrtOpNode;28;-2107.611,203.1318;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-2129.481,309.9124;Inherit;False;Constant;_Float2;Float 2;2;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-1963.881,206.1124;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;32;-2453.326,-44.07676;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;77;-2867.327,1533.297;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-1797.755,230.535;Inherit;False;Constant;_Float3;Float 3;1;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;88;-2636.245,1537.16;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;33;-1773.837,-26.29051;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-1607.755,102.5349;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;89;-2461.958,1531.52;Inherit;False;Thickness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;-1249.89,1132.719;Inherit;False;89;Thickness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-1266.819,1231.253;Inherit;False;Property;_Refintensity;Refintensity;5;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;43;-1477.253,100.1434;Inherit;False;MatcapImproved;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-1090.747,964.7836;Inherit;False;43;MatcapImproved;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-1030.033,1157.648;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;91;-799.5984,1011.859;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;94;-644.5652,990.8094;Inherit;True;Property;_RefracMatcap;RefracMatcap;6;0;Create;True;0;0;False;0;False;-1;None;728d60c27d12d2545984583532a20617;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;45;-541.023,571.0889;Inherit;False;43;MatcapImproved;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;69;-699.8139,742.6234;Inherit;False;Property;_BaseColor;BaseColor;2;0;Create;True;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;97;-442.3961,816.3684;Inherit;False;Constant;_Float5;Float 5;8;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;372.8206,880.2926;Inherit;False;89;Thickness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;9;-260.726,548.8082;Inherit;True;Property;_Matcap;Matcap;0;0;Create;True;0;0;False;0;False;-1;None;728d60c27d12d2545984583532a20617;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-205.4505,749.9144;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-231.0116,969.1455;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;41;-3771.25,731.6068;Inherit;False;1334.12;314.3839;MatcapUV;8;16;3;40;18;17;15;2;1;MatcapUV;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;99;614.8464,822.8877;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;95;45.03058,1095.321;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldNormalVector;1;-3721.248,866.9907;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-2179.338,-543.6569;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-3282.789,917.857;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-3447.248,786.9907;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-2680.126,782.4483;Inherit;False;MatcapUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-2844.923,790.7457;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;61;-2825.774,-571.952;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CrossProductOpNode;57;-3028.774,-587.952;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;-1740.587,-514.212;Inherit;False;Matcap_Improved2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;54;-3533.169,-474.856;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;62;-2390.774,-575.952;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-2381.338,-445.657;Inherit;False;Constant;_Float4;Float 4;2;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;100;317.0634,563.8235;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;106;788.4006,813.2176;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;63;-2556.774,-478.952;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;60;-3201.774,-728.952;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;15;-3282.779,781.6066;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewMatrixNode;55;-3476.774,-561.952;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.ViewMatrixNode;2;-3660.248,783.9907;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-3043.024,788.4105;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TransformPositionNode;59;-3449.774,-795.952;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;58;-3706.774,-755.952;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;66;-1991.338,-515.6569;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-3230.774,-513.952;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1046.071,528.3845;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Scene_Glass;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;True;0;Custom;0.5;True;True;0;True;Custom;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;36;0;19;0
WireConnection;20;0;36;0
WireConnection;20;1;21;0
WireConnection;23;0;22;0
WireConnection;23;1;20;0
WireConnection;24;0;23;0
WireConnection;25;0;24;0
WireConnection;46;0;24;0
WireConnection;26;0;25;0
WireConnection;26;1;27;0
WireConnection;49;0;24;0
WireConnection;51;0;26;0
WireConnection;51;1;26;0
WireConnection;47;0;46;0
WireConnection;47;1;46;0
WireConnection;50;0;49;0
WireConnection;50;1;49;0
WireConnection;48;0;47;0
WireConnection;48;1;50;0
WireConnection;48;2;51;0
WireConnection;73;0;70;0
WireConnection;73;1;72;0
WireConnection;74;0;73;0
WireConnection;74;1;75;0
WireConnection;74;2;76;0
WireConnection;28;0;48;0
WireConnection;52;0;28;0
WireConnection;52;1;53;0
WireConnection;32;0;24;0
WireConnection;77;0;74;0
WireConnection;88;0;77;0
WireConnection;33;0;32;0
WireConnection;33;1;52;0
WireConnection;34;0;33;0
WireConnection;34;1;35;0
WireConnection;89;0;88;0
WireConnection;43;0;34;0
WireConnection;92;0;113;0
WireConnection;92;1;93;0
WireConnection;91;0;90;0
WireConnection;91;1;92;0
WireConnection;94;1;91;0
WireConnection;9;1;45;0
WireConnection;96;0;69;0
WireConnection;96;1;97;0
WireConnection;98;0;69;0
WireConnection;98;1;94;0
WireConnection;99;0;9;1
WireConnection;99;1;112;0
WireConnection;95;0;96;0
WireConnection;95;1;98;0
WireConnection;95;2;92;0
WireConnection;64;0;62;0
WireConnection;64;1;65;0
WireConnection;3;0;2;0
WireConnection;3;1;1;0
WireConnection;40;0;18;0
WireConnection;18;0;16;0
WireConnection;18;1;17;0
WireConnection;61;0;57;0
WireConnection;57;0;60;0
WireConnection;57;1;56;0
WireConnection;67;0;66;0
WireConnection;62;0;63;0
WireConnection;62;1;61;0
WireConnection;100;0;9;0
WireConnection;100;1;95;0
WireConnection;106;0;99;0
WireConnection;63;0;61;1
WireConnection;60;0;59;0
WireConnection;15;0;3;0
WireConnection;16;0;15;0
WireConnection;16;1;17;0
WireConnection;59;0;58;0
WireConnection;66;0;64;0
WireConnection;66;1;65;0
WireConnection;56;0;55;0
WireConnection;56;1;54;0
WireConnection;0;2;100;0
WireConnection;0;9;106;0
ASEEND*/
//CHKSM=97A0B24B7C5F921250AB9CE4E183988F8703EA9A