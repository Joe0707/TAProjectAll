Shader "Unlit/TestFB"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_OutlineWidth("Outline Width",Float) =7.0
		_OutlineColor("Outline Color",Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			// Cull Front
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
		Pass
		{
			Cull Front
			// ColorMask 0
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#include "AutoLight.cginc"
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord0 : TEXCOORD0;
				float3 normal : NORMAL;
				float4 color : COLOR;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 vertex_color:TEXCOORD3;
			};

			sampler2D _BaseMap;
			sampler2D _SSSMap;
			sampler2D _ILMMap;
			float _OutlineWidth;
			float4 _OutlineColor;
			float _OutlineZBias;
			v2f vert (appdata v)
			{
				v2f o;
				float3 pos_view = UnityObjectToViewPos(v.vertex);
				float3 normal_world = UnityObjectToWorldNormal(v.normal);
				float3 outline_dir = normalize(mul((float3x3)UNITY_MATRIX_V,normal_world));
				// outline_dir.z = _OutlineZBias*(1.0-v.color.b);
				pos_view += outline_dir*_OutlineWidth;
				o.pos = mul(UNITY_MATRIX_P,float4(pos_view,1));
				// o.pos = mul(UNITY_MATRIX_VP,float4(pos_world,1));
				o.uv = v.texcoord0;
				o.vertex_color = v.color;
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{				
				float3 basecolor = tex2D(_BaseMap,i.uv.xy).xyz;
				half maxComponent = max(max(basecolor.r,basecolor.g),basecolor.b)-0.004;
				half3 saturatedColor = step(maxComponent.rrr,basecolor)*basecolor;
				saturatedColor = lerp(basecolor.rgb,saturatedColor,0.6);
				half3 outlineColor = 0.8*saturatedColor*basecolor*_OutlineColor.xyz;
				return float4(outlineColor,1.0);

				// return float4(0,0,0,1.0);
			}
			ENDCG
		}

	}
}
