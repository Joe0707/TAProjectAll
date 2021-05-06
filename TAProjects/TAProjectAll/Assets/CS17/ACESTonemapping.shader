Shader "Custom/ColorAdjustEffect"
{
	Properties 
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		//_IsLieanr("IsLieanr?", Range(0,1)) = 0
		_A("A", float) = 2.51
		_B("B", float) = 0.03
		_C("C", float) = 2.43
		_D("D", float) = 0.59
		_E("E", float) = 0.14
	}
	SubShader
	{
		Pass
		{
				ZTest Always Cull Off ZWrite Off
				
				CGPROGRAM
				sampler2D _MainTex;
				float _IsLieanr;
				float _A = 2.51f;
				float _B = 0.03f;
				float _C = 2.43f;
				float _D = 0.59f;
				float _E = 0.14f;

				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				struct v2f
				{
					float4 pos : SV_POSITION;
					half2  uv : TEXCOORD0;
				};

			inline float3 ACES_Tonemapping(float3 x)
			{
				float a = 2.51f;
				float b = 0.03f;
				float c = 2.43f;
				float d = 0.59f;
				float e = 0.14f;
				float3 encode_color = saturate((x*(a*x + b)) / (x*(c*x + d) + e));
				return encode_color;
			};

				v2f vert(appdata_img v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = v.texcoord;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					float4 maincolor = tex2D(_MainTex, i.uv);
					//float3 linear_color = lerp(maincolor.rgb * maincolor.rgb,maincolor.rgb,_IsLieanr);
					float3 linear_color = pow(maincolor.rgb,2.2);
					float3 tonemapped_color = saturate((linear_color*(_A * linear_color + _B))/(linear_color*(_C * linear_color + _D) + _E));
					//float3 encode_color = lerp(sqrt(tonemapped_color),tonemapped_color,_IsLieanr);
					float3 encode_color = pow(tonemapped_color, 1.0 / 2.2);
					return float4(encode_color,1.0);
				}
				ENDCG
		}
	}
	//防止shader失效的保障措施
	FallBack Off
}