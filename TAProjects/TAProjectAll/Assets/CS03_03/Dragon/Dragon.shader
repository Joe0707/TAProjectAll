Shader "Dragon" {
   Properties {
		_DiffuseColor("Diffuse Color",Color) = (0,0.352,0.219,1)
		_AddColor("Add Color",Color) = (0,0.352,0.219,1)
		_Opacity("Opacity",Range(0,1)) = 0
		_ThicknessMap("Thickness Map",2D) = "black"{}
		
		[Header(BasePass)]
		_BasePassDistortion("Bass Pass Distortion", Range(0,1)) = 0.2
		_BasePassColor("BasePass Color",Color) = (1,1,1,1)
		_BasePassPower("BasePass Power",float) = 1
		_BasePassScale("BasePass Scale",float) = 2
		
		[Header(AddPass)]
		_AddPassDistortion("Add Pass Distortion", Range(0,1)) = 0.2
		_AddPassColor("AddPass Color",Color) = (0.56,0.647,0.509,1)
		_AddPassPower("AddPass Power",float) = 1
		_AddPassScale("AddPass Scale",float) = 1

		[Header(EnvReflect)]
		_EnvRotate("Env Rotate",Range(0,360)) = 0
		_EnvMap ("Env Map", Cube) = "white" {}
		_FresnelMin("Fresnel Min",Range(-2,2)) = 0
		_FresnelMax("Fresnel Max",Range(-2,2)) = 1
		_EnvIntensity("Env Intensity",float) = 1.0
   }
   SubShader {
		Pass {	
		Tags { "LightMode" = "ForwardBase" } 
		CGPROGRAM
 
		#pragma vertex vert  
		#pragma fragment frag 
		#pragma multi_compile_fwdbase
		#include "UnityCG.cginc"
		#include "AutoLight.cginc"

		sampler2D _ThicknessMap;
		float4 _DiffuseColor;
		float4 _AddColor;
		float _Opacity;

		float4 _BasePassColor;
		float _BasePassDistortion;
		float _BasePassPower;
		float _BasePassScale;

 		samplerCUBE _EnvMap;
		float4 _EnvMap_HDR;
		float _EnvRotate;
		float _EnvIntensity;
		float _FresnelMin;
		float _FresnelMax;

		float4 _LightColor0;
 
		struct appdata {
			float4 vertex : POSITION;
			float2 texcoord : TEXCOORD0;
			float3 normal : NORMAL;
		};
		struct v2f {
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
			float4 posWorld : TEXCOORD1;
			float3 normalDir : TEXCOORD2;
		};

        v2f vert(appdata v) 
        {
			v2f o;
			o.posWorld = mul(unity_ObjectToWorld, v.vertex);
			o.normalDir = UnityObjectToWorldNormal(v.normal);
            o.posWorld = mul(unity_ObjectToWorld, v.vertex);
			o.uv = v.texcoord;
			o.pos = UnityObjectToClipPos(v.vertex);
			return o;
        }
 
        float4 frag(v2f i) : COLOR
        {
			//info
			float3 diffuse_color = _DiffuseColor;
			float3 normalDir = normalize(i.normalDir);
			float3 viewDir = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);
			float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

			//diffuse
			float diff_term = max(0.0, dot(normalDir, lightDir));
			float3 diffuselight_color = diff_term * diffuse_color * _LightColor0.rgb;

			float sky_sphere = (dot(normalDir,float3(0,1,0)) + 1.0) * 0.5;
			float3 sky_light = sky_sphere * diffuse_color;
			float3 final_diffuse = diffuselight_color + sky_light * _Opacity + _AddColor.xyz;

			//trans light
			float3 back_dir = -normalize(lightDir + normalDir * _BasePassDistortion);
			float VdotB = max(0.0, dot(viewDir, back_dir));
			float backlight_term = max(0.0,pow(VdotB, _BasePassPower)) * _BasePassScale;
			float thickness = 1.0 - tex2D(_ThicknessMap, i.uv).r;
			float3 backlight = backlight_term * thickness *
				_LightColor0.xyz * _BasePassColor.xyz;

			//ENV
			float3 reflectDir = reflect(-viewDir,normalDir);

			half theta = _EnvRotate * UNITY_PI / 180.0f;
			float2x2 m_rot = float2x2(cos(theta), -sin(theta), sin(theta),cos(theta));
			float2 v_rot = mul(m_rot, reflectDir.xz);
			reflectDir = half3(v_rot.x, reflectDir.y, v_rot.y);

			float4 cubemap_color = texCUBE(_EnvMap,reflectDir);
			half3 env_color = DecodeHDR(cubemap_color, _EnvMap_HDR);

			float fresnel = 1.0 - saturate(dot(normalDir, viewDir));
			fresnel = smoothstep(_FresnelMin, _FresnelMax, fresnel);

			float3 final_env = env_color * _EnvIntensity * fresnel;
			//combine
			float3 combined_color = final_diffuse + final_env + backlight;
			float3 final_color = combined_color;
			return float4(final_color,1.0);
		}
		ENDCG
		}
		Pass {	
			Tags { "LightMode" = "ForwardAdd" } 
			Blend One One 
			CGPROGRAM
 
			#pragma vertex vert  
			#pragma fragment frag 
			#pragma multi_compile_fwdadd
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			float4 _LightColor0; 
 
			float4 _DiffuseColor;
			sampler2D _ThicknessMap;
			float _AddPassDistortion;
			float _AddPassPower;
			float _AddPassScale;
			float4 _AddPassColor;

 			samplerCUBE _EnvMap;
			float _EnvIntensity;
			float _FresnelMin;
			float _FresnelMax;
 
			struct appdata {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord0 : TEXCOORD0;
			};
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float3 normalDir : TEXCOORD2;
				LIGHTING_COORDS(5,6)
			};
			v2f vert(appdata v) 
			{
				v2f o;

				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.normalDir = UnityObjectToWorldNormal(v.normal);
				o.uv = v.texcoord0;
				o.pos = UnityObjectToClipPos(v.vertex);
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}
 
			float4 frag(v2f i) : COLOR
			{
				float3 diffuse_color = _DiffuseColor * _DiffuseColor;

				float3 normalDir = normalize(i.normalDir); 
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);
				float NdotV = saturate(dot(normalDir,viewDir));
				//light info
				float3 lightDir = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
				float attenuation = LIGHT_ATTENUATION(i);
				//trans light
				float3 back_dir = -normalize(lightDir + normalDir * _AddPassDistortion);
				float VdotB = max(0.0,dot(viewDir, back_dir));
				float backlight_term = max(0.0, pow(VdotB, _AddPassPower)) * _AddPassScale;
				float thickness = 1.0 - tex2D(_ThicknessMap, i.uv).r;
				float3 backlight = backlight_term * thickness *
					_LightColor0.xyz * _AddPassColor.xyz;
				//combine
				float3 final_color = backlight;
				final_color = sqrt(final_color);
				return float4(final_color,1.0);
			}
			ENDCG
		}
	}
	    FallBack "Diffuse"
}