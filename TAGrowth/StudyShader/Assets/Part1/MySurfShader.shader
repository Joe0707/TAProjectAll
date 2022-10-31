Shader "Part 1/My Surface Shader"
{
	Properties // 属性类型不区分大小写
	{
		// 此处设置的属性将被显示在Shader所在的Material的属性面板上
		// 属性的语法格式：属性的变量名(属性的显示名称, 属性的类型) = 属性的初始值
		// 属性的变量名：在Shader中使用的名称
		// 属性的显示名称：在Material的面板上显示的名称
		_MainTex("我的纹理", 2D) = "white"{}
		//_MyTexture2("我的纹理2", 2D) = "bump"{}
		_MyInt("我的整数", int) = 2
		_MyRange("在范围内调节", range(-1,1)) = 0
		_MyColor("调节颜色", color) = (0,0,1,1) // new Color(r,g,b,a)
		_MyVector("设置向量", vector) = (1,1,1,1) // new Vector(x,y,z,w)
	}
	
	SubShader // Shader程序区分大小写
	{
		Tags
		{
			"Queue" = "Geometry"
			"RenderType" = "Opaque"
		}
		
	
		// 此处编写Shader代码
		CGPROGRAM
		
		#pragma surface surf Lambert
		
		sampler2D _MainTex;
		
		struct Input
		{
			float2 uv_MainTex;
		};
		
		void surf(Input IN, inout SurfaceOutput o)
		{
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex);
		}
		
		ENDCG
	}
}