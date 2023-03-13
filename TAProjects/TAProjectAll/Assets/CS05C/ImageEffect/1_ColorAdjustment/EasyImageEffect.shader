// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EasyImageEffect"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_Brightness("Brightness", Float) = 0
		_Fraction("Fraction", Range( -1 , 1)) = 0
		_Contrast("Contrast", Float) = 0
		_AddTex("AddTex", 2D) = "white" {}
		_HueShift("HueShift", Range( -1 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		
		
		ZTest Always
		Cull Off
		ZWrite Off

		
		Pass
		{ 
			CGPROGRAM 

			

			#pragma vertex vert_img_custom 
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			

			struct appdata_img_custom
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				
			};

			struct v2f_img_custom
			{
				float4 pos : SV_POSITION;
				half2 uv   : TEXCOORD0;
				half2 stereoUV : TEXCOORD2;
		#if UNITY_UV_STARTS_AT_TOP
				half4 uv2 : TEXCOORD1;
				half4 stereoUV2 : TEXCOORD3;
		#endif
				
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform float _HueShift;
			uniform sampler2D _AddTex;
			uniform float4 _AddTex_ST;
			uniform float _Brightness;
			uniform float _Fraction;
			uniform float _Contrast;
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}


			v2f_img_custom vert_img_custom ( appdata_img_custom v  )
			{
				v2f_img_custom o;
				
				o.pos = UnityObjectToClipPos( v.vertex );
				o.uv = float4( v.texcoord.xy, 1, 1 );

				#if UNITY_UV_STARTS_AT_TOP
					o.uv2 = float4( v.texcoord.xy, 1, 1 );
					o.stereoUV2 = UnityStereoScreenSpaceUVAdjust ( o.uv2, _MainTex_ST );

					if ( _MainTex_TexelSize.y < 0.0 )
						o.uv.y = 1.0 - o.uv.y;
				#endif
				o.stereoUV = UnityStereoScreenSpaceUVAdjust ( o.uv, _MainTex_ST );
				return o;
			}

			half4 frag ( v2f_img_custom i ) : SV_Target
			{
				#ifdef UNITY_UV_STARTS_AT_TOP
					half2 uv = i.uv2;
					half2 stereoUV = i.stereoUV2;
				#else
					half2 uv = i.uv;
					half2 stereoUV = i.stereoUV;
				#endif	
				
				half4 finalColor;

				// ase common template code
				float2 uv_MainTex = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 uv_AddTex = i.uv.xy * _AddTex_ST.xy + _AddTex_ST.zw;
				float4 blendOpSrc17 = tex2D( _MainTex, uv_MainTex );
				float4 blendOpDest17 = tex2D( _AddTex, uv_AddTex );
				float3 desaturateInitialColor7 = ( ( saturate( ( 1.0 - ( 1.0 - blendOpSrc17 ) * ( 1.0 - blendOpDest17 ) ) )) * _Brightness ).rgb;
				float desaturateDot7 = dot( desaturateInitialColor7, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar7 = lerp( desaturateInitialColor7, desaturateDot7.xxx, _Fraction );
				float3 lerpResult14 = lerp( float3(0.5,0.5,0.5) , desaturateVar7 , _Contrast);
				float3 hsvTorgb20 = RGBToHSV( lerpResult14 );
				float3 hsvTorgb19 = HSVToRGB( float3(( _HueShift + hsvTorgb20.x ),hsvTorgb20.y,hsvTorgb20.z) );
				

				finalColor = float4( hsvTorgb19 , 0.0 );

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18500
889;257;1329;687;1861.824;555.9281;2.343703;True;False
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;2;-1206.003,-235.9662;Inherit;False;0;0;_MainTex;Shader;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-1057.089,-233.5;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;18;-1143.8,15.80865;Inherit;True;Property;_AddTex;AddTex;3;0;Create;True;0;0;False;0;False;-1;None;69e847bbff1cf5449a4ee0bbd045dbc9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;17;-694.056,-57.6109;Inherit;False;Screen;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-784.0538,211.0958;Inherit;False;Property;_Brightness;Brightness;0;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-679.5,405.5;Inherit;False;Property;_Fraction;Fraction;1;0;Create;True;0;0;False;0;False;0;-1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-554.2296,165.0696;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-262.9647,473.829;Inherit;False;Property;_Contrast;Contrast;2;0;Create;True;0;0;False;0;False;0;2.93;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;15;-238.9693,170.1189;Inherit;False;Constant;_Vector0;Vector 0;2;0;Create;True;0;0;False;0;False;0.5,0.5,0.5;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DesaturateOpNode;7;-316.5,340.5;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;14;29.81734,322.9911;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RGBToHSVNode;20;184.5092,520.2617;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;22;199.4292,354.1303;Inherit;False;Property;_HueShift;HueShift;4;0;Create;True;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;470.8292,419.9303;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;19;560.7496,542.1614;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;839.0999,529.798;Float;False;True;-1;2;ASEMaterialInspector;0;2;EasyImageEffect;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;4;0;2;0
WireConnection;17;0;4;0
WireConnection;17;1;18;0
WireConnection;5;0;17;0
WireConnection;5;1;6;0
WireConnection;7;0;5;0
WireConnection;7;1;8;0
WireConnection;14;0;15;0
WireConnection;14;1;7;0
WireConnection;14;2;16;0
WireConnection;20;0;14;0
WireConnection;21;0;22;0
WireConnection;21;1;20;1
WireConnection;19;0;21;0
WireConnection;19;1;20;2
WireConnection;19;2;20;3
WireConnection;0;0;19;0
ASEEND*/
//CHKSM=68598748A28F90CFD2C8DC1E3076D6B9E2759DB0