// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Vice"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Vice_BaseColor("Vice_BaseColor", 2D) = "white" {}
		_Vice_NormalMap("Vice_NormalMap", 2D) = "bump" {}
		_Vice_Roughness("Vice_Roughness", 2D) = "white" {}
		_Grow1("Grow", Range( -2 , 2)) = 0
		_GrouMin1("GrouMin", Range( 0 , 1)) = 0
		_GrowMax1("GrowMax", Range( 0 , 1.5)) = 0.9176471
		_EndMin1("EndMin", Range( 0 , 1)) = 0
		_EndMax1("EndMax", Range( 0 , 1.5)) = 0
		_Offset("Offset", Float) = 0
		_Scale("Scale", Float) = 0
		_Plane_BaseColor("Plane_BaseColor", 2D) = "white" {}
		_Plane_NormalMap("Plane_NormalMap", 2D) = "bump" {}
		_Plane_Smoothness("Plane_Smoothness", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" }
		Cull Off
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float _GrouMin1;
		uniform float _GrowMax1;
		uniform float _Grow1;
		uniform float _EndMin1;
		uniform float _EndMax1;
		uniform float _Offset;
		uniform float _Scale;
		uniform sampler2D _Plane_NormalMap;
		uniform sampler2D _Plane_BaseColor;
		uniform float4 _Plane_BaseColor_ST;
		uniform sampler2D _Vice_NormalMap;
		uniform sampler2D _Vice_BaseColor;
		uniform float4 _Vice_BaseColor_ST;
		uniform sampler2D _Plane_Smoothness;
		uniform sampler2D _Vice_Roughness;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float temp_output_68_0 = ( v.texcoord.xy.y - _Grow1 );
			float smoothstepResult74 = smoothstep( _GrouMin1 , _GrowMax1 , temp_output_68_0);
			float smoothstepResult73 = smoothstep( _EndMin1 , _EndMax1 , v.texcoord.xy.y);
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( ( max( smoothstepResult74 , smoothstepResult73 ) * ( ase_vertexNormal * 0.01 * _Offset ) ) + ( ase_vertexNormal * _Scale ) );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Plane_BaseColor = i.uv_texcoord * _Plane_BaseColor_ST.xy + _Plane_BaseColor_ST.zw;
			float2 uv_Vice_BaseColor = i.uv_texcoord * _Vice_BaseColor_ST.xy + _Vice_BaseColor_ST.zw;
			float3 ase_worldPos = i.worldPos;
			float clampResult47 = clamp( ( ase_worldPos.y / 0.1 ) , 0.0 , 1.0 );
			float Lerpfactor52 = clampResult47;
			float3 lerpResult54 = lerp( UnpackNormal( tex2D( _Plane_NormalMap, uv_Plane_BaseColor ) ) , UnpackNormal( tex2D( _Vice_NormalMap, uv_Vice_BaseColor ) ) , Lerpfactor52);
			float3 normal60 = lerpResult54;
			o.Normal = normal60;
			float4 lerpResult51 = lerp( tex2D( _Plane_BaseColor, uv_Plane_BaseColor ) , tex2D( _Vice_BaseColor, uv_Vice_BaseColor ) , Lerpfactor52);
			float4 albedo59 = lerpResult51;
			o.Albedo = albedo59.rgb;
			float lerpResult55 = lerp( tex2D( _Plane_Smoothness, uv_Plane_BaseColor ).r , tex2D( _Vice_Roughness, uv_Vice_BaseColor ).r , Lerpfactor52);
			float smoothness61 = ( 1.0 - lerpResult55 );
			o.Smoothness = smoothness61;
			o.Alpha = 1;
			float temp_output_68_0 = ( i.uv_texcoord.y - _Grow1 );
			clip( ( 1.0 - temp_output_68_0 ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
7;482;1570;504;2049.048;1537.121;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;56;-3056.164,-349.5388;Inherit;False;1071.173;323.2141;LerpFactor;5;44;48;49;47;52;LerpFactor;0,1,0.1310344,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;44;-3006.164,-299.5388;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;49;-2993.94,-141.3246;Inherit;False;Constant;_Float2;Float 2;13;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;48;-2782.94,-229.3246;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;47;-2571.648,-247.0225;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;65;-1693.238,227.6272;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;66;-1722.238,399.6272;Inherit;False;Property;_Grow1;Grow;4;0;Create;True;0;0;False;0;False;0;0.76;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-2353.467,-242.6484;Inherit;False;Lerpfactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;31;-2075.934,-686.5502;Inherit;False;0;2;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;50;-1920.066,-1506.419;Inherit;False;0;41;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;67;-1441.533,519.8787;Inherit;False;Property;_GrouMin1;GrouMin;5;0;Create;True;0;0;False;0;False;0;0.295;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-1324.032,914.3269;Inherit;False;Property;_EndMin1;EndMin;7;0;Create;True;0;0;False;0;False;0;0.593;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;43;-1312.322,-1253.787;Inherit;True;Property;_Plane_Smoothness;Plane_Smoothness;13;0;Create;True;0;0;False;0;False;-1;5b69da41deae6fc468efafdbfb3d62ac;5b69da41deae6fc468efafdbfb3d62ac;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;68;-1351.777,300.7411;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-1352.234,618.8787;Inherit;False;Property;_GrowMax1;GrowMax;6;0;Create;True;0;0;False;0;False;0.9176471;0.683;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-1296.994,-381.3554;Inherit;True;Property;_Vice_Roughness;Vice_Roughness;3;0;Create;True;0;0;False;0;False;-1;79722df8209c0d8419cec564ccf46330;79722df8209c0d8419cec564ccf46330;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;53;-919.8172,-864.8002;Inherit;False;52;Lerpfactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-1250.032,1038.327;Inherit;False;Property;_EndMax1;EndMax;8;0;Create;True;0;0;False;0;False;0;1.386;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;70;-1391.84,757.0078;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;8;-601.1301,1122.868;Inherit;False;Property;_Offset;Offset;9;0;Create;True;0;0;False;0;False;0;-7.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;6;-589.7239,877.2319;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;42;-1324.488,-1514.219;Inherit;True;Property;_Plane_NormalMap;Plane_NormalMap;12;0;Create;True;0;0;False;0;False;-1;c886840aa65cea14ab7494ed2314b46f;c886840aa65cea14ab7494ed2314b46f;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;41;-1312.859,-1797.059;Inherit;True;Property;_Plane_BaseColor;Plane_BaseColor;11;0;Create;True;0;0;False;0;False;-1;c8461f3ab2ff47c489e4aeaf88a5e05d;c8461f3ab2ff47c489e4aeaf88a5e05d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;73;-976.1164,790.2659;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-606.7262,1027.67;Inherit;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;55;-511.8128,-386.0623;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1330.812,-657.6849;Inherit;True;Property;_Vice_NormalMap;Vice_NormalMap;2;0;Create;True;0;0;False;0;False;-1;8e0b8dd8a1fb4cd4784b58ca8409871e;8e0b8dd8a1fb4cd4784b58ca8409871e;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;74;-1021.721,469.4929;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-1318.629,-979.6174;Inherit;True;Property;_Vice_BaseColor;Vice_BaseColor;1;0;Create;True;0;0;False;0;False;-1;af42bface2e2f5a4cbff1e6bada59ab0;af42bface2e2f5a4cbff1e6bada59ab0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;30;-105.24,1399.179;Inherit;False;Property;_Scale;Scale;10;0;Create;True;0;0;False;0;False;0;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;54;-471.3544,-887.0155;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;4;-323.8513,-381.717;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;28;-133.24,1238.179;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;51;-468.0634,-1569.431;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-323.8021,885.18;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;75;-758.1264,697.6583;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;-190.9084,-1576.148;Inherit;False;albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;130.76,1265.179;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-78.86981,734.8433;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-150.6382,-903.8654;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;61;-119.5546,-381.2723;Inherit;False;smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;280.76,987.1791;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;496.6432,84.54669;Inherit;False;60;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;62;520.415,-9.395378;Inherit;False;59;albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;485.0287,182.2717;Inherit;False;61;smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;76;-1127.478,298.2429;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;982.2411,20.94119;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Vice;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;48;0;44;2
WireConnection;48;1;49;0
WireConnection;47;0;48;0
WireConnection;52;0;47;0
WireConnection;43;1;50;0
WireConnection;68;0;65;2
WireConnection;68;1;66;0
WireConnection;3;1;31;0
WireConnection;42;1;50;0
WireConnection;41;1;50;0
WireConnection;73;0;70;2
WireConnection;73;1;72;0
WireConnection;73;2;71;0
WireConnection;55;0;43;1
WireConnection;55;1;3;1
WireConnection;55;2;53;0
WireConnection;1;1;31;0
WireConnection;74;0;68;0
WireConnection;74;1;67;0
WireConnection;74;2;69;0
WireConnection;2;1;31;0
WireConnection;54;0;42;0
WireConnection;54;1;1;0
WireConnection;54;2;53;0
WireConnection;4;0;55;0
WireConnection;51;0;41;0
WireConnection;51;1;2;0
WireConnection;51;2;53;0
WireConnection;23;0;6;0
WireConnection;23;1;9;0
WireConnection;23;2;8;0
WireConnection;75;0;74;0
WireConnection;75;1;73;0
WireConnection;59;0;51;0
WireConnection;29;0;28;0
WireConnection;29;1;30;0
WireConnection;7;0;75;0
WireConnection;7;1;23;0
WireConnection;60;0;54;0
WireConnection;61;0;4;0
WireConnection;27;0;7;0
WireConnection;27;1;29;0
WireConnection;76;0;68;0
WireConnection;0;0;62;0
WireConnection;0;1;63;0
WireConnection;0;4;64;0
WireConnection;0;10;76;0
WireConnection;0;11;27;0
ASEEND*/
//CHKSM=8FB9AB9E1E4754419822D6289C2D7E0839B9F215