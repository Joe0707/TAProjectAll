// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Part 2/SurfSnow" {
	Properties {
		_MainColor ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Bump("Bump", 2D) = "bump"{}
		_Snow("Level of Snow", Range(1,-1)) = 1
		_SnowColor("Color of Snow", Color) = (1,1,1,1)
		_SnowDirection("Direction of Snow", Vector) = (0,1,0,0)
		_SnowDepth("Depth of Snow", Range(0,0.0001)) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert vertex:vert
		
		float4 _MainColor;
		sampler2D _MainTex;
		sampler2D _Bump;
		float _Snow;
		float4 _SnowColor;
		float4 _SnowDirection;
		float _SnowDepth;
		
		void vert(inout appdata_full v)
		{
			_SnowDirection = normalize(_SnowDirection);
			_SnowDirection.w = 0;
			
			// 我们约定_SnowDirection是雪在世界空间中的方向，而物体的三角形的法线在其自身的对象空间
			// 两者不在同一个坐标系，就无法进行雪和三角形法线的夹角计算，需要进行坐标系转换！
			// unity_WorldToObject是Unity预定义的，并且传递到shader中的
			// 可以想象，从对象空间转换到世界空间的矩阵，Unity也预定义了，叫做unity_ObjectToWorld
			float4 sn = mul(unity_WorldToObject, _SnowDirection); // 由于士兵模型带缩放，所以sn要单位化
			sn = normalize(sn);
			float f = dot(v.normal, sn.xyz);
			if (f >= _Snow)
			{
				v.vertex.xyz += normalize(sn.xyz + v.normal) * _SnowDepth * f;
			}
		}
		
		struct Input{
			float2 uv_MainTex;
			float2 uv_Bump;
			float3 worldNormal;
			INTERNAL_DATA
		};
		
		void surf(Input IN, inout SurfaceOutput o)
		{
			half4 c = tex2D(_MainTex, IN.uv_MainTex);
			// UnpackNormal:纹理图采样的是颜色值，颜色值介于【0，1】，而法线介于【-1，1】，所以需要采用一个统一的方法进行转换
			o.Normal = UnpackNormal(tex2D(_Bump, IN.uv_Bump)); // 光照模型会依据此法线数据进行光照
			// 将物体自身的法线（局部坐标系）转换为其在世界空间中的法线
			float3 worldNormal = WorldNormalVector(IN, o.Normal);
			// 与雪的方向计算夹角的余弦值，将此余弦值作为光照强度系数
			float f = dot(worldNormal, _SnowDirection.xyz);
			if (f >= _Snow) // f >= 0
			{
				o.Albedo = _SnowColor.rgb;
			}
			else
			{
				o.Albedo = c.rgb;
			}
		}
		
		ENDCG
	} 
	FallBack "Diffuse"
}
