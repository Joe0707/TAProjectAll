// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "VAT"
{
	Properties
	{
		_VAT_POS("VAT_POS", 2D) = "white" {}
		_FrameCount("FrameCount", Float) = 0
		_Speed("Speed", Float) = 0
		_BoudingMin("BoudingMin", Float) = 0
		_BoudingMax("BoudingMax", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			half filler;
		};

		uniform sampler2D _VAT_POS;
		uniform float _Speed;
		uniform float _FrameCount;
		uniform float _BoudingMax;
		uniform float _BoudingMin;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float CurrentFrame7 = ( ( -ceil( ( frac( ( _Time.y * _Speed ) ) * _FrameCount ) ) / _FrameCount ) + ( -1.0 / _FrameCount ) );
			float2 appendResult8 = (float2(v.texcoord1.xy.x , CurrentFrame7));
			float2 UV_VAT10 = appendResult8;
			float3 appendResult23 = (float3(-( ( (tex2Dlod( _VAT_POS, float4( UV_VAT10, 0, 0.0) )).rgb * ( _BoudingMax - _BoudingMin ) ) + _BoudingMin ).x , 0.0 , 0.0));
			float3 VAT_VertexOffset40 = appendResult23;
			v.vertex.xyz += VAT_VertexOffset40;
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
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
421;764;1906;1044;2361.318;238.7136;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;47;-2577.626,-546.0948;Inherit;False;2200.86;1190.064;VAT;35;25;32;31;26;4;27;30;16;6;21;20;7;3;9;8;10;11;42;1;43;12;44;45;22;24;23;40;36;39;2;37;34;35;38;48;VAT;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-2527.626,-359.587;Inherit;False;Property;_Speed;Speed;3;0;Create;True;0;0;False;0;False;0;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;25;-2503.352,-496.0948;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-2323.526,-483.0868;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-2218.17,-320.6307;Inherit;False;Property;_FrameCount;FrameCount;2;0;Create;True;0;0;False;0;False;0;101;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;26;-2174.791,-483.9773;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1981.551,-491.1948;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CeilOpNode;30;-1825.551,-473.1948;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;16;-1706.651,-464.7675;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;21;-1573.228,-329.7367;Inherit;False;2;0;FLOAT;-1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;6;-1553.141,-466.7154;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;-1374.229,-410.7367;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;7;-1234.741,-411.6154;Inherit;False;CurrentFrame;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-2481.39,-173.8052;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;9;-2469.39,-33.80521;Inherit;False;7;CurrentFrame;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;8;-2129.389,-153.1269;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-1956.389,-155.8052;Inherit;False;UV_VAT;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;11;-2484.7,190.6073;Inherit;False;10;UV_VAT;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1872.307,180.1508;Inherit;False;Property;_BoudingMax;BoudingMax;5;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-1869.607,281.0011;Inherit;False;Property;_BoudingMin;BoudingMin;4;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-2195.459,71.96888;Inherit;True;Property;_VAT_POS;VAT_POS;0;0;Create;True;0;0;False;0;False;-1;42545dd01f563c34b8d83746bede09a2;42545dd01f563c34b8d83746bede09a2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;12;-1866.837,53.73449;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;44;-1653.517,184.3304;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-1498.517,80.33038;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-1362.318,316.2864;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;22;-1271.771,209.0738;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NegateNode;24;-1017.16,190.4451;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;23;-858.1599,191.4451;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-644.7661,188.8095;Inherit;False;VAT_VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;2;-2170.459,413.9689;Inherit;True;Property;_VAT_NORMAL;VAT_NORMAL;1;0;Create;True;0;0;False;0;False;-1;13b79923623fd524aac8d8f3bb658451;13b79923623fd524aac8d8f3bb658451;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;35;-1653.381,434.3241;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;-1;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-831.6235,413.7364;Inherit;False;VAT_VertexNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;36;-1441.516,431.2534;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SwizzleNode;34;-1850.918,433.3005;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;63.53528,251.597;Inherit;False;40;VAT_VertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;38;-1185.639,414.8774;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;37;-1006.525,419.9949;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;382.1777,9.574532;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;VAT;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;31;0;25;0
WireConnection;31;1;32;0
WireConnection;26;0;31;0
WireConnection;27;0;26;0
WireConnection;27;1;4;0
WireConnection;30;0;27;0
WireConnection;16;0;30;0
WireConnection;21;1;4;0
WireConnection;6;0;16;0
WireConnection;6;1;4;0
WireConnection;20;0;6;0
WireConnection;20;1;21;0
WireConnection;7;0;20;0
WireConnection;8;0;3;1
WireConnection;8;1;9;0
WireConnection;10;0;8;0
WireConnection;1;1;11;0
WireConnection;12;0;1;0
WireConnection;44;0;42;0
WireConnection;44;1;43;0
WireConnection;45;0;12;0
WireConnection;45;1;44;0
WireConnection;48;0;45;0
WireConnection;48;1;43;0
WireConnection;22;0;48;0
WireConnection;24;0;22;0
WireConnection;23;0;24;0
WireConnection;40;0;23;0
WireConnection;2;1;11;0
WireConnection;35;0;34;0
WireConnection;39;0;37;0
WireConnection;36;0;35;0
WireConnection;34;0;2;0
WireConnection;38;0;36;0
WireConnection;37;0;38;0
WireConnection;37;1;36;2
WireConnection;37;2;36;1
WireConnection;0;11;41;0
ASEEND*/
//CHKSM=821C521F2CD667C39FE18E3031B43ECD281A6C99