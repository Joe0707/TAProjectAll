// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CS02/Rim" //Shader的真正名字  可以是路径式的格式
{
	/*材质球参数及UI面板
	https://docs.unity3d.com/cn/current/Manual/SL-Properties.html
	https://docs.unity3d.com/cn/current/ScriptReference/MaterialPropertyDrawer.html
	*/
	Properties 
	{
		_MainTex ("Texture", 2D) = "" {}
		_MainColor("Main Color",Color) = (1,1,1,1)
		_Emiss("Emiss", Float) = 1.0
		_Speed("Speed", Vector) = (.34, .85, .92, 1)
	}
	SubShader
	{
		/*
		标签属性，有两种：一种是SubShader层级，一种在Pass层级
		https://docs.unity3d.com/cn/current/Manual/SL-SubShaderTags.html
		https://docs.unity3d.com/cn/current/Manual/SL-PassTags.html
		*/
		Tags { "Queue" = "Transparent" }
		Pass {
			Cull Off 
			ZWrite On 
			ColorMask 0
			CGPROGRAM
			float4 _Color;
			#pragma vertex vert 
			#pragma fragment frag

			float4 vert(float4 vertexPos : POSITION) : SV_POSITION
			{
				return UnityObjectToClipPos(vertexPos);
			}

			float4 frag(void) : COLOR
			{
				return _Color;
			}
			ENDCG
		}
		Pass 
		{
			//Blending:https://docs.unity3d.com/Manual/SL-Blend.html
			ZWrite Off
			//Blend SrcAlpha OneMinusSrcAlpha 
			Blend SrcAlpha One
			//Blend DstColor Zero

			CGPROGRAM  // Shader代码从这里开始	
			#pragma vertex vert //指定一个名为"vert"的函数为顶点Shader
			#pragma fragment frag //指定一个名为"frag"函数为片元Shader

			#include "UnityCG.cginc"  //引用Unity内置的文件，很方便，有很多现成的函数提供使用

			struct appdata  //CPU向顶点Shader提供的模型数据
			{
				float4 vertex : POSITION; //模型空间顶点坐标
				half2 texcoord0 : TEXCOORD0; //第一套UV
				half3 normal : NORMAL; //顶点法线
			};

			struct v2f  //自定义数据结构体，顶点着色器输出的数据，也是片元着色器输入数据
			{
				float4 pos : SV_POSITION; 
				float2 uv : TEXCOORD0;
				float3 pos_world : TEXCOORD1;
				float3 normal_world : TEXCOORD2;
			};

			/*
			Shader内的变量声明，如果跟上面Properties模块内的参数同名，就可以产生链接
			*/
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Cutout;
			float4 _Speed;
			sampler2D _NoiseMap;
			float4 _NoiseMap_ST;
			float4 _MainColor;
			float _Emiss;
			
			//Unity内置变量：https://docs.unity3d.com/Manual/SL-VertexProgramInputs.html

			//顶点Shader
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord0 * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 pos_world = mul(unity_ObjectToWorld, v.vertex);
				o.pos_world = pos_world.xyz;
				o.normal_world = normalize(mul(float4(v.normal,0.0), unity_WorldToObject).xyz);
				return o;
			}
			//片元Shader
			half4 frag (v2f i) : SV_Target //SV_Target表示为：片元Shader输出的目标地（渲染目标）
			{
				float3 normal_world = normalize(i.normal_world);
				float3 view_world = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
				float NdotV = saturate(dot(normal_world, view_world));
				float alpha = saturate(_MainColor.a / NdotV);
				return float4(_MainColor.xyz * _Emiss, alpha);
			}
			ENDCG // Shader代码从这里结束
		}
	}
}
