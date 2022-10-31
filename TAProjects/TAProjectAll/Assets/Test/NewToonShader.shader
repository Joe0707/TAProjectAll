// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable

// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/New Toon Shading " {
	Properties {
		_Color ("Diffuse Multi Color", Color) = (1, 1, 1, 1)
		_AmbientColor("Ambient Multi Color",Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_Ramp ("Ramp Texture", 2D) = "white" {}
		_SpecularTex("Specular Tex",2D) = "white" {}
		_Roughness("Metal Roughness",Range(-1,1)) = 0
		_Outline ("Outline", Float) = 6
		_OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
		_SpecShininess("Spec Shininess",Float) = 10
		_MetalShininess("Metal Shininess",Float) = 1
		[HDR]_SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
		_SpecularScale("Specular Scale",Float) = 1
		// _SpecularScale ("Specular Scale", Range(0, 0.1)) = 0
		// _DiffuseIntensityValue("DiffuseIntensity",Range(0,10)) = 1
		[Toggle(_SPECCHECK_ON)] 
		_SpecCheck("Specular Check",Float) = 1
		[Toggle(_INDIRECT_DIFFUSE_CHECK_ON)] 
		_IndirectDiffuseCheck("Indirect Check",Float) = 1
		_EnvMap("Env Map",Cube) = "white" {}
		_EnvLevel("Env Level",Int) = 1
		_EnvIntensity("Env Intensity",Range(0,1)) = 1
		_CartoonLightUp("Cartoon Light Up",Range(0,1)) = 1
		_CartoonLightDown("Cartoon Light Down",Range(0,1)) = 0
		_Step("Step",Range(0.001,9)) = 1
		_ToonEffect("Toon Effect",Range(0,1)) = 0
		_DiffuseHardness("Diffuse Hardness",Float) = 1
	}

    SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Geometry" }
		Pass{
			Cull Front
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdbase
				#pragma multi_compile_instancing
            	// make fog work
            	#pragma multi_compile_fog

				#include "UnityCG.cginc"
				float _Outline;
				half4 _OutlineColor;
				struct a2v{
					float4 position : POSITION;
					float3 normal : NORMAL;
                	float4 color : COLOR;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};
				struct v2f{
					float4 position:POSITION;
					UNITY_FOG_COORDS(0)
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};
				v2f vert(a2v a){
						v2f v;
						float3 pos_view = UnityObjectToViewPos(a.position);
						UNITY_SETUP_INSTANCE_ID(a); //这里第三步
                		UNITY_TRANSFER_INSTANCE_ID(a,v); //第三步
						float3 normal_world = UnityObjectToWorldNormal(a.normal);
						float3 outline_dir = normalize(mul((float3x3)UNITY_MATRIX_V,normal_world));
						outline_dir.z = -1;
						pos_view += outline_dir*_Outline*a.color.r;
						v.position = mul(UNITY_MATRIX_P,float4(pos_view,1));

    					// v.position = UnityObjectToClipPos(a.position);
    					// float3 clipNormal = mul((float3x3) UNITY_MATRIX_VP, mul((float3x3) UNITY_MATRIX_M, a.normal));
						// float2 offset = normalize(clipNormal.xy) / _ScreenParams.xy * _Outline * v.position.w * 2;
						// offset*=a.color.r;
						// v.position.xy += offset;
						UNITY_TRANSFER_FOG(v,v.position);
						return v;
				}

				half4 frag(v2f i):SV_Target{
					UNITY_SETUP_INSTANCE_ID(i);
					clip(_OutlineColor.a-0.5);
					// apply fog
					float4 finalcolor = _OutlineColor;
                	UNITY_APPLY_FOG(i.fogCoord, finalcolor);
					return finalcolor;
				}
			ENDCG
		}
		Pass {
			Tags { "LightMode"="ForwardBase" }
			
			Cull Back
		
			CGPROGRAM
		
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_fwdbase
			#pragma multi_compile_instancing
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON//开启LIGHTMAP_OFF LIGHTMAP_ON这两个宏。
            // make fog work
            #pragma multi_compile_fog
			#pragma shader_feature _SPECCHECK_ON
			#pragma shader_feature _INDIRECT_DIFFUSE_CHECK_ON
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityShaderVariables.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Ramp;
			float4 _SpecularColor;
			float _SpecularScale;
			// fixed _SpecularScale;
			fixed4 _AmbientColor;
			// float _DiffuseIntensityValue;
			float _Roughness;
			sampler2D _SpecularTex;
			samplerCUBE _EnvMap;
			float4 _EnvMap_HDR;
			float _SpecShininess;
			float _MetalShininess;
			float _EnvIntensity;
			int _EnvLevel;
			fixed _CartoonLightUp;
			fixed _CartoonLightDown;
			float _Step;
			float _ToonEffect;
			float _DiffuseHardness;
			#ifdef LIGHTMAP_ON 
        		// sampler2D unity_Lightmap;//Beast lightmap
        		// float4 unity_LightmapST; //scale & position of Beast lightmap
			#endif

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			}; 
		
			struct v2f {
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				SHADOW_COORDS(3)
                UNITY_FOG_COORDS(4)
				#ifdef LIGHTMAP_ON 
					float2 uv2: TEXCOORD5;
				#endif
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
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

			v2f vert (appdata_full v) {
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v); //这里第三步
                UNITY_TRANSFER_INSTANCE_ID(v,o); //第三步
				o.pos = UnityObjectToClipPos( v.vertex);
				o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
				o.worldNormal  = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#ifdef LIGHTMAP_ON 
					o.uv2 = v.texcoord1.xy*unity_LightmapST.xy+unity_LightmapST.zw;
				#endif
				TRANSFER_SHADOW(o);
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			
			float4 frag(v2f i) : SV_Target { 
				fixed4 c = tex2D (_MainTex, i.uv);
				// fixed4 c= pow(c_gamma,2.2);
				UNITY_SETUP_INSTANCE_ID(i);
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 worldHalfDir = normalize(worldLightDir + worldViewDir);
				
				fixed3 albedo = c.rgb * _Color.rgb;
				
				// fixed3 ambient = _AmbientColor.xyz;
				
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				
				// fixed diff =  dot(worldNormal, worldLightDir)*_DiffuseIntensityValue;
				// // diff = (diff * 0.5 + 0.5) * atten;
				// diff = (diff * 0.5 + 0.5) *_DiffuseIntensityValue;
				// diff = tex2D(_Ramp, float2(diff, diff)).r;
				// diff *= atten;
				
				// fixed3 diffuse = _LightColor0.rgb * albedo * diff;
				//diff
				half ndl = dot(worldNormal, worldLightDir);
				half diff_term = max(0.0,ndl);
				diff_term = pow(diff_term,_DiffuseHardness);
				half half_lambert = smoothstep(0,1,(ndl+1.0)*0.5);
				half ramp_diff = tex2D(_Ramp, float2(diff_term*atten, 0.5)).r;
				// ramp_diff = pow(ramp_diff,_DiffuseHardness);
				// half_lambert = smoothstep(0,1,half_lambert);
				half diff_step = smoothstep(_CartoonLightDown,_CartoonLightUp,diff_term);//计算漫反射
				float toonlight = floor(diff_step*_Step)/_Step;	//对计算结果进行离散化处理
				float diff = lerp(ramp_diff,toonlight,_ToonEffect);//调节卡通效果强弱
				half3 diffuse = ramp_diff *albedo.rgb*_LightColor0.xyz;
				//spec
				half NdotH = dot(worldNormal, worldHalfDir);
				half4 spec_mask = tex2D(_SpecularTex,i.uv);
				half hasspec = saturate(spec_mask.r);
				float3 spec_color = lerp(fixed3(0,0,0),c.rgb*_SpecularColor,hasspec);
				// return fixed4(spec_color, 1.0);
				half smoothness = saturate(spec_mask.r-_Roughness);
				// return fixed4((smoothness+_TestValue).xxxx);
				half shininess = lerp(1,_SpecShininess,smoothness);
				// half smoothness = 1.0-roughness;
				// half hasspec = lerp(0,1,roughness);
				// half shininess = lerp(_SpecShininess,_MetalShininess,hasspec);
				float spec_term = pow(max(0.0,NdotH),max(0,shininess));
				#ifdef _SPECCHECK_ON
				float3 direct_specular = spec_term*spec_color*_SpecularScale*_LightColor0.xyz*atten;
				#else
				float3 direct_specular = half3(0,0,0);
				#endif
				// fixed spec = dot(worldNormal, worldHalfDir);
				// fixed w = fwidth(spec) * 2.0;
				// fixed3 specular = _Specular.rgb * lerp(0, 1, smoothstep(-w, w, spec + _SpecularScale - 1)) * step(0.0001, _SpecularScale);
				//indirect diffuse

				//Indirect Diffuse
				half3 reflect_dir = reflect(-worldViewDir, worldNormal);
				// float mip_level = roughness * 6.0;
				half4 color_cubemap = texCUBElod(_EnvMap, float4(reflect_dir, _EnvLevel));
				half3 env_color = DecodeHDR(color_cubemap, _EnvMap_HDR)*_EnvIntensity;//确保在移动端能拿到HDR信息
				// half half_lambert = (diff_term+1.0)*0.5;
				env_color = env_color*_AmbientColor.xyz*albedo.rgb*half_lambert;

				#ifdef _INDIRECT_DIFFUSE_CHECK_ON
				fixed3 env_diffuse = env_color;
				#else
				fixed3 env_diffuse = half3(0,0,0);
				#endif

				float3 finalcolor = diffuse + direct_specular+env_diffuse;
				// specular*=atten;
				#ifdef LIGHTMAP_ON
					fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap,i.uv2))*2;
					finalcolor *= lm;
				#endif
				// finalcolor = ACES_Tonemapping(finalcolor);
				// finalcolor = pow(finalcolor,1.0/2.2);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, finalcolor);
				return float4(finalcolor, 1.0);
			}
		
			ENDCG
		}
		Pass{
			Tags{"LightMode"="ForwardAdd"}
			Cull Back
			Blend One One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_fwdadd
            // make fog work
            #pragma multi_compile_fog
						// #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON//开启LIGHTMAP_OFF LIGHTMAP_ON这两个宏。
					#pragma shader_feature _SPECCHECK_ON
			#pragma shader_feature _INDIRECT_DIFFUSE_CHECK_ON

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityShaderVariables.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Ramp;
			float4 _SpecularColor;
			// fixed4 _Specular;
			// fixed _SpecularScale;
			fixed4 _AmbientColor;
			// float _DiffuseIntensityValue;
			float _Roughness;
			sampler2D _SpecularTex;
			samplerCUBE _EnvMap;
			float4 _EnvMap_HDR;
			float _SpecShininess;
			float _MetalShininess;
			float _EnvIntensity;
			int _EnvLevel;
			fixed _CartoonLightUp;
			fixed _CartoonLightDown;
			float _Step;
			float _ToonEffect;
			float _DiffuseHardness;
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			}; 
		
			struct v2f {
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				SHADOW_COORDS(3)
			    UNITY_FOG_COORDS(4)
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
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

			v2f vert (a2v v) {
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v); //这里第三步
                UNITY_TRANSFER_INSTANCE_ID(v,o); //第三步
				o.pos = UnityObjectToClipPos( v.vertex);
				o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
				o.worldNormal  = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				TRANSFER_SHADOW(o);
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			
			float4 frag(v2f i) : SV_Target { 
				fixed4 c = tex2D (_MainTex, i.uv);
				// fixed4 c= pow(c_gamma,2.2);
				UNITY_SETUP_INSTANCE_ID(i);
				fixed3 worldNormal = normalize(i.worldNormal);
				// fixed3 worldLightDir = normalize(UnityWorldSpaceLwightDir(i.worldPos));
				half3 light_dir_point = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
				half3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				worldLightDir = lerp(worldLightDir, light_dir_point, _WorldSpaceLightPos0.w);
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 worldHalfDir = normalize(worldLightDir + worldViewDir);
				
				fixed3 albedo = c.rgb * _Color.rgb;
				
				// fixed3 ambient = _AmbientColor.xyz;
				
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				
				// fixed diff =  dot(worldNormal, worldLightDir)*_DiffuseIntensityValue;
				// // diff = (diff * 0.5 + 0.5) * atten;
				// diff = (diff * 0.5 + 0.5) *_DiffuseIntensityValue;
				// diff = tex2D(_Ramp, float2(diff, diff)).r;
				// diff *= atten;
				
				// fixed3 diffuse = _LightColor0.rgb * albedo * diff;
				//diff
				half ndl = dot(worldNormal, worldLightDir);
				half diff_term = max(0.0,ndl);
				diff_term = pow(diff_term,_DiffuseHardness);
				half half_lambert = smoothstep(0,1,(ndl+1.0)*0.5);
				half ramp_diff = tex2D(_Ramp, float2(diff_term*atten, 0.5)).r;
				// ramp_diff = pow(ramp_diff,_DiffuseHardness);
				// half_lambert = smoothstep(0,1,half_lambert);
				half diff_step = smoothstep(_CartoonLightDown,_CartoonLightUp,diff_term);//计算漫反射
				float toonlight = floor(diff_step*_Step)/_Step;	//对计算结果进行离散化处理
				float diff = lerp(ramp_diff,toonlight,_ToonEffect);//调节卡通效果强弱
				half3 diffuse = ramp_diff *albedo.rgb*_LightColor0.xyz;
				//spec
				half NdotH = dot(worldNormal, worldHalfDir);
				half4 spec_mask = tex2D(_SpecularTex,i.uv);
				half hasspec = saturate(spec_mask.r);
				float3 spec_color = lerp(fixed3(0,0,0),c.rgb*_SpecularColor,hasspec);
				// return fixed4(spec_color, 1.0);
				half smoothness = saturate(spec_mask.r-_Roughness);
				// return fixed4((smoothness+_TestValue).xxxx);
				half shininess = lerp(1,_SpecShininess,smoothness);
				// half smoothness = 1.0-roughness;
				// half hasspec = lerp(0,1,roughness);
				// half shininess = lerp(_SpecShininess,_MetalShininess,hasspec);
				float spec_term = pow(max(0.0,NdotH),max(0,shininess));
				#ifdef _SPECCHECK_ON
				float3 direct_specular = spec_term*spec_color*_LightColor0.xyz*atten;
				#else
				float3 direct_specular = float3(0,0,0);
				#endif
				// fixed spec = dot(worldNormal, worldHalfDir);
				// fixed w = fwidth(spec) * 2.0;
				// fixed3 specular = _Specular.rgb * lerp(0, 1, smoothstep(-w, w, spec + _SpecularScale - 1)) * step(0.0001, _SpecularScale);
				//indirect diffuse

				//Indirect Diffuse
				half3 reflect_dir = reflect(-worldViewDir, worldNormal);
				// float mip_level = roughness * 6.0;
				half4 color_cubemap = texCUBElod(_EnvMap, float4(reflect_dir, _EnvLevel));
				half3 env_color = DecodeHDR(color_cubemap, _EnvMap_HDR)*_EnvIntensity;//确保在移动端能拿到HDR信息
				// half half_lambert = (diff_term+1.0)*0.5;
				env_color = env_color*_AmbientColor.xyz*albedo.rgb*half_lambert;

				#ifdef _INDIRECT_DIFFUSE_CHECK_ON
				fixed3 env_diffuse = env_color;
				#else
				fixed3 env_diffuse = half3(0,0,0);
				#endif

				float3 finalcolor = diffuse + direct_specular+env_diffuse;
				// specular*=atten;
				// #ifdef LIGHTMAP_ON
				// 	fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap,i.uv2))*2;
				// 	finalcolor *= lm;
				// #endif
				// finalcolor = ACES_Tonemapping(finalcolor);
				// finalcolor = pow(finalcolor,1.0/2.2);
			    // apply fog
                UNITY_APPLY_FOG(i.fogCoord, finalcolor);
				return float4(finalcolor, 1.0);
			}
			ENDCG
		}

	}
	FallBack "Diffuse"
}
