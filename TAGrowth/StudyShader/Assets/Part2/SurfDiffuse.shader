Shader "Part 2/SurfDiffuse" {
	Properties {
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		
		#pragma surface surf Lambert
		
		struct Input
		{
			float4 color : COLOR;
		};
		
		void surf(Input IN, inout SurfaceOutput o)
		{
			o.Albedo = 1;
		}
		
		ENDCG
	} 
	//FallBack "Diffuse"
}
