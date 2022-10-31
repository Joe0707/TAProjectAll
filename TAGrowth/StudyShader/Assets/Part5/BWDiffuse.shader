Shader "Hidden/BWDiffuse"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_bwBlend("Black & White blend", Range(0,1)) = 0
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			uniform float _bwBlend;

			fixed4 frag (v2f_img i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv);

				float lum = c.r*0.3+c.g*.59+c.b*.11; // 得到颜色的亮度值

				float4 bw = float4(lum, lum, lum, 1); // 从颜色的亮度值构造一个该亮度值的灰色

				float4 result = lerp(c,bw,_bwBlend);

				return result;
			}
			ENDCG
		}
	}
}
