// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Flag_Burn"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Size("Size", Range( 0 , 10)) = 1
		_MainTex("MainTex", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Matallic("Matallic", Range( 0 , 1)) = 0
		_VAT_POS("VAT_POS", 2D) = "white" {}
		_VAT_NORMAL("VAT_NORMAL", 2D) = "white" {}
		_Speed("Speed", Float) = 0
		_BoudingMin("BoudingMin", Float) = 0
		_BoudingMax("BoudingMax", Float) = 0
		_WindIntensity("WindIntensity", Range( 0 , 1)) = 1
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0.5126595
		_NoiseStrength("NoiseStrength", Vector) = (0,0,0,0)
		[Toggle(_MANNULCONTROL_ON)] _MANNULCONTROL("MANNULCONTROL", Float) = 1
		_Spread("Spread", Range( 0 , 1)) = 0
		_ObjectScale("ObjectScale", Float) = 1
		_PivotOffset("PivotOffset", Float) = 0
		_FrameCount("FrameCount", Float) = 0
		_FlameOffset("FlameOffset", Float) = 0.5
		_FlameWidth("FlameWidth", Range( 0 , 2)) = 0.1
		_FlameColor("FlameColor", Color) = (0,0,0,0)
		_FlameIntensity("FlameIntensity", Float) = 0
		_CharringOffset("CharringOffset", Float) = 0.5
		_CharringWidth("CharringWidth", Range( 0 , 2)) = 0.1
		_FlowMap("FlowMap", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Float) = 0
		_Noise("Noise", 2D) = "white" {}
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
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform sampler2D _VAT_POS;
		uniform float _Speed;
		uniform float _FrameCount;
		uniform float _BoudingMax;
		uniform float _BoudingMin;
		uniform float _WindIntensity;
		uniform sampler2D _VAT_NORMAL;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _PivotOffset;
		uniform float _ObjectScale;
		uniform float _ChangeAmount;
		uniform float _Spread;
		uniform sampler2D _Noise;
		uniform float4 _Noise_ST;
		uniform float _Size;
		uniform sampler2D _FlowMap;
		uniform float4 _FlowMap_ST;
		uniform float2 _NoiseStrength;
		uniform float _NoiseSpeed;
		uniform float _CharringOffset;
		uniform float _CharringWidth;
		uniform float _FlameOffset;
		uniform float _FlameWidth;
		uniform float4 _FlameColor;
		uniform float _FlameIntensity;
		uniform float _Matallic;
		uniform float _Smoothness;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float CurrentFrame16 = ( ( -ceil( ( frac( ( _Time.y * _Speed ) ) * _FrameCount ) ) / _FrameCount ) + ( -1.0 / _FrameCount ) );
			float2 appendResult19 = (float2(v.texcoord1.xy.x , CurrentFrame16));
			float2 UV_VAT20 = appendResult19;
			float3 appendResult31 = (float3(-( ( (tex2Dlod( _VAT_POS, float4( UV_VAT20, 0, 0.0) )).rgb * ( _BoudingMax - _BoudingMin ) ) + _BoudingMin ).x , 0.0 , 0.0));
			float3 VAT_VertexOffset32 = appendResult31;
			v.vertex.xyz += ( VAT_VertexOffset32 * _WindIntensity );
			v.vertex.w = 1;
			float3 break36 = ((tex2Dlod( _VAT_NORMAL, float4( UV_VAT20, 0, 0.0) )).rgb*2.0 + -1.0);
			float3 appendResult39 = (float3(-break36.x , break36.z , break36.y));
			float3 VAT_VertexNormal35 = appendResult39;
			float3 ase_vertexNormal = v.normal.xyz;
			float3 lerpResult44 = lerp( VAT_VertexNormal35 , ase_vertexNormal , _WindIntensity);
			v.normal = lerpResult44;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld71 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float clampResult80 = clamp( ( ( ( ase_worldPos.y - objToWorld71.y ) - _PivotOffset ) / _ObjectScale ) , 0.0 , 1.0 );
			float mulTime75 = _Time.y * 0.2;
			#ifdef _MANNULCONTROL_ON
				float staticSwitch82 = _ChangeAmount;
			#else
				float staticSwitch82 = frac( mulTime75 );
			#endif
			float Gradient90 = ( ( ( clampResult80 - (-_Spread + (staticSwitch82 - 0.0) * (1.0 - -_Spread) / (1.0 - 0.0)) ) / _Spread ) * 2.0 );
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float2 temp_output_4_0_g1 = (( uv_Noise / _Size )).xy;
			float2 uv_FlowMap = i.uv_texcoord * _FlowMap_ST.xy + _FlowMap_ST.zw;
			float4 tex2DNode151 = tex2D( _FlowMap, uv_FlowMap );
			float4 appendResult153 = (float4(tex2DNode151.r , tex2DNode151.g , 0.0 , 0.0));
			float2 temp_output_41_0_g1 = ( appendResult153.xy + 0.5 );
			float2 temp_output_17_0_g1 = _NoiseStrength;
			float mulTime22_g1 = _Time.y * _NoiseSpeed;
			float temp_output_27_0_g1 = frac( mulTime22_g1 );
			float2 temp_output_11_0_g1 = ( temp_output_4_0_g1 + ( temp_output_41_0_g1 * temp_output_17_0_g1 * temp_output_27_0_g1 ) );
			float2 temp_output_12_0_g1 = ( temp_output_4_0_g1 + ( temp_output_41_0_g1 * temp_output_17_0_g1 * frac( ( mulTime22_g1 + 0.5 ) ) ) );
			float4 lerpResult9_g1 = lerp( tex2D( _Noise, temp_output_11_0_g1 ) , tex2D( _Noise, temp_output_12_0_g1 ) , ( abs( ( temp_output_27_0_g1 - 0.5 ) ) / 0.5 ));
			float Noise97 = (lerpResult9_g1).r;
			float GradientNoise104 = ( Gradient90 - Noise97 );
			float clampResult137 = clamp( ( ( distance( GradientNoise104 , _CharringOffset ) / _CharringWidth ) - 0.25 ) , 0.0 , 1.0 );
			float Charring142 = (clampResult137*2.0 + -1.0);
			o.Albedo = ( tex2D( _MainTex, uv_MainTex ) * Charring142 ).rgb;
			float clampResult118 = clamp( ( 1.0 - ( distance( GradientNoise104 , _FlameOffset ) / _FlameWidth ) ) , 0.0 , 1.0 );
			float4 temp_output_120_0 = ( clampResult118 * _FlameColor * 2.0 );
			float4 FlameColor126 = ( ( temp_output_120_0 * temp_output_120_0 ) * _FlameIntensity );
			o.Emission = FlameColor126.rgb;
			o.Metallic = _Matallic;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
			clip( step( 0.5 , GradientNoise104 ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
2;143;1522;785;3270.352;-1151.726;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;4;-3379.19,592.6132;Inherit;False;2200.86;1190.064;VAT;35;39;38;37;36;35;34;33;32;31;30;29;28;27;26;25;24;23;22;21;20;19;18;17;16;15;14;13;12;11;10;9;8;7;6;5;VAT;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;70;-3344.871,-659.484;Inherit;False;1618.665;872.0184;Gradient;20;90;89;88;87;86;85;82;81;80;79;78;77;76;75;74;73;72;71;109;110;Gradient;0.1999999,1,0,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;6;-3304.916,642.6132;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-3329.19,779.121;Inherit;False;Property;_Speed;Speed;9;0;Create;True;0;0;False;0;False;0;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;72;-3309.601,-635.9191;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;71;-3330.492,-492.4884;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-3125.09,655.6212;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;75;-3319.783,-28.54308;Inherit;False;1;0;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;9;-2976.355,654.7307;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-3019.734,818.0773;Inherit;False;Property;_FrameCount;FrameCount;19;0;Create;True;0;0;False;0;False;0;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;73;-3077.083,-593.8286;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-3102.305,-451.2341;Inherit;False;Property;_PivotOffset;PivotOffset;18;0;Create;True;0;0;False;0;False;0;0.94;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;79;-3158.297,-98.37614;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-2783.115,647.5132;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;100;-3287.612,2131.099;Inherit;False;1845.309;652.605;Noise;12;151;150;149;148;97;94;92;93;153;156;157;158;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-3282.67,115.0737;Inherit;False;Property;_Spread;Spread;16;0;Create;True;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-2798.103,-390.1119;Inherit;False;Property;_ObjectScale;ObjectScale;17;0;Create;True;0;0;False;0;False;1;30;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;109;-2913.305,-576.2341;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-3287.58,-343.0918;Inherit;False;Property;_ChangeAmount;ChangeAmount;13;0;Create;True;0;0;False;0;False;0.5126595;0.4;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;82;-3236.922,-259.3763;Inherit;False;Property;_MANNULCONTROL;MANNULCONTROL;15;0;Create;True;0;0;False;0;False;0;1;0;True;;Toggle;2;Key0;Key1;Create;False;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CeilOpNode;11;-2627.115,665.5132;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;81;-3091.667,-10.8026;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;76;-2769.001,-523.7408;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;157;-3103.865,2527.44;Inherit;False;0;151;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;12;-2508.215,673.9404;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;85;-2918.07,-157.4597;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;151;-2859.542,2512.324;Inherit;True;Property;_FlowMap;FlowMap;26;0;Create;True;0;0;False;0;False;-1;None;75c11ff777c73f745a290b5eb6b2723f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;80;-2636.551,-605.4948;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;86;-2309.797,-559.0159;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;13;-2374.792,808.9714;Inherit;False;2;0;FLOAT;-1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;14;-2354.705,671.9925;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;153;-2469.729,2468.344;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TexturePropertyNode;149;-2759.852,2171.47;Inherit;True;Property;_Noise;Noise;28;0;Create;True;0;0;False;0;False;None;6e9e3841a0552a34cb7c38b3628da853;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TextureCoordinatesNode;150;-2769.193,2365.588;Inherit;False;0;149;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;156;-2270.735,2670.918;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;27;0;Create;True;0;0;False;0;False;0;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;92;-2479.814,2637.201;Inherit;False;Property;_NoiseStrength;NoiseStrength;14;0;Create;True;0;0;False;0;False;0,0;0.5,-1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;87;-2300.641,148.8191;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-2491.38,47.8269;Inherit;False;Constant;_Float1;Float 1;15;0;Create;True;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;148;-2226.411,2269.253;Inherit;False;Flow;1;;1;acad10cc8145e1f4eb8042bebe2d9a42;2,51,0,50,0;5;5;SAMPLER2D;;False;2;FLOAT2;0,0;False;18;FLOAT2;0,0;False;17;FLOAT2;1,1;False;24;FLOAT;0.2;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-2175.793,727.9713;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-2102.871,-23.85148;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-2036.305,727.0926;Inherit;False;CurrentFrame;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;158;-1951.227,2329.707;Inherit;False;FLOAT;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;17;-3282.954,964.903;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;97;-1757.924,2216.248;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;-2009.24,-153.0666;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-3270.954,1104.903;Inherit;False;16;CurrentFrame;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;105;-3344.632,2865.198;Inherit;False;735.1746;360.8359;GradientNoise;4;101;102;103;104;GradientNoise;0.0787197,0.8235294,0.2379548,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;-3294.632,2915.198;Inherit;False;90;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;19;-2930.953,985.5812;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-3287.896,3037.034;Inherit;False;97;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-2757.953,982.903;Inherit;False;UV_VAT;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;103;-3094.896,2973.034;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;104;-2854.458,3020.988;Inherit;False;GradientNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;112;-3339.908,3376.304;Inherit;False;1852.461;539.8671;FlameColor;14;121;120;125;124;123;122;118;117;119;116;115;114;113;126;FlameColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;-3286.264,1329.315;Inherit;False;20;UV_VAT;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-2671.171,1419.709;Inherit;False;Property;_BoudingMin;BoudingMin;10;0;Create;True;0;0;False;0;False;0;-2.653735;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;128;-3333.772,4114.502;Inherit;False;1852.461;539.8671;Charring;10;142;137;133;132;131;130;129;144;145;147;Charring;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-3303.908,3585.072;Inherit;False;Property;_FlameOffset;FlameOffset;20;0;Create;True;0;0;False;0;False;0.5;0.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;24;-2997.023,1210.677;Inherit;True;Property;_VAT_POS;VAT_POS;7;0;Create;True;0;0;False;0;False;-1;None;0680b1a9af24f4442b4e252b528cf1db;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;22;-2673.871,1318.859;Inherit;False;Property;_BoudingMax;BoudingMax;11;0;Create;True;0;0;False;0;False;0;1.072085;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;-3303.621,3440.934;Inherit;False;104;GradientNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;33;-2972.023,1552.677;Inherit;True;Property;_VAT_NORMAL;VAT_NORMAL;8;0;Create;True;0;0;False;0;False;-1;None;908c9706f47c33a4aa4a2f048c2d4f90;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;115;-3100.148,3525.381;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-3283.772,4330.27;Inherit;False;Property;_CharringOffset;CharringOffset;24;0;Create;True;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;26;-2455.081,1323.038;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;130;-3297.486,4179.133;Inherit;False;104;GradientNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-3206.306,3711.37;Inherit;False;Property;_FlameWidth;FlameWidth;21;0;Create;True;0;0;False;0;False;0.1;0.2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;25;-2668.401,1192.443;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;37;-2652.482,1572.008;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DistanceOpNode;132;-3094.013,4263.58;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;116;-2893.797,3497.695;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;131;-3200.17,4449.568;Inherit;False;Property;_CharringWidth;CharringWidth;25;0;Create;True;0;0;False;0;False;0.1;0.5;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-2300.081,1219.038;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;133;-2887.662,4235.894;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;34;-2454.945,1573.032;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-2847.828,4484.912;Inherit;False;Constant;_Float3;Float 3;23;0;Create;True;0;0;False;0;False;0.25;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;117;-2677.49,3504.439;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-2163.882,1454.995;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;118;-2481.188,3504.982;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;144;-2648.828,4287.912;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;121;-2516.794,3650.213;Inherit;False;Property;_FlameColor;FlameColor;22;0;Create;True;0;0;False;0;False;0,0,0,0;0.6470588,0.4764348,0.334,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;122;-2447.501,3829.481;Inherit;False;Constant;_Float0;Float 0;19;0;Create;True;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;29;-2073.335,1347.782;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;36;-2243.08,1569.961;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NegateNode;30;-1818.724,1329.153;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;137;-2432.053,4277.181;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;-2265.37,3528.134;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NegateNode;38;-1987.203,1553.585;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;147;-2202.609,4360.796;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;-1659.724,1330.153;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-2160.17,3701.594;Inherit;False;Property;_FlameIntensity;FlameIntensity;23;0;Create;True;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;39;-1808.089,1558.703;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-2070.484,3540.49;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-1904.398,3560.421;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-1633.187,1552.444;Inherit;False;VAT_VertexNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;142;-1723.873,4296.958;Inherit;False;Charring;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-1446.33,1327.517;Inherit;False;VAT_VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;45;-672.2175,651.5236;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;40;-589.5779,405.9535;Inherit;False;32;VAT_VertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-689.5392,827.8911;Inherit;False;35;VAT_VertexNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;143;-267.0313,-383.0951;Inherit;False;142;Charring;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;-1067.68,338.9789;Inherit;False;104;GradientNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;-1730.008,3558.76;Inherit;False;FlameColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-683.1682,553.5679;Inherit;False;Property;_WindIntensity;WindIntensity;12;0;Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-580.1763,-315.6853;Inherit;True;Property;_MainTex;MainTex;4;0;Create;True;0;0;False;0;False;-1;None;de5969b59a7d5db48b198da3aa63c061;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;-75.1911,-246.9799;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;127;-397.2195,23.62991;Inherit;False;126;FlameColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;-386.3998,953.1637;Inherit;False;97;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;108;-820.0284,270.5694;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-289.22,467.6155;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;44;-154.22,695.6155;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-430.056,204.8814;Inherit;False;Property;_Matallic;Matallic;6;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-384.1993,305.0425;Inherit;False;Property;_Smoothness;Smoothness;5;0;Create;True;0;0;False;0;False;0;0.125;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;94;-2946.81,2242.569;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;93;-3237.612,2181.099;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Flag_Burn;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;False;Opaque;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;7;0;6;0
WireConnection;7;1;5;0
WireConnection;9;0;7;0
WireConnection;73;0;72;2
WireConnection;73;1;71;2
WireConnection;79;0;75;0
WireConnection;10;0;9;0
WireConnection;10;1;8;0
WireConnection;109;0;73;0
WireConnection;109;1;110;0
WireConnection;82;1;79;0
WireConnection;82;0;77;0
WireConnection;11;0;10;0
WireConnection;81;0;78;0
WireConnection;76;0;109;0
WireConnection;76;1;74;0
WireConnection;12;0;11;0
WireConnection;85;0;82;0
WireConnection;85;3;81;0
WireConnection;151;1;157;0
WireConnection;80;0;76;0
WireConnection;86;0;80;0
WireConnection;86;1;85;0
WireConnection;13;1;8;0
WireConnection;14;0;12;0
WireConnection;14;1;8;0
WireConnection;153;0;151;1
WireConnection;153;1;151;2
WireConnection;87;0;86;0
WireConnection;87;1;78;0
WireConnection;148;5;149;0
WireConnection;148;2;150;0
WireConnection;148;18;153;0
WireConnection;148;17;92;0
WireConnection;148;24;156;0
WireConnection;15;0;14;0
WireConnection;15;1;13;0
WireConnection;89;0;87;0
WireConnection;89;1;88;0
WireConnection;16;0;15;0
WireConnection;158;0;148;0
WireConnection;97;0;158;0
WireConnection;90;0;89;0
WireConnection;19;0;17;1
WireConnection;19;1;18;0
WireConnection;20;0;19;0
WireConnection;103;0;101;0
WireConnection;103;1;102;0
WireConnection;104;0;103;0
WireConnection;24;1;21;0
WireConnection;33;1;21;0
WireConnection;115;0;119;0
WireConnection;115;1;113;0
WireConnection;26;0;22;0
WireConnection;26;1;23;0
WireConnection;25;0;24;0
WireConnection;37;0;33;0
WireConnection;132;0;130;0
WireConnection;132;1;129;0
WireConnection;116;0;115;0
WireConnection;116;1;114;0
WireConnection;27;0;25;0
WireConnection;27;1;26;0
WireConnection;133;0;132;0
WireConnection;133;1;131;0
WireConnection;34;0;37;0
WireConnection;117;0;116;0
WireConnection;28;0;27;0
WireConnection;28;1;23;0
WireConnection;118;0;117;0
WireConnection;144;0;133;0
WireConnection;144;1;145;0
WireConnection;29;0;28;0
WireConnection;36;0;34;0
WireConnection;30;0;29;0
WireConnection;137;0;144;0
WireConnection;120;0;118;0
WireConnection;120;1;121;0
WireConnection;120;2;122;0
WireConnection;38;0;36;0
WireConnection;147;0;137;0
WireConnection;31;0;30;0
WireConnection;39;0;38;0
WireConnection;39;1;36;2
WireConnection;39;2;36;1
WireConnection;123;0;120;0
WireConnection;123;1;120;0
WireConnection;125;0;123;0
WireConnection;125;1;124;0
WireConnection;35;0;39;0
WireConnection;142;0;147;0
WireConnection;32;0;31;0
WireConnection;126;0;125;0
WireConnection;146;0;1;0
WireConnection;146;1;143;0
WireConnection;108;1;106;0
WireConnection;43;0;40;0
WireConnection;43;1;42;0
WireConnection;44;0;41;0
WireConnection;44;1;45;0
WireConnection;44;2;42;0
WireConnection;94;0;93;0
WireConnection;0;0;146;0
WireConnection;0;2;127;0
WireConnection;0;3;2;0
WireConnection;0;4;3;0
WireConnection;0;10;108;0
WireConnection;0;11;43;0
WireConnection;0;12;44;0
ASEEND*/
//CHKSM=7DAF90508A66F51881FF6013035815B5877DBE38