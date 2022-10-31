Shader "Part 2/SurfCircle" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Center("Center", Vector) = (0,0,0,1)
		_Radius("Radius", float) = 0.5
		_BandWidth("Band Width", float) = 0.2
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert
		
		struct Input
		{
			float2 uv_MainTex;
			float3 worldPos;
		};
		
		sampler2D _MainTex;
		float3 _Center;
		float _Radius;
		float _BandWidth;
		
		void surf(Input IN, inout SurfaceOutput o)
		{
			float d = distance(_Center, IN.worldPos);
			
			if (d >= _Radius-_BandWidth && d <= _Radius+_BandWidth)
			{
				o.Albedo = 1;
			}
			else
			{
				o.Albedo = tex2D(_MainTex, IN.uv_MainTex); // half3 <= float4.xyz
			}
		}
		
		ENDCG
	} 
	FallBack "Diffuse"
}
