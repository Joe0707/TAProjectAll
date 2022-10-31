Shader "Part 1/Vertex and Fragment Shader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			struct VertInput
			{
				float4 pos : POSITION; // pos in object space ( local space )
			};
			
			struct VertOutput
			{
				float4 pos : SV_POSITION; // pos in projection space
			};
			
			VertOutput vert(VertInput input)
			{
				VertOutput o;
				o.pos = mul(UNITY_MATRIX_MVP, input.pos); // 把一个物体的顶点变换为投影空间的顶点
				return o;
			}
			
			half4 frag(VertOutput input) : COLOR
			{
				return half4(1,0,0,1);
			}
			
			ENDCG
		}
	}
}
