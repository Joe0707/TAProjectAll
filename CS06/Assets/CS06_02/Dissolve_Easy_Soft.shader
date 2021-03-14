// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dissolve_Easy"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_Gradient("Gradient", 2D) = "white" {}
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0.5126595
		_EdgeWidth("EdgeWidth", Range( 0 , 2)) = 0.1
		_EdgeColor("EdgeColor", Color) = (0,0,0,0)
		_EegeIntensity("EegeIntensity", Float) = 2
		[Toggle(_MANNULCONTROL_ON)] _MANNULCONTROL("MANNULCONTROL", Float) = 0
		_Spread("Spread", Range( 0 , 1)) = 0
		_Softness("Softness", Range( 0 , 0.5)) = 0
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
		#pragma target 3.0
		#pragma shader_feature _MANNULCONTROL_ON
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _EdgeColor;
		uniform float _EegeIntensity;
		uniform sampler2D _Gradient;
		uniform float4 _Gradient_ST;
		uniform float _ChangeAmount;
		uniform float _Spread;
		uniform float _Softness;
		uniform float _EdgeWidth;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			float2 uv_Gradient = i.uv_texcoord * _Gradient_ST.xy + _Gradient_ST.zw;
			float mulTime27 = _Time.y * 0.2;
			#ifdef _MANNULCONTROL_ON
				float staticSwitch29 = _ChangeAmount;
			#else
				float staticSwitch29 = frac( mulTime27 );
			#endif
			float Gradient23 = ( ( tex2D( _Gradient, uv_Gradient ).r - (-_Spread + (staticSwitch29 - 0.0) * (1.0 - -_Spread) / (1.0 - 0.0)) ) / _Spread );
			float clampResult15 = clamp( ( 1.0 - ( distance( Gradient23 , _Softness ) / _EdgeWidth ) ) , 0.0 , 1.0 );
			float4 lerpResult19 = lerp( tex2DNode1 , ( _EdgeColor * _EegeIntensity * tex2DNode1 ) , clampResult15);
			o.Emission = lerpResult19.rgb;
			float smoothstepResult33 = smoothstep( _Softness , 0.5 , Gradient23);
			o.Alpha = ( tex2DNode1.a * smoothstepResult33 );
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
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
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
192;165;1522;788;2336.674;108.2039;1.617145;True;True
Node;AmplifyShaderEditor.CommentaryNode;22;-2289.517,-396.6843;Inherit;False;1123.869;785.8799;Gradient;11;30;8;23;4;2;29;5;28;27;31;32;;0.1999999,1,0,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;27;-2272.443,138.102;Inherit;False;1;0;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2272.316,-147.4343;Inherit;False;Property;_ChangeAmount;ChangeAmount;2;0;Create;True;0;0;False;0;False;0.5126595;0.46;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2240.573,247.6411;Inherit;False;Property;_Spread;Spread;7;0;Create;True;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;28;-2110.957,68.269;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;29;-2189.582,-92.73099;Inherit;False;Property;_MANNULCONTROL;MANNULCONTROL;6;0;Create;True;0;0;False;0;False;0;0;1;True;;Toggle;2;Key0;Key1;Create;False;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;31;-2024.668,154.5318;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-1926.771,-350.0325;Inherit;True;Property;_Gradient;Gradient;1;0;Create;True;0;0;False;0;False;-1;9f596798ece08994c8528294715641cd;b518525ec3f2a154d8d7cc44a6012ab9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;8;-1834.032,14.42828;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-1626.173,-345.7902;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;32;-1501.299,114.8891;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-1335.54,-172.7368;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-1857.807,449.2579;Inherit;False;Property;_Softness;Softness;8;0;Create;True;0;0;False;0;False;0;0.3272704;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-1104.487,165.056;Inherit;False;23;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;25;-1504.984,463.2112;Inherit;False;1324.309;471.7719;EdgeColor;5;15;14;12;10;13;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DistanceOpNode;10;-1269.11,513.2111;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1404.408,823.5321;Inherit;False;Property;_EdgeWidth;EdgeWidth;3;0;Create;True;0;0;False;0;False;0.1;0.1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;12;-1012.248,571.004;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;18;-337.0524,-334.2229;Inherit;False;Property;_EdgeColor;EdgeColor;4;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-777.4983,-102.8814;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;False;0;False;-1;062a1135c5d262f43b456bd8aac598fb;062a1135c5d262f43b456bd8aac598fb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;21;-320.7326,-465.6895;Inherit;False;Property;_EegeIntensity;EegeIntensity;5;0;Create;True;0;0;False;0;False;2;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;14;-799.8269,568.0335;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-19.00754,-387.7724;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;33;-761.3096,147.0288;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;15;-620.0867,584.3738;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-318,160.4965;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;19;-0.8794203,123.9058;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;717.4764,-35.651;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Dissolve_Easy;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;28;0;27;0
WireConnection;29;1;28;0
WireConnection;29;0;5;0
WireConnection;31;0;30;0
WireConnection;8;0;29;0
WireConnection;8;3;31;0
WireConnection;4;0;2;1
WireConnection;4;1;8;0
WireConnection;32;0;4;0
WireConnection;32;1;30;0
WireConnection;23;0;32;0
WireConnection;10;0;24;0
WireConnection;10;1;34;0
WireConnection;12;0;10;0
WireConnection;12;1;13;0
WireConnection;14;0;12;0
WireConnection;20;0;18;0
WireConnection;20;1;21;0
WireConnection;20;2;1;0
WireConnection;33;0;24;0
WireConnection;33;1;34;0
WireConnection;15;0;14;0
WireConnection;3;0;1;4
WireConnection;3;1;33;0
WireConnection;19;0;1;0
WireConnection;19;1;20;0
WireConnection;19;2;15;0
WireConnection;0;2;19;0
WireConnection;0;9;3;0
ASEEND*/
//CHKSM=B9B37DDDCE4CF65A8AEB11C6E483866C66BAFF0D