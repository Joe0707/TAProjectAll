// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "HolegramDepthMask"
{
	Properties
	{
		_GlicthTex("GlicthTex", 2D) = "white" {}
		_GlicthWidth("GlicthWidth", Float) = 0
		_GlicthHardness("GlicthHardness", Float) = 1
		_GlicthSpeed("GlicthSpeed", Float) = 0
		_GlicthFreq("GlicthFreq", Float) = 2
		_ScanlineVertexOffset("ScanlineVertexOffset", Vector) = (0,0,0,0)
		_RandomTilling("RandomTilling", Float) = 3
		_RandomVertexOffset("RandomVertexOffset", Vector) = (0,0,0,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		ZWrite On
		Blend SrcAlpha OneMinusSrcAlpha
		
		ColorMask 0
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
		};

		uniform float3 _RandomVertexOffset;
		uniform float _RandomTilling;
		uniform float3 _ScanlineVertexOffset;
		uniform sampler2D _GlicthTex;
		uniform float _GlicthFreq;
		uniform float _GlicthSpeed;
		uniform float _GlicthWidth;
		uniform float _GlicthHardness;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 viewToObjDir115 = mul( UNITY_MATRIX_T_MV, float4( _RandomVertexOffset, 0 ) ).xyz;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float mulTime102 = _Time.y * -2.5;
			float mulTime105 = _Time.y * -2.0;
			float2 appendResult103 = (float2((ase_worldPos.y*_RandomTilling + mulTime102) , mulTime105));
			float simplePerlin2D104 = snoise( appendResult103 );
			simplePerlin2D104 = simplePerlin2D104*0.5 + 0.5;
			float3 objToWorld116 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime117 = _Time.y * -5.0;
			float mulTime120 = _Time.y * -1.0;
			float2 appendResult122 = (float2((( objToWorld116.x + objToWorld116.y + objToWorld116.z )*200.0 + mulTime117) , mulTime120));
			float simplePerlin2D123 = snoise( appendResult122 );
			simplePerlin2D123 = simplePerlin2D123*0.5 + 0.5;
			float clampResult130 = clamp( (simplePerlin2D123*2.0 + -1.0) , 0.0 , 1.0 );
			float temp_output_131_0 = ( (simplePerlin2D104*2.0 + -1.0) * clampResult130 );
			float2 break132 = appendResult103;
			float2 appendResult135 = (float2(( 20.0 * break132.x ) , break132.y));
			float simplePerlin2D136 = snoise( appendResult135 );
			simplePerlin2D136 = simplePerlin2D136*0.5 + 0.5;
			float clampResult138 = clamp( (simplePerlin2D136*2.0 + -1.0) , 0.0 , 1.0 );
			float3 GlitchVertexOffset111 = ( ( viewToObjDir115 * 0.01 ) * ( temp_output_131_0 + ( temp_output_131_0 * clampResult138 ) ) );
			float3 viewToObjDir151 = mul( UNITY_MATRIX_T_MV, float4( _ScanlineVertexOffset, 0 ) ).xyz;
			float3 objToWorld2_g23 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime7_g23 = _Time.y * _GlicthSpeed;
			float2 appendResult9_g23 = (float2(0.5 , (( ase_worldPos.y - objToWorld2_g23.y )*_GlicthFreq + mulTime7_g23)));
			float clampResult23_g23 = clamp( ( ( tex2Dlod( _GlicthTex, float4( appendResult9_g23, 0, 0.0) ).r - _GlicthWidth ) * _GlicthHardness ) , 0.0 , 1.0 );
			float3 ScanlineGlitch154 = ( ( viewToObjDir151 * 0.01 ) * clampResult23_g23 );
			v.vertex.xyz += ( GlitchVertexOffset111 + ScanlineGlitch154 );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
7;29;1522;788;6519.31;863.7655;5.23444;True;False
Node;AmplifyShaderEditor.CommentaryNode;141;-2608.437,1158.592;Inherit;False;3100.969;1493.713;GlicthVertexOffset;35;101;99;102;100;105;116;119;103;118;117;120;121;134;132;133;122;135;123;136;129;104;130;106;137;131;138;108;110;139;115;140;109;107;111;162;RandomGlicth;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-2558.437,1413.763;Inherit;False;Property;_RandomTilling;RandomTilling;7;0;Create;True;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;102;-2522.009,1519.177;Inherit;False;1;0;FLOAT;-2.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;99;-2540.899,1208.592;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;105;-2272.018,1510.171;Inherit;False;1;0;FLOAT;-2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;100;-2308.56,1334.681;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;116;-2348.842,1678.608;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;103;-2041.008,1296.177;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;117;-2210.843,1971.609;Inherit;False;1;0;FLOAT;-5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-2210.843,1846.608;Inherit;False;Constant;_Tilling1;Tilling;2;0;Create;True;0;0;False;0;False;200;200;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;119;-2106.842,1699.608;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;132;-1917.425,2236.061;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;134;-1808.322,2146.501;Inherit;False;Constant;_Float1;Float 1;26;0;Create;True;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;121;-1943.842,1704.608;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;120;-1901.842,1998.609;Inherit;False;1;0;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-1611.286,2214.894;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;122;-1717.477,1727.62;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;135;-1425.881,2257.917;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;123;-1580.219,1749.361;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;136;-1153.298,2288.426;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;104;-1827.008,1311.177;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;129;-1306.417,1798.544;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;137;-862.1183,2332.655;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;106;-1516.018,1421.171;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;155;-2570.661,-46.49376;Inherit;False;1439.854;963.3514;ScanlineOffset;12;150;151;154;149;142;152;153;144;147;148;145;146;ScanlineOffset;1,1,1,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;138;-580.4374,2380.832;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;130;-1088.417,1841.544;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;108;-858.2543,1229.205;Inherit;False;Property;_RandomVertexOffset;RandomVertexOffset;8;0;Create;True;0;0;False;0;False;0,0,0;-3,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;149;-2289.552,3.506255;Inherit;False;Property;_ScanlineVertexOffset;ScanlineVertexOffset;6;0;Create;True;0;0;False;0;False;0,0,0;-2.5,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.VertexToFragmentNode;162;-343.8649,2441.049;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;-951.3563,1571.207;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-2520.661,561.116;Inherit;False;Property;_GlicthFreq;GlicthFreq;5;0;Create;True;0;0;False;0;False;2;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;115;-613.6644,1246.696;Inherit;False;View;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;144;-2502.408,338.9133;Inherit;True;Property;_GlicthTex;GlicthTex;1;0;Create;True;0;0;False;0;False;None;afb16754b93daf04187b10b438f7a250;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TransformDirectionNode;151;-2044.962,20.99625;Inherit;False;View;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;148;-2511.359,642.022;Inherit;False;Property;_GlicthSpeed;GlicthSpeed;4;0;Create;True;0;0;False;0;False;0;-0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-2418.94,801.8569;Inherit;False;Property;_GlicthHardness;GlicthHardness;3;0;Create;True;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;146;-2456.94,725.8569;Inherit;False;Property;_GlicthWidth;GlicthWidth;2;0;Create;True;0;0;False;0;False;0;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-573.7879,1490.053;Inherit;False;Constant;_Float0;Float 0;26;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-2005.085,264.3541;Inherit;False;Constant;_Float2;Float 0;26;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-258.2987,1889.771;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;140;-177.3407,1684.435;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-354.3105,1362.171;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;-1785.608,136.472;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;142;-2059.648,417.847;Inherit;True;Scanline;-1;;23;41d3502ec500f8841bf8ae0f314f26cf;0;6;20;SAMPLER2D;0;False;16;FLOAT;0;False;18;FLOAT;2;False;19;FLOAT;1;False;21;FLOAT;0;False;22;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;-1585.402,320.8322;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;23.97242,1477.743;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;154;-1374.807,355.8012;Inherit;False;ScanlineGlitch;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;220.5321,1515.814;Inherit;False;GlitchVertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;225.9836,666.4054;Inherit;False;154;ScanlineGlitch;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;229.0512,518.9487;Inherit;False;111;GlitchVertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;156;488.9836,593.4054;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;567.6025,5.55265;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;HolegramDepthMask;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;1;False;21;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;Transparent;All;14;all;False;False;False;False;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;100;0;99;2
WireConnection;100;1;101;0
WireConnection;100;2;102;0
WireConnection;103;0;100;0
WireConnection;103;1;105;0
WireConnection;119;0;116;1
WireConnection;119;1;116;2
WireConnection;119;2;116;3
WireConnection;132;0;103;0
WireConnection;121;0;119;0
WireConnection;121;1;118;0
WireConnection;121;2;117;0
WireConnection;133;0;134;0
WireConnection;133;1;132;0
WireConnection;122;0;121;0
WireConnection;122;1;120;0
WireConnection;135;0;133;0
WireConnection;135;1;132;1
WireConnection;123;0;122;0
WireConnection;136;0;135;0
WireConnection;104;0;103;0
WireConnection;129;0;123;0
WireConnection;137;0;136;0
WireConnection;106;0;104;0
WireConnection;138;0;137;0
WireConnection;130;0;129;0
WireConnection;162;0;138;0
WireConnection;131;0;106;0
WireConnection;131;1;130;0
WireConnection;115;0;108;0
WireConnection;151;0;149;0
WireConnection;139;0;131;0
WireConnection;139;1;162;0
WireConnection;140;0;131;0
WireConnection;140;1;139;0
WireConnection;109;0;115;0
WireConnection;109;1;110;0
WireConnection;152;0;151;0
WireConnection;152;1;150;0
WireConnection;142;20;144;0
WireConnection;142;18;147;0
WireConnection;142;19;148;0
WireConnection;142;21;146;0
WireConnection;142;22;145;0
WireConnection;153;0;152;0
WireConnection;153;1;142;0
WireConnection;107;0;109;0
WireConnection;107;1;140;0
WireConnection;154;0;153;0
WireConnection;111;0;107;0
WireConnection;156;0;112;0
WireConnection;156;1;157;0
WireConnection;0;11;156;0
ASEEND*/
//CHKSM=54F5332A001CFB6D3CA2AFC1C847389C93521C39