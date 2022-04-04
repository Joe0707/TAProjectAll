Shader "Char_Standard"
{
	Properties
	{
		[Header(BaseInfo)]
		_BaseMap ("BaseMap", 2D) = "white" {}
		_CompMask("CompMask(RM)",2D) = "white"{}
		_NormalMap("NormalMap",2D) = "bump" {}
		_RoughnessAdjust("Roughness Adjust",Range(-1,1))=0.0
		_MetalAdjust("Metal Adjust",Range(-1,1))=0.0
		[Header(Specular)]
		_SpecShininess("Spec Shininess",Float) = 10
		[Header(SSS)]
		_SkinLUT("Skin LUT",2D) = "white"{}
		_SSSOffset("LUT Offset",Range(-1,1))= 0
		[Header(IBL)]
		_EnvMap("Env Map",Cube) = "white"{}
		// _Tint("Tint",Color) = (1,1,1,1)
		_Expose("Expose",Float) = 1.0
		// _Rotate("Rotate",Range(0,360)) = 0
		[Toggle(_DIFFUSECHECK_ON)] 
		_DiffuseCheck("Diffuse Check",Float) = 0.0
		[Toggle(_SPECCHECK_ON)] 
		_SpecCheck("Specular Check",Float) = 0.0
		[Toggle(_SHCHECK_ON)] 
		_SHCheck("SH Check",Float) = 0.0
		[Toggle(_IBLCHECK_ON)] 
		_IBLCheck("IBL Check",Float) = 0.0

		[HideInInspector]custom_SHAr("Custom SHAr", Vector) = (0, 0, 0, 0)
		[HideInInspector]custom_SHAg("Custom SHAg", Vector) = (0, 0, 0, 0)
		[HideInInspector]custom_SHAb("Custom SHAb", Vector) = (0, 0, 0, 0)
		[HideInInspector]custom_SHBr("Custom SHBr", Vector) = (0, 0, 0, 0)
		[HideInInspector]custom_SHBg("Custom SHBg", Vector) = (0, 0, 0, 0)
		[HideInInspector]custom_SHBb("Custom SHBb", Vector) = (0, 0, 0, 0)
		[HideInInspector]custom_SHC("Custom SHC", Vector) = (0, 0, 0, 1)

	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma shader_feature _DIFFUSECHECK_ON
			#pragma shader_feature _SPECCHECK_ON
			#pragma shader_feature _SHCHECK_ON
			#pragma shader_feature _IBLCHECK_ON

			#include "AutoLight.cginc"
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 normal  : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal_dir : TEXCOORD1;
				float3 pos_world : TEXCOORD2;
				float3 tangent_dir : TEXCOORD3;
				float3 binormal_dir : TEXCOORD4;
				LIGHTING_COORDS(5,6)

			};
			sampler2D _BaseMap;
			sampler2D _CompMask;
			sampler2D _NormalMap;
			float4 _LightColor0;
			float _RoughnessAdjust;
			float _MetalAdjust;
			float _SpecShininess;
			//SH
			half4 custom_SHAr;
			half4 custom_SHAg;
			half4 custom_SHAb;
			half4 custom_SHBr;
			half4 custom_SHBg;
			half4 custom_SHBb;
			half4 custom_SHC;
			//IBL
			samplerCUBE _EnvMap;
			float4 _EnvMap_HDR;
			float4 _Tint;
			float _Expose;
			//SSS
			sampler2D _SkinLUT;
			float _SSSOffset;
			float3 custom_sh(float3 normal_dir)
			{
				float4 normalForSH = float4(normal_dir, 1.0);
				//SHEvalLinearL0L1
				half3 x;
				x.r = dot(custom_SHAr, normalForSH);
				x.g = dot(custom_SHAg, normalForSH);
				x.b = dot(custom_SHAb, normalForSH);

				//SHEvalLinearL2
				half3 x1, x2;
				// 4 of the quadratic (L2) polynomials
				half4 vB = normalForSH.xyzz * normalForSH.yzzx;
				x1.r = dot(custom_SHBr, vB);
				x1.g = dot(custom_SHBg, vB);
				x1.b = dot(custom_SHBb, vB);

				// Final (5th) quadratic (L2) polynomial
				half vC = normalForSH.x*normalForSH.x - normalForSH.y*normalForSH.y;
				x2 = custom_SHC.rgb * vC;

				float3 sh = max(float3(0.0, 0.0, 0.0), (x + x1 + x2));
				sh = pow(sh, 1.0 / 2.2);
				return sh;
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				o.normal_dir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				o.tangent_dir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
				o.binormal_dir = normalize(cross(o.normal_dir,o.tangent_dir)) * v.tangent.w;
				o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
				TRANSFER_VERTEX_TO_FRAGMENT(o);

				return o;
			}
			
			inline float3 ACES_Tonemapping(float3 x)
			{
				float a = 2.51f;
				float b = 0.03f;
				float c = 2.43f;
				float d = 0.59f;
				float e = 0.14f;
				float3 encode_color = saturate((x*(a*x + b)) / (x*(c*x + d) + e));
				return encode_color;
			};


			fixed4 frag (v2f i) : SV_Target
			{
				//Texture Info
				half4 albedo_color_gamma = tex2D(_BaseMap,i.uv);
				half4 albedo_color = pow(albedo_color_gamma,2.2);
				half4 comp_mask = tex2D(_CompMask,i.uv);
				half roughness = saturate(comp_mask.r+_RoughnessAdjust);
				half metal = saturate(comp_mask.g+_MetalAdjust);
				half skin_area =1.0-comp_mask.b;
				half3 base_color = albedo_color.rgb*(1-metal);//非金属固有色
				half3 spec_color = lerp(0.0,albedo_color.rgb,metal);//高光颜色
				half3 normal_data = UnpackNormal(tex2D(_NormalMap,i.uv));
				//Dir
				half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
				half3 normal_dir = normalize(i.normal_dir);
				half3 tangent_dir = normalize(i.tangent_dir);
				half3 binormal_dir = normalize(i.binormal_dir);
				float3x3 TBN = float3x3(tangent_dir, binormal_dir, normal_dir);
				normal_dir = normalize(mul(normal_data.xyz,TBN));
				//Light Info
				half3 light_dir = normalize(_WorldSpaceLightPos0.xyz);
				half atten = LIGHT_ATTENUATION(i);
				//Direct Diffuse 直接光漫反射
				half diff_term = max(0.0,dot(normal_dir, light_dir));
				half3 common_diffuse = diff_term *base_color.xyz*atten*  _LightColor0.xyz  ;

				half2 uv_lut = half2(diff_term*atten+_SSSOffset,1);
				half3 lut_color_gamma = tex2D(_SkinLUT,uv_lut);
				half3 lut_color = pow(lut_color_gamma,2.2);
				half half_lambert = (diff_term+1.0)*0.5;
				half3 sss_diffuse = lut_color*base_color.xyz*  _LightColor0.xyz*half_lambert  ;

				#ifdef _DIFFUSECHECK_ON
				half3 direct_diffuse = lerp(common_diffuse,sss_diffuse,skin_area);
				#else
				half3 direct_diffuse = half3(0.0,0.0,0.0);
				#endif
				//Direct Specular 直接光镜面反射
				half3 half_dir = normalize(light_dir + view_dir);
				half NdotH = dot(normal_dir, half_dir);
				half smoothness = 1.0-roughness;
				half shininess = lerp(1,_SpecShininess,smoothness);
				half spec_term = pow(max(0.0,NdotH),shininess*smoothness);
				half3 spec_skin_color = lerp(spec_color,0.1,skin_area);
				#ifdef _SPECCHECK_ON
				half3 direct_specular = spec_term*spec_skin_color*_LightColor0.xyz*atten;
				#else
				half3 direct_specular = half3(0.0,0.0,0.0);
				#endif
				//Indirect Diffuse 间接光漫反射
				#ifdef _SHCHECK_ON
				float3 env_diffuse = custom_sh(normal_dir)*base_color*half_lambert;
				env_diffuse = lerp(env_diffuse*0.5,env_diffuse,skin_area);
				#else
				float3 env_diffuse = half3(0.0,0.0,0.0);
				#endif
				//Indirect Specular 间接光镜面反射
				half3 reflect_dir = reflect(-view_dir, normal_dir);

				roughness = roughness * (1.7 - 0.7 * roughness);
				float mip_level = roughness * 6.0;

				half4 color_cubemap = texCUBElod(_EnvMap, float4(reflect_dir, mip_level));
				half3 env_color = DecodeHDR(color_cubemap, _EnvMap_HDR);//确保在移动端能拿到HDR信息
				#ifdef _IBLCHECK_ON
				half3 env_specular = env_color *  _Expose*spec_color*half_lambert;
				#else
				half3 env_specular = half3(0.0,0.0,0.0);
				#endif


				float3 final_color = direct_diffuse+direct_specular+env_diffuse+env_specular;
				final_color = ACES_Tonemapping(final_color);
				//线性空间转gamma空间
				final_color = pow(final_color,1.0/2.2);

				return float4(final_color,1.0);
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
