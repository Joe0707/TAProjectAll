Shader "Toon"
{
	Properties
	{
		_BaseMap ("Base Map", 2D) = "white" {}
		_SSSMap ("SSS Map", 2D) = "black" {}
		_ILMMap("ILM Map",2D) = "grey" {}
		_DetailMap("Detail Map",2D) = "white" {}
		_ToonThreshold("ToonThreshold",Range(0,1)) = 0.5
		_ToonHardness("ToonHardness",Float) = 20.0
		_SpecSize("Spec Size",Range(0,1)) =0.1 
		_SpecColor("Spec Color",Color) = (1,1,1,1)
		_RimLightDir("RimLight Dir",Vector) = (1,0,-1,0)
		_RimLightColor("RimLight Color",Color) = (1,1,1,1)
		_OutlineWidth("Outline Width",Float) =7.0
		_OutlineColor("Outline Color",Color) = (1,1,1,1)
		_OutlineZBias("Outline Z Bias",Float) = -10
	}
	SubShader
	{
		Tags { "LightMode"="ForwardBase"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#include "AutoLight.cginc"
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord0 : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
				float3 normal : NORMAL;
				float4 color : COLOR;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 pos_world:TEXCOORD1;
				float3 normal_world:TEXCOORD2;
				float4 vertex_color:TEXCOORD3;
				SHADOW_COORDS(4)
			};

			sampler2D _BaseMap;
			sampler2D _SSSMap;
			sampler2D _ILMMap;
			sampler2D _DetailMap;
			float _ToonThreshold;
			float _ToonHardness;
			float _SpecSize;
			float4 _SpecColor;
			float4 _RimLightDir;
			float4 _RimLightColor;
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.pos_world = mul(unity_ObjectToWorld,v.vertex).xyz;
				o.normal_world = UnityObjectToWorldNormal(v.normal);
				o.uv = float4(v.texcoord0,v.texcoord1);
				o.vertex_color = v.color;
				TRANSFER_SHADOW(o)
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				// sample the texture
				half2 uv1 = i.uv.xy;
				half2 uv2 = i.uv.zw;
				//向量
				float3 normalDir = normalize(i.normal_world);
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.pos_world.xyz);
				//Base贴图
				half4 base_map = tex2D(_BaseMap, uv1);
				half3 base_color = base_map.rgb;//亮部的颜色
				half base_mask = base_map.a;//用来区分皮肤和非皮肤区域
				//SSS贴图
				half4 sss_map = tex2D(_SSSMap,uv1);
				half3 sss_color = sss_map.rgb;//暗部的颜色
				half sss_alpha = sss_map.a;//边缘光 强度控制
				//ILM贴图
				half4 ilm_map = tex2D(_ILMMap,uv1);
				float spec_intensity = ilm_map.r;//控制高光强度
				float diffuse_control = ilm_map.g*2-1;//控制光照的偏移
				float spec_size = ilm_map.b;//控制高光形状大小
				float inner_line = ilm_map.a;//内描线
				//顶点色
				float ao = i.vertex_color.r;
				//实时阴影
				float atten = lerp(1,SHADOW_ATTENUATION(i),i.vertex_color.g);
				//漫反射
				half NdotL = dot(normalDir,lightDir);
				half half_lambert = NdotL*0.5+0.5;
				half lambert_term = half_lambert*ao*atten+diffuse_control;
				half toon_diffuse = saturate((lambert_term-_ToonThreshold)*_ToonHardness);
				half3 final_diffuse = lerp(sss_color,base_color,toon_diffuse);
				//高光
				float NdotV = (dot(normalDir,viewDir)+1)*0.5;
				float spec_term = NdotV * ao +diffuse_control;
				spec_term = half_lambert*0.9+spec_term*0.1;
				half toon_spec = saturate((spec_term-(1.0-spec_size*_SpecSize))*500);
				half3 spec_color = (_SpecColor.xyz+base_color)*0.5;
				half3 final_spec = spec_color*toon_spec*spec_intensity;
				//描线
				half3 inner_line_color = lerp(base_color*0.2,float3(1.0,1.0,1.0),inner_line);
				half3 detail_color = tex2D(_DetailMap,uv2);//第二套UV Detail细节图
				detail_color = lerp(base_color*0.2,float3(1.0,1.0,1.0),detail_color);
				half3 final_line = inner_line_color*inner_line_color*detail_color;
				//补光
				float3 lightDir_rim = normalize(mul((float3x3)unity_MatrixInvV,_RimLightDir.xyz));
				half NdotL_rim = (dot(normalDir,lightDir_rim)+1.0)*0.5;
				half rimlight_term = NdotL_rim+diffuse_control;
				half toon_rim = saturate((rimlight_term-_ToonThreshold)*20);
				half3 rim_color = (_RimLightColor.rgb + base_color)*0.5*sss_alpha;
				half3 final_rimlight = toon_rim*rim_color*base_mask*toon_diffuse*_RimLightColor.a;

				half3 final_color = (final_diffuse+final_spec+final_rimlight)*final_line;
				final_color = sqrt(max(exp2(log2(max(final_color,0.0))*2.2),0.0));
				return float4(final_color,1.0);
			}
			ENDCG
		}

		Pass
		{
			Cull Front
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#include "AutoLight.cginc"
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord0 : TEXCOORD0;
				float3 normal : NORMAL;
				float4 color : COLOR;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 vertex_color:TEXCOORD3;
			};

			sampler2D _BaseMap;
			sampler2D _SSSMap;
			sampler2D _ILMMap;
			float _OutlineWidth;
			float4 _OutlineColor;
			float _OutlineZBias;
			v2f vert (appdata v)
			{
				v2f o;
				float3 pos_view = UnityObjectToViewPos(v.vertex);
				float3 normal_world = UnityObjectToWorldNormal(v.normal);
				float3 outline_dir = normalize(mul((float3x3)UNITY_MATRIX_V,normal_world));
				outline_dir.z = _OutlineZBias*(1.0-v.color.b);
				pos_view += outline_dir*_OutlineWidth*0.001*v.color.a;
				o.pos = mul(UNITY_MATRIX_P,float4(pos_view,1));
				// o.pos = mul(UNITY_MATRIX_VP,float4(pos_world,1));
				o.uv = v.texcoord0;
				o.vertex_color = v.color;
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{				
				float3 basecolor = tex2D(_BaseMap,i.uv.xy).xyz;
				half maxComponent = max(max(basecolor.r,basecolor.g),basecolor.b)-0.004;
				half3 saturatedColor = step(maxComponent.rrr,basecolor)*basecolor;
				saturatedColor = lerp(basecolor.rgb,saturatedColor,0.6);
				half3 outlineColor = 0.8*saturatedColor*basecolor*_OutlineColor.xyz;
				return float4(outlineColor,1.0);

				// return float4(0,0,0,1.0);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
