// Upgrade NOTE: upgraded instancing buffer 'Fire' to new syntax.

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Fire"
{
	Properties
	{
		_Noise("Noise", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Vector) = (0,0,0,0)
		_TintColor("TintColor", Color) = (0,0.2550357,0.9669316,0)
		_Gradient("Gradient", 2D) = "white" {}
		_GrandientEndControl("GrandientEndControl", Float) = 2
		_Softness("Softness", Range( 0 , 1)) = 0.3065573
		_EmissIntensity("EmissIntensity", Float) = 10
		_EndMiss("EndMiss", Range( 0 , 1)) = 0.8051311
		_FireShape("FireShape", 2D) = "white" {}
		_NoiseIntensity("NoiseIntensity", Float) = 0
		_Number("Number", Float) = 0
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
		#pragma multi_compile_instancing
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _TintColor;
		uniform float _EmissIntensity;
		uniform float _EndMiss;
		uniform sampler2D _Gradient;
		uniform float _GrandientEndControl;
		uniform sampler2D _Noise;
		uniform float4 _Noise_ST;
		uniform sampler2D _FireShape;
		uniform float4 _FireShape_ST;
		uniform float _NoiseIntensity;
		uniform float _Number;
		uniform float _Softness;

		UNITY_INSTANCING_BUFFER_START(Fire)
			UNITY_DEFINE_INSTANCED_PROP(float2, _NoiseSpeed)
#define _NoiseSpeed_arr Fire
		UNITY_INSTANCING_BUFFER_END(Fire)

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 break37 = ( _TintColor * _EmissIntensity );
			float4 tex2DNode17 = tex2D( _Gradient, i.uv_texcoord );
			float GradientEnd32 = ( ( 1.0 - tex2DNode17.r ) * _GrandientEndControl );
			float2 _NoiseSpeed_Instance = UNITY_ACCESS_INSTANCED_PROP(_NoiseSpeed_arr, _NoiseSpeed);
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float2 panner10 = ( 1.0 * _Time.y * _NoiseSpeed_Instance + uv_Noise);
			float Noise25 = tex2D( _Noise, panner10 ).r;
			float4 appendResult38 = (float4(break37.r , ( break37.g + ( _EndMiss * GradientEnd32 * Noise25 ) ) , break37.b , 0.0));
			o.Emission = appendResult38.xyz;
			float2 uv_FireShape = i.uv_texcoord * _FireShape_ST.xy + _FireShape_ST.zw;
			float4 appendResult59 = (float4(( uv_FireShape.x + ( (Noise25*2.0 + -1.0) * _NoiseIntensity * GradientEnd32 ) ) , uv_FireShape.y , 0.0 , 0.0));
			float4 tex2DNode46 = tex2D( _FireShape, appendResult59.xy );
			float clampResult66 = clamp( ( ( tex2DNode46.r * tex2DNode46.r ) * _Number ) , 0.0 , 1.0 );
			float FireSharp68 = clampResult66;
			float clampResult23 = clamp( ( Noise25 - _Softness ) , 0.0 , 1.0 );
			float Gradient24 = tex2DNode17.r;
			float smoothstepResult19 = smoothstep( clampResult23 , Noise25 , Gradient24);
			o.Alpha = ( FireSharp68 * smoothstepResult19 );
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
-1718;60;1522;780;1905.072;-995.4829;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;28;-2000.804,26.36257;Inherit;False;1301.707;903.5541;GradientAndNoise;12;29;24;17;18;25;6;10;12;1;30;31;32;;0.2413793,1,0,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;18;-1952.311,529.1486;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-1871.829,76.42866;Inherit;False;0;6;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;12;-1905.345,339.6119;Inherit;False;InstancedProperty;_NoiseSpeed;NoiseSpeed;1;0;Create;True;0;0;False;0;False;0,0;0,-1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;10;-1735.211,222.8104;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;17;-1708.902,535.9977;Inherit;True;Property;_Gradient;Gradient;3;0;Create;True;0;0;False;0;False;-1;801fed79971098c48a6eb80ef54db8a1;801fed79971098c48a6eb80ef54db8a1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;31;-1602.432,809.2686;Inherit;False;Property;_GrandientEndControl;GrandientEndControl;4;0;Create;True;0;0;False;0;False;2;4.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-1508.722,153.8121;Inherit;True;Property;_Noise;Noise;0;0;Create;True;0;0;False;0;False;-1;6a36d32c08d6e9f4b91dea5c68bdab22;6a36d32c08d6e9f4b91dea5c68bdab22;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;29;-1286.411,503.4692;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-1190.15,121.2636;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;67;-2015.342,1195.99;Inherit;False;2331.91;701.3052;Sharp;14;61;47;52;49;53;63;62;66;64;50;51;46;59;68;;0,0.1446247,0.6764706,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1261.353,747.6124;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-1039.781,601.172;Inherit;True;GradientEnd;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;-1960.534,1479.956;Inherit;True;25;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;-1464.3,1872.463;Inherit;True;32;GradientEnd;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;61;-1698.473,1564.371;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1497.285,1782.443;Inherit;False;Property;_NoiseIntensity;NoiseIntensity;9;0;Create;True;0;0;False;0;False;0;0.09;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;47;-1542.05,1277.698;Inherit;False;0;46;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-1215.733,1630.325;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-1285.656,1408.41;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;59;-1034.184,1313.821;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;46;-835.629,1154.152;Inherit;True;Property;_FireShape;FireShape;8;0;Create;True;0;0;False;0;False;-1;3de8274e4f520cd42a36c6c953154202;3de8274e4f520cd42a36c6c953154202;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-551.2142,1358.327;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-429.0483,1452.229;Inherit;False;Property;_Number;Number;10;0;Create;True;0;0;False;0;False;0;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-364.9498,1310.524;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;14;-369.2963,-129.8214;Inherit;False;Property;_TintColor;TintColor;2;0;Create;True;0;0;False;0;False;0,0.2550357,0.9669316,0;0,0.2137933,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;21;-324.0589,470.8818;Inherit;False;Property;_Softness;Softness;5;0;Create;True;0;0;False;0;False;0.3065573;0.3065573;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-380.3351,668.8062;Inherit;False;25;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-387.3083,48.18902;Inherit;False;Property;_EmissIntensity;EmissIntensity;6;0;Create;True;0;0;False;0;False;10;1.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-294.8467,287.3122;Inherit;False;25;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;66;-224.8393,1302.282;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-122.3966,-69.58388;Inherit;True;Property;_EndMiss;EndMiss;7;0;Create;True;0;0;False;0;False;0.8051311;0.61;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-307.8514,179.8442;Inherit;False;32;GradientEnd;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-1277.232,354.9229;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-38.7593,-182.8721;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;20;-21.06759,291.017;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;-34.91382,1347.562;Inherit;False;FireSharp;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;155.1227,82.78164;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;37;105.5813,-236.5182;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ClampOpNode;23;85.9285,418.1875;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-79.59278,643.1015;Inherit;False;24;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;170.0199,-2.121554;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;591.5717,934.758;Inherit;False;68;FireSharp;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;19;173.3374,725.0493;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;38;466.9674,-171.3666;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;758.7964,766.0931;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;506.3929,255.3515;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Fire;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;10;0;1;0
WireConnection;10;2;12;0
WireConnection;17;1;18;0
WireConnection;6;1;10;0
WireConnection;29;0;17;1
WireConnection;25;0;6;1
WireConnection;30;0;29;0
WireConnection;30;1;31;0
WireConnection;32;0;30;0
WireConnection;61;0;49;0
WireConnection;51;0;61;0
WireConnection;51;1;52;0
WireConnection;51;2;53;0
WireConnection;50;0;47;1
WireConnection;50;1;51;0
WireConnection;59;0;50;0
WireConnection;59;1;47;2
WireConnection;46;1;59;0
WireConnection;62;0;46;1
WireConnection;62;1;46;1
WireConnection;64;0;62;0
WireConnection;64;1;63;0
WireConnection;66;0;64;0
WireConnection;24;0;17;1
WireConnection;33;0;14;0
WireConnection;33;1;34;0
WireConnection;20;0;26;0
WireConnection;20;1;21;0
WireConnection;68;0;66;0
WireConnection;42;0;40;0
WireConnection;42;1;41;0
WireConnection;42;2;44;0
WireConnection;37;0;33;0
WireConnection;23;0;20;0
WireConnection;39;0;37;1
WireConnection;39;1;42;0
WireConnection;19;0;27;0
WireConnection;19;1;23;0
WireConnection;19;2;26;0
WireConnection;38;0;37;0
WireConnection;38;1;39;0
WireConnection;38;2;37;2
WireConnection;48;0;69;0
WireConnection;48;1;19;0
WireConnection;0;2;38;0
WireConnection;0;9;48;0
ASEEND*/
//CHKSM=1F5E0CF42E46169139AE368E6CD652C563E5E7A3