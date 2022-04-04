Shader "lit/Phong"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NormalMap("NormalMap",2D) = "bump"{}
		_NormalIntensity("Normal Intensity",Range(0.0,5.0)) = 1.0
		_AOMap("AO Map",2D) = "white"{}
		_SpecMask("Spec Mask",2D) = "white"{}
		_Shininess("Shininess",Range(0.01,100)) = 1.0
		_SpecIntensity("SpecIntensity",Range(0.01,5)) = 1.0
		_ParallaxMap("ParallaxMap",2D) = "black"{}
		_Parallax("_Parallax",float) = 2
		//_AmbientColor("Ambient Color",Color) = (0,0,0,0)

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
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			
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
				SHADOW_COORDS(5)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _LightColor0;
			float _Shininess;
			float4 _AmbientColor;
			float _SpecIntensity;
			sampler2D _AOMap;
			sampler2D _SpecMask;
			sampler2D _NormalMap;
			float _NormalIntensity;
			sampler2D _ParallaxMap;
			float _Parallax;
			
			float3 ACESFilm(float3 x)
			{
				float a = 2.51f;
				float b = 0.03f;
				float c = 2.43f;
				float d = 0.59f;
				float e = 0.14f;
				return saturate((x*(a*x + b)) / (x*(c*x + d) + e));
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.normal_dir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				o.tangent_dir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
				o.binormal_dir = normalize(cross(o.normal_dir,o.tangent_dir)) * v.tangent.w;
				o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
				TRANSFER_SHADOW(o)
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{		
				half shadow = SHADOW_ATTENUATION(i);



				half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
				half3 normal_dir = normalize(i.normal_dir);
				half3 tangent_dir = normalize(i.tangent_dir);
				half3 binormal_dir = normalize(i.binormal_dir);
				float3x3 TBN = float3x3(tangent_dir, binormal_dir, normal_dir);
				half3 view_tangentspace = normalize(mul(TBN, view_dir));
				half2 uv_parallax = i.uv;

				for (int j = 0; j < 10; j++)
				{
					half height = tex2D(_ParallaxMap, uv_parallax);
					uv_parallax = uv_parallax - (0.5 - height) * view_tangentspace.xy * _Parallax * 0.01f;
				}

				half4 base_color = tex2D(_MainTex, uv_parallax);
				base_color = pow(base_color, 2.2);
				half4 ao_color = tex2D(_AOMap, uv_parallax);
				half4 spec_mask = tex2D(_SpecMask, uv_parallax);
				half4 normalmap = tex2D(_NormalMap, uv_parallax);
				half3 normal_data = UnpackNormal(normalmap);
				normal_data.xy = normal_data.xy * _NormalIntensity;
				normal_dir = normalize(mul(normal_data.xyz, TBN));
				//normal_dir = normalize(tangent_dir * normal_data.x * _NormalIntensity + binormal_dir * normal_data.y * _NormalIntensity + normal_dir * normal_data.z);

				half3 light_dir = normalize(_WorldSpaceLightPos0.xyz);
				half diff_term = min(shadow,max(0.0,dot(normal_dir, light_dir)));
				half3 diffuse_color = diff_term *  _LightColor0.xyz * base_color.xyz;
				
				half3 half_dir = normalize(light_dir + view_dir);
				half NdotH = dot(normal_dir, half_dir);
				half3 spec_color = pow(max(0.0, NdotH),_Shininess) 
					 * diff_term * _LightColor0.xyz * _SpecIntensity * spec_mask.rgb;

				half3 ambient_color = UNITY_LIGHTMODEL_AMBIENT.rgb * base_color.xyz;
				half3 final_color = (diffuse_color + spec_color + ambient_color) * ao_color;
				half3 tone_color = ACESFilm(final_color);
				tone_color = pow(tone_color, 1.0 / 2.2);
				return half4(tone_color,1.0);
			}
			ENDCG
		}
		Pass
		{
			Tags{"LightMode" = "ForwardAdd"}
			Blend One One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

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
				LIGHTING_COORDS(5, 6)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _LightColor0;
			float _Shininess;
			float4 _AmbientColor;
			float _SpecIntensity;
			sampler2D _AOMap;
			sampler2D _SpecMask;
			sampler2D _NormalMap;
			float _NormalIntensity;
			sampler2D _ParallaxMap;
			float _Parallax;

			float3 ACESFilm(float3 x)
			{
				float a = 2.51f;
				float b = 0.03f;
				float c = 2.43f;
				float d = 0.59f;
				float e = 0.14f;
				return saturate((x*(a*x + b)) / (x*(c*x + d) + e));
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.normal_dir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				o.tangent_dir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
				o.binormal_dir = normalize(cross(o.normal_dir,o.tangent_dir)) * v.tangent.w;
				o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				half atten = LIGHT_ATTENUATION(i);

				half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
				half3 normal_dir = normalize(i.normal_dir);
				half3 tangent_dir = normalize(i.tangent_dir);
				half3 binormal_dir = normalize(i.binormal_dir);
				float3x3 TBN = float3x3(tangent_dir, binormal_dir, normal_dir);
				half3 view_tangentspace = normalize(mul(TBN, view_dir));
				half2 uv_parallax = i.uv;

				for (int j = 0; j < 10; j++)
				{
					half height = tex2D(_ParallaxMap, uv_parallax);
					uv_parallax = uv_parallax - (0.5 - height) * view_tangentspace.xy * _Parallax * 0.01f;
				}

				half4 base_color = tex2D(_MainTex, uv_parallax);
				half4 ao_color = tex2D(_AOMap, uv_parallax);
				half4 spec_mask = tex2D(_SpecMask, uv_parallax);
				half4 normalmap = tex2D(_NormalMap, uv_parallax);
				half3 normal_data = UnpackNormal(normalmap);
				normal_data.xy = normal_data.xy * _NormalIntensity;
				normal_dir = normalize(mul(normal_data.xyz, TBN));
				//normal_dir = normalize(tangent_dir * normal_data.x * _NormalIntensity + binormal_dir * normal_data.y * _NormalIntensity + normal_dir * normal_data.z);

				half3 light_dir_point = normalize(_WorldSpaceLightPos0.xyz - i.pos_world);
				half3 light_dir = normalize(_WorldSpaceLightPos0.xyz);
				light_dir = lerp(light_dir, light_dir_point, _WorldSpaceLightPos0.w);
				half diff_term = min(atten,max(0.0,dot(normal_dir, light_dir)));
				half3 diffuse_color = diff_term * _LightColor0.xyz * base_color.xyz;

				half3 half_dir = normalize(light_dir + view_dir);
				half NdotH = dot(normal_dir, half_dir);
				half3 spec_color = pow(max(0.0, NdotH),_Shininess)
					 * diff_term * _LightColor0.xyz * _SpecIntensity * spec_mask.rgb;

				half3 final_color = (diffuse_color + spec_color) * ao_color;
				return half4(final_color,1.0);
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
