Shader "Hidden/DistortionDiffuse"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DisplaceTex("Displacement Map",2D) = "bump"{}
		_Strength("Strength", float) = 1
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _DisplaceTex;
			float _Strength;

			fixed4 frag (v2f_img i) : SV_Target
			{
				half2 n = tex2D(_DisplaceTex, i.uv);
				half2 d = n*2-1; // 从颜色值转为单位向量
				i.uv += d*_Strength;
				i.uv = saturate(i.uv);

				float4 c = tex2D(_MainTex, i.uv);
				
				return c;
			}
			ENDCG
		}
	}
}
