// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dissolve_Sphere"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0.5126595
		_EdgeWidth("EdgeWidth", Range( 0 , 2)) = 0.1
		_EdgeColor("EdgeColor", Color) = (0,0,0,0)
		_EegeIntensity("EegeIntensity", Float) = 2
		[Toggle(_MANNULCONTROL_ON)] _MANNULCONTROL("MANNULCONTROL", Float) = 1
		_Spread("Spread", Range( 0 , 1)) = 0
		_Noise("Noise", 2D) = "white" {}
		_Float1("Float 1", Float) = 0
		_ObjectScale("ObjectScale", Float) = 3.5
		[Toggle(_DIR_INV_ON)] _DIR_INV("DIR_INV", Float) = 0
		_Radius("Radius", Float) = 0
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
		#pragma shader_feature _DIR_INV_ON
		#pragma shader_feature _MANNULCONTROL_ON
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float4 _EdgeColor;
		uniform float _EegeIntensity;
		uniform float _Radius;
		uniform float _ObjectScale;
		uniform float _ChangeAmount;
		uniform float _Spread;
		uniform float _Float1;
		uniform sampler2D _Noise;
		uniform float4 _Noise_ST;
		uniform float _EdgeWidth;
		uniform float _Cutoff = 0.5;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 temp_cast_0 = (0.18).xxx;
			o.Albedo = temp_cast_0;
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld73 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float clampResult56 = clamp( ( ( length( ( ase_worldPos - objToWorld73 ) ) - _Radius ) / _ObjectScale ) , 0.0 , 1.0 );
			#ifdef _DIR_INV_ON
				float staticSwitch62 = ( 1.0 - clampResult56 );
			#else
				float staticSwitch62 = clampResult56;
			#endif
			float mulTime27 = _Time.y * 0.2;
			#ifdef _MANNULCONTROL_ON
				float staticSwitch29 = _ChangeAmount;
			#else
				float staticSwitch29 = frac( mulTime27 );
			#endif
			float Gradient23 = ( ( ( staticSwitch62 - (-_Spread + (staticSwitch29 - 0.0) * (1.0 - -_Spread) / (1.0 - 0.0)) ) / _Spread ) * _Float1 );
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float2 panner36 = ( 1.0 * _Time.y * float2( 0,0 ) + uv_Noise);
			float Noise38 = ( 1.0 - tex2D( _Noise, panner36 ).r );
			float temp_output_40_0 = ( Gradient23 - Noise38 );
			float clampResult15 = clamp( ( 1.0 - ( distance( temp_output_40_0 , 0.5 ) / _EdgeWidth ) ) , 0.0 , 1.0 );
			o.Emission = ( _EdgeColor * _EegeIntensity * clampResult15 ).rgb;
			o.Alpha = 1;
			clip( ( 1.0 - step( 0.5 , temp_output_40_0 ) ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
-1698;124;1521;788;3328.917;1151.881;1.678229;True;True
Node;AmplifyShaderEditor.CommentaryNode;22;-2727.338,-865.0554;Inherit;False;1618.665;872.0184;Gradient;22;57;52;23;41;42;32;4;56;8;29;31;30;5;28;51;27;58;61;62;63;67;68;;0.1999999,1,0,1;0;0
Node;AmplifyShaderEditor.TransformPositionNode;73;-2739.858,-675.2635;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;51;-2734.068,-827.4905;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;52;-2533.962,-817.194;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LengthOpNode;63;-2395.092,-823.7946;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-2449.391,-695.1095;Inherit;False;Property;_Radius;Radius;13;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;68;-2237.064,-820.4619;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-2292.569,-592.773;Inherit;False;Property;_ObjectScale;ObjectScale;11;0;Create;True;0;0;False;0;False;3.5;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;57;-2154.087,-698.6617;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;27;-2702.25,-234.1144;Inherit;False;1;0;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;28;-2540.764,-303.9475;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2715.484,-77.07182;Inherit;False;Property;_Spread;Spread;7;0;Create;True;0;0;False;0;False;0;0.19;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;56;-1998.217,-813.6662;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2679.047,-533.6632;Inherit;False;Property;_ChangeAmount;ChangeAmount;2;0;Create;True;0;0;False;0;False;0.5126595;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;61;-1735.285,-701.1797;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;31;-2474.134,-216.3739;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;29;-2619.389,-464.9476;Inherit;False;Property;_MANNULCONTROL;MANNULCONTROL;6;0;Create;True;0;0;False;0;False;0;1;0;True;;Toggle;2;Key0;Key1;Create;False;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;62;-1614.533,-824.5457;Inherit;False;Property;_DIR_INV;DIR_INV;12;0;Create;True;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;8;-2290.468,-361.3528;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-2889.034,670.2698;Inherit;False;0;33;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;37;-2864.549,868.265;Inherit;False;Constant;_NoiseSpeed;NoiseSpeed;10;0;Create;True;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;36;-2598.232,731.7399;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-1425.601,-737.0957;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1555.675,-116.8811;Inherit;False;Property;_Float1;Float 1;9;0;Create;True;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;32;-1874.475,-226.5938;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;33;-2347.07,705.245;Inherit;True;Property;_Noise;Noise;8;0;Create;True;0;0;False;0;False;-1;b518525ec3f2a154d8d7cc44a6012ab9;25943e8eca27e824d92f7f502efd8342;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;60;-2017.111,777.4677;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1627.517,-249.9515;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-1456.919,-350.3769;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-1777.693,700.0881;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-1063.571,158.9185;Inherit;False;23;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-1056.835,280.7544;Inherit;False;38;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;25;-1504.984,463.2112;Inherit;False;1324.309;471.7719;EdgeColor;6;15;14;12;10;13;11;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1454.984,678.9793;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;40;-863.835,216.7544;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;10;-1269.11,513.2111;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1404.408,823.5321;Inherit;False;Property;_EdgeWidth;EdgeWidth;3;0;Create;True;0;0;False;0;False;0.1;0.33;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;12;-1012.248,571.004;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;14;-799.8269,568.0335;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;7;-534,136;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;15;-580.2122,574.4052;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;18;-337.0524,-334.2229;Inherit;False;Property;_EdgeColor;EdgeColor;4;0;Create;True;0;0;False;0;False;0,0,0,0;0,0.8344827,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;21;-302.3826,-130.8034;Inherit;False;Property;_EegeIntensity;EegeIntensity;5;0;Create;True;0;0;False;0;False;2;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-32.98251,-174.2233;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;64;-367.0292,219.2971;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;49;-909.5839,-104.5317;Inherit;False;Property;_MainColor;MainColor;10;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;59;497.4106,-105.2889;Inherit;False;Constant;_Float2;Float 2;12;0;Create;True;0;0;False;0;False;0.18;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-978.4983,-319.8814;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;False;-1;062a1135c5d262f43b456bd8aac598fb;062a1135c5d262f43b456bd8aac598fb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-509.5457,-118.184;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;717.4764,-35.651;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Dissolve_Sphere;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;52;0;51;0
WireConnection;52;1;73;0
WireConnection;63;0;52;0
WireConnection;68;0;63;0
WireConnection;68;1;67;0
WireConnection;57;0;68;0
WireConnection;57;1;58;0
WireConnection;28;0;27;0
WireConnection;56;0;57;0
WireConnection;61;0;56;0
WireConnection;31;0;30;0
WireConnection;29;1;28;0
WireConnection;29;0;5;0
WireConnection;62;1;56;0
WireConnection;62;0;61;0
WireConnection;8;0;29;0
WireConnection;8;3;31;0
WireConnection;36;0;35;0
WireConnection;36;2;37;0
WireConnection;4;0;62;0
WireConnection;4;1;8;0
WireConnection;32;0;4;0
WireConnection;32;1;30;0
WireConnection;33;1;36;0
WireConnection;60;0;33;1
WireConnection;41;0;32;0
WireConnection;41;1;42;0
WireConnection;23;0;41;0
WireConnection;38;0;60;0
WireConnection;40;0;24;0
WireConnection;40;1;39;0
WireConnection;10;0;40;0
WireConnection;10;1;11;0
WireConnection;12;0;10;0
WireConnection;12;1;13;0
WireConnection;14;0;12;0
WireConnection;7;1;40;0
WireConnection;15;0;14;0
WireConnection;20;0;18;0
WireConnection;20;1;21;0
WireConnection;20;2;15;0
WireConnection;64;0;7;0
WireConnection;50;0;1;0
WireConnection;50;1;49;0
WireConnection;0;0;59;0
WireConnection;0;2;20;0
WireConnection;0;10;64;0
ASEEND*/
//CHKSM=FC880EFD614D09B80DFFDCF573405B33B28154D4