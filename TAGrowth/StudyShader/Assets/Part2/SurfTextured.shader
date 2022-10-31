Shader "Part 2/SurfTextured" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert
		
		struct Input
		{
			float2 uv_MainTex;
		};
		
		sampler2D _MainTex;
		
		void surf(Input IN, inout SurfaceOutput o)
		{
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex); // half3 <= float4.xyz
		}
		
		ENDCG
	} 
	FallBack "Diffuse"
}
