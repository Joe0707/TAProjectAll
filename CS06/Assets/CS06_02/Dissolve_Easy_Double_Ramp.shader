// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dissolve_Easy"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_Gradient("Gradient", 2D) = "white" {}
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0.5126595
		_EdgeWidth("EdgeWidth", Range( 0 , 2)) = 0.1
		_EegeIntensity("EegeIntensity", Float) = 2
		[Toggle(_MANNULCONTROL_ON)] _MANNULCONTROL("MANNULCONTROL", Float) = 1
		_Spread("Spread", Range( 0 , 1)) = 0
		_Noise("Noise", 2D) = "white" {}
		_Float1("Float 1", Float) = 0
		_RampTex("RampTex", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature _MANNULCONTROL_ON
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _RampTex;
		uniform sampler2D _Gradient;
		uniform float4 _Gradient_ST;
		uniform float _ChangeAmount;
		uniform float _Spread;
		uniform float _Float1;
		uniform sampler2D _Noise;
		uniform float4 _Noise_ST;
		uniform float _EdgeWidth;
		uniform float _EegeIntensity;
		uniform float _Cutoff = 0.5;

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
			float Gradient23 = ( ( ( tex2D( _Gradient, uv_Gradient ).r - (-_Spread + (staticSwitch29 - 0.0) * (1.0 - -_Spread) / (1.0 - 0.0)) ) / _Spread ) * _Float1 );
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float2 panner36 = ( 1.0 * _Time.y * float2( 0,0 ) + uv_Noise);
			float Noise38 = tex2D( _Noise, panner36 ).r;
			float temp_output_40_0 = ( Gradient23 - Noise38 );
			float clampResult15 = clamp( ( 1.0 - ( distance( temp_output_40_0 , 0.5 ) / _EdgeWidth ) ) , 0.0 , 1.0 );
			float4 appendResult43 = (float4(( 1.0 - clampResult15 ) , 0.5 , 0.0 , 0.0));
			float4 RampColor45 = tex2D( _RampTex, appendResult43.xy );
			float4 lerpResult19 = lerp( tex2DNode1 , ( RampColor45 * _EegeIntensity * tex2DNode1 ) , clampResult15);
			o.Emission = lerpResult19.rgb;
			o.Alpha = 1;
			clip( ( tex2DNode1.a * step( 0.5 , temp_output_40_0 ) ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
41;148;1522;788;953.6499;-350.1512;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;22;-2289.517,-396.6843;Inherit;False;1123.869;785.8799;Gradient;13;30;8;23;4;2;29;5;28;27;31;32;41;42;;0.1999999,1,0,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;27;-2272.443,138.102;Inherit;False;1;0;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;28;-2110.957,68.269;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2235.33,281.7188;Inherit;False;Property;_Spread;Spread;8;0;Create;True;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2234.232,-228.5306;Inherit;False;Property;_ChangeAmount;ChangeAmount;3;0;Create;True;0;0;False;0;False;0.5126595;0.4749583;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;29;-2189.582,-92.73099;Inherit;False;Property;_MANNULCONTROL;MANNULCONTROL;7;0;Create;True;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;False;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;31;-2044.328,155.8425;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;8;-1870.731,9.185555;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-1966.091,-340.8578;Inherit;True;Property;_Gradient;Gradient;2;0;Create;True;0;0;False;0;False;-1;9f596798ece08994c8528294715641cd;9f596798ece08994c8528294715641cd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-1626.173,-326.13;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-2889.034,670.2698;Inherit;False;0;33;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;37;-2864.549,868.265;Inherit;False;Constant;_NoiseSpeed;NoiseSpeed;10;0;Create;True;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;32;-1590.375,104.3851;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1366.421,313.0679;Inherit;False;Property;_Float1;Float 1;10;0;Create;True;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;36;-2598.232,731.7399;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1355.788,144.2583;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;33;-2347.07,705.245;Inherit;True;Property;_Noise;Noise;9;0;Create;True;0;0;False;0;False;-1;b518525ec3f2a154d8d7cc44a6012ab9;b518525ec3f2a154d8d7cc44a6012ab9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-1999.693,730.0881;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-1335.54,-172.7368;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-1056.835,280.7544;Inherit;False;38;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;25;-1504.984,463.2112;Inherit;False;2034.828;728.1328;EdgeColor;10;44;43;15;14;12;10;13;11;45;47;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-1063.571,158.9185;Inherit;False;23;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1454.984,678.9793;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;40;-863.835,216.7544;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;10;-1269.11,513.2111;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1404.408,823.5321;Inherit;False;Property;_EdgeWidth;EdgeWidth;4;0;Create;True;0;0;False;0;False;0.1;0.5535086;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;12;-1012.248,571.004;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;14;-799.8269,568.0335;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;15;-620.0867,584.3738;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;47;-566.6499,758.1511;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;43;-314.2152,725.0699;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;44;-120.2152,707.0699;Inherit;True;Property;_RampTex;RampTex;11;0;Create;True;0;0;False;0;False;-1;None;c7370cf76a1fa8c4ebe291ba6d0c6081;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;75.92017,581.0269;Inherit;False;RampColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-546.2573,-335.0159;Inherit;False;45;RampColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-777.4983,-102.8814;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;False;-1;062a1135c5d262f43b456bd8aac598fb;062a1135c5d262f43b456bd8aac598fb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;21;-320.7326,-465.6895;Inherit;False;Property;_EegeIntensity;EegeIntensity;6;0;Create;True;0;0;False;0;False;2;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-19.00754,-387.7724;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;7;-534,136;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-318,160.4965;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;18;-685.0524,-497.2229;Inherit;False;Property;_EdgeColor;EdgeColor;5;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;19;-0.8794203,123.9058;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;717.4764,-35.651;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Dissolve_Easy;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
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
WireConnection;36;0;35;0
WireConnection;36;2;37;0
WireConnection;41;0;32;0
WireConnection;41;1;42;0
WireConnection;33;1;36;0
WireConnection;38;0;33;1
WireConnection;23;0;41;0
WireConnection;40;0;24;0
WireConnection;40;1;39;0
WireConnection;10;0;40;0
WireConnection;10;1;11;0
WireConnection;12;0;10;0
WireConnection;12;1;13;0
WireConnection;14;0;12;0
WireConnection;15;0;14;0
WireConnection;47;0;15;0
WireConnection;43;0;47;0
WireConnection;44;1;43;0
WireConnection;45;0;44;0
WireConnection;20;0;46;0
WireConnection;20;1;21;0
WireConnection;20;2;1;0
WireConnection;7;1;40;0
WireConnection;3;0;1;4
WireConnection;3;1;7;0
WireConnection;19;0;1;0
WireConnection;19;1;20;0
WireConnection;19;2;15;0
WireConnection;0;2;19;0
WireConnection;0;10;3;0
ASEEND*/
//CHKSM=F6AEC3D070081E6DF2542A5EE928371123D8BABB