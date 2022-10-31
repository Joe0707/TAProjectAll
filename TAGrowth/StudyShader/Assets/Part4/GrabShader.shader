Shader "Part 4/GrabShader"
{
	SubShader
	{
		Tags 
		{
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Opaque"
		}
		ZWrite On 
		Lighting Off 
		Cull Off 
		Fog { Mode Off } 
		Blend One Zero
		LOD 100
		
		GrabPass { "_GrabTexture" } // 在对玻璃第一遍渲染时，把整个场景拍照，绘制到一个名为_GrabTexture的纹理上

		// 将GrabPass抓取的内容贴图到当前pass
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			sampler2D _GrabTexture; // 表示在GrabPass中抓取的纹理
			
			struct VertInput
			{
				float4 vertex : POSITION;
			};
			
			struct VertOutput
			{
				float4 vertex : POSITION;
				float4 uvgrab : TEXCOORD1;
			};
			
			// 计算每个顶点相关的属性（位置、纹理坐标等）
			VertOutput vert(VertInput i)
			{
				VertOutput o;
				o.vertex = mul(UNITY_MATRIX_MVP, i.vertex);
				// ComputeGrabScreenPos：传入一个投影空间中的顶点坐标，此方法会以摄像机可视范围的左下角为纹理坐标【0，0】点，以右上角为【1，1】点，计算出当前顶点位置对应的纹理坐标
				o.uvgrab = ComputeGrabScreenPos(o.vertex);
				
				return o;
			}
			
			// 对Unity光栅化阶段经过顶点插值得到的片元（像素）的属性进行计算，得到每个片元的颜色值
			half4 frag(VertOutput i) : COLOR
			{
				return tex2Dproj(_GrabTexture, i.uvgrab);
			}
			
			ENDCG
		}
	}
}
