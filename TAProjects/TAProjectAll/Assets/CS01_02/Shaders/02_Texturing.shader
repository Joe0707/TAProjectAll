Shader "CS02/Texturing" //Shader的真正名字  可以是路径式的格式
{
	/*材质球参数及UI面板
	https://docs.unity3d.com/cn/current/Manual/SL-Properties.html
	https://docs.unity3d.com/cn/current/ScriptReference/MaterialPropertyDrawer.html
	https://zhuanlan.zhihu.com/p/93194054
	*/
	Properties 
	{
		_MainTex ("Texture", 2D) = "" {}
		_Float("Float", Float) = 0.0
		_Debug("_Debug", Range(0.0,1.0)) = 0.0
		_Vector("Vector", Vector) = (.34, .85, .92, 1) 
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", float) = 2
	}
	/*
	这是为了让你可以在一个Shader文件中写多种版本的Shader，但只有一个会被使用。
	提供多个版本的SubShader，Unity可以根据对应平台选择最合适的Shader
	或者配合LOD机制一起使用。
	一般写一个即可
	*/
	SubShader
	{
		/*
		标签属性，有两种：一种是SubShader层级，一种在Pass层级
		https://docs.unity3d.com/cn/current/Manual/SL-SubShaderTags.html
		https://docs.unity3d.com/cn/current/Manual/SL-PassTags.html
		*/
		Tags { "RenderType"="Opaque" "DisableBatching"="True"} 
		/*
		Pass里面的内容Shader代码真正起作用的地方，
		一个Pass对应一个真正意义上运行在GPU上的完整着色器(Vertex-Fragment Shader)
		一个SubShader里面可以包含多个Pass，每个Pass会被按顺序执行
		*/
		Pass 
		{
			Cull [_CullMode]
			CGPROGRAM  // Shader代码从这里开始
			#pragma vertex vert //指定一个名为"vert"的函数为顶点Shader
			#pragma fragment frag //指定一个名为"frag"函数为片元Shader
			#include "UnityCG.cginc"  //引用Unity内置的文件，很方便，有很多现成的函数提供使用

			//https://docs.unity3d.com/Manual/SL-VertexProgramInputs.html
			struct appdata  //CPU向顶点Shader提供的模型数据
			{
				//冒号后面的是特定语义词，告诉CPU需要哪些类似的数据
				float4 vertex : POSITION; //模型空间顶点坐标
				half2 texcoord0 : TEXCOORD0; //第一套UV
				half2 texcoord1 : TEXCOORD1; //第二套UV
				half2 texcoord2 : TEXCOORD2; //第二套UV
				half2 texcoord4 : TEXCOORD3;  //模型最多只能有4套UV

				half4 color : COLOR; //顶点颜色
				half3 normal : NORMAL; //顶点法线
				half4 tangent : TANGENT; //顶点切线(模型导入Unity后自动计算得到)
			};

			struct v2f  //自定义数据结构体，顶点着色器输出的数据，也是片元着色器输入数据
			{
				float4 pos : SV_POSITION; //输出裁剪空间下的顶点坐标数据，给光栅化使用，必须要写的数据
				float2 uv : TEXCOORD0; //自定义数据体
				//注意跟上方的TEXCOORD的意义是不一样的，上方代表的是UV，这里可以是任意数据。
				//插值器：输出后会被光栅化进行插值，而后作为输入数据，进入片元Shader
				//最多可以写16个：TEXCOORD0 ~ TEXCOORD15。
				float3 pos_local : TEXCOORD1;
				//float3 pos_pivot : TEXCOORD2;
			};

			/*
			Shader内的变量声明，如果跟上面Properties模块内的参数同名，就可以产生链接
			*/
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Debug;
			
			//顶点Shader
			v2f vert (appdata v)
			{
				v2f o;
				float4 pos_world = mul(unity_ObjectToWorld, v.vertex);
				float4 pos_view = mul(UNITY_MATRIX_V, pos_world);
				float4 pos_clip = mul(UNITY_MATRIX_P, pos_view);
				o.pos = pos_clip;
				//o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord0 * _MainTex_ST.xy + _MainTex_ST.zw;
				//o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.pos_local = v.vertex.xyz;
				return o;
			}
			//片元Shader
			half4 frag (v2f i) : SV_Target //SV_Target表示为：片元Shader输出的目标地（渲染目标）
			{
				float dist = distance(i.pos_local,float3(0.0,0.0,0.0));
				float arc = (atan2(i.pos_local.x, i.pos_local.y) / (UNITY_PI) + 1.0) * 2.0;
				float2 uv_fix = float2(arc, dist);
				half4 col = tex2D(_MainTex, i.uv.xy);
				half4 col_fix = tex2D(_MainTex, uv_fix);
				half4 finalcolor = lerp(col, col_fix, _Debug);
				return finalcolor;
			}
			ENDCG // Shader代码从这里结束
		}
	}
}
