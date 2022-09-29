Shader "taecg/GlobalIllumaination"
{
    Properties
    {
        _Color ("Color",Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "./CGIncludes/MyGlobalIllumination.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                half3 normal:NORMAL;
                //当Baked GI或者Realtime GI开启时则进行定义
                #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
                    float4 texcoord1:TEXCOORD1;
                #endif
                float4 texcoord2:TEXCOORD2;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos:TEXCOORD;
                half3 worldNormal:NORMAL;
                #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
                    float4 lightmapUV :TEXCOORD1;
                #endif

                #ifndef LIGHTMAP_ON
                    #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
                        half3 sh :TEXCOORD2;
                    #endif
                #endif
                //同时定义灯光衰减以及实时阴影采样所需的插值器
                UNITY_LIGHTING_COORDS(3,4)
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                //Baked GI的Tiling与Offset
                #if defined(LIGHTMAP_ON)
                    o.lightmapUV.xy = v.texcoord1 * unity_LightmapST.xy + unity_LightmapST.zw;
                #endif
                //Realtime GI的Tiling与Offset
                #if defined(DYNAMICLIGHTMAP_ON)
                    o.lightmapUV.zw = v.texcoord1 * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
                #endif

                //球谐光照和顶点光照的计算
                // SH/ambient and vertex lights
                #ifndef LIGHTMAP_ON //当此对象没有开启静态烘焙时
                    #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
                        o.sh = 0;
                        // Approximated illumination from non-important point lights
                        //近似模拟非重要级别的点光在逐顶点上的光照效果
                        #ifdef VERTEXLIGHT_ON
                            o.sh += Shade4PointLights (
                            unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                            unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                            unity_4LightAtten0, o.worldPos, o.worldNormal);
                        #endif
                        o.sh = ShadeSHPerVertex (o.worldNormal, o.sh);
                    #endif
                #endif // !LIGHTMAP_ON
                
                UNITY_TRANSFER_LIGHTING(o,v.texcoord2.xy);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return unity_FogColor;

                SurfaceOutput o;
                UNITY_INITIALIZE_OUTPUT(SurfaceOutput,o)
                o.Albedo = 1;
                o.Normal = i.worldNormal;

                //1.代表灯光的衰减效果
                //2.实时阴影的采样
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos)

                UnityGI gi;
                UNITY_INITIALIZE_OUTPUT(UnityGI,gi);
                gi.light.color = _LightColor0;
                gi.light.dir = _WorldSpaceLightPos0;
                gi.indirect.diffuse = 0;
                gi.indirect.specular = 0;

                UnityGIInput giInput;
                UNITY_INITIALIZE_OUTPUT(UnityGIInput,giInput);
                giInput.light = gi.light;
                giInput.worldPos = i.worldPos;
                giInput.worldViewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                giInput.atten = atten;
                #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
                    giInput.ambient = i.sh;
                #else
                    giInput.ambient.rgb = 0.0;
                #endif
                #if defined(LIGHTMAP_ON) ||defined(DYNAMICLIGHTMAP_ON)
                    giInput.lightmapUV = i.lightmapUV;
                #endif

                //GI间接光照计算，数据存储在gi中
                // LightingLambert_GI1(o, giInput, gi);
                gi = UnityGI_Base1(giInput,1,o.Normal);

                //GI直接光照计算
                fixed4 c = LightingLambert1(o,gi);
                return c;
            }
            ENDCG
        }

        pass
        {
            Tags {"LightMode" = "ShadowCaster"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _DISSOLVEENABLED_ON
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex:POSITION;
                half3 normal:NORMAL;
                float4 uv:TEXCOORD;
            };

            struct v2f
            {
                float4 uv:TEXCOORD;
                V2F_SHADOW_CASTER;
            };

            sampler2D _DissolveTex;float4 _DissolveTex_ST;
            fixed _Clip;

            v2f vert(appdata v)
            {
                v2f o;
                o.uv.zw = TRANSFORM_TEX(v.uv,_DissolveTex);
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                #if _DISSOLVEENABLED_ON
                    fixed4 dissolveTex=tex2D(_DissolveTex,i.uv.zw);
                    clip(dissolveTex.r-_Clip);
                #endif
                
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }

        //此Pass用于计算光照的间接光反弹
        //在正常渲染时不会使用此Pass
        Pass
        {
            Name "META"
            Tags { "LightMode" = "Meta" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #include "UnityCG.cginc"
            #include "UnityMetaPass.cginc"

            fixed4 _Color;

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata_full v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);
                o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST);
                return o;
            }


            half4 frag (v2f i) : SV_Target
            {
                UnityMetaInput metaIN;
                UNITY_INITIALIZE_OUTPUT(UnityMetaInput, metaIN);
                metaIN.Albedo = 1;
                metaIN.Emission = _Color;
                return UnityMetaFragment(metaIN);
            }
            ENDCG
        }
    }
    CustomEditor "LegacyIlluminShaderGUI"
}
