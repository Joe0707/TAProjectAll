#ifndef MYGLOBALILLUMINATION_CGINCLUDE
    #define MYGLOBALILLUMINATION_CGINCLUDE

    //Lambert光照模型
    inline fixed4 UnityLambertLight1 (SurfaceOutput s, UnityLight light)
    {
        fixed diff = max (0, dot (s.Normal, light.dir));

        fixed4 c;
        c.rgb = s.Albedo * light.color * diff;
        c.a = s.Alpha;
        return c;
    }

    //直接光照+间接光照
    inline fixed4 LightingLambert1 (SurfaceOutput s, UnityGI gi)
    {
        fixed4 c;
        c = UnityLambertLight1 (s, gi.light);

        //如果是BakedGI或者RealtimeGI的情况下
        #ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
            c.rgb += s.Albedo * gi.indirect.diffuse;
        #endif

        return c;
    }

    //GI核心内容
    inline UnityGI UnityGI_Base1(UnityGIInput data, half occlusion, half3 normalWorld)
    {
        //声明一个UnityGI类型的变量o_gi,用于存储最终计算的gi信息
        UnityGI o_gi;
        //重置gi内的变量值
        ResetUnityGI(o_gi);

        //计算在Distance Shadowmask中实时阴影与烘焙阴影的混合过渡
        // Base pass with Lightmap support is responsible for handling ShadowMask / blending here for performance reason
        #if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
            half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
            float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
            float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
            data.atten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
        #endif

        //将主平行灯传入gi中
        o_gi.light = data.light;
        //将衰减应用于灯光颜色中
        o_gi.light.color *= data.atten;

        //是否进行球谐光照
        #if UNITY_SHOULD_SAMPLE_SH
            o_gi.indirect.diffuse = ShadeSHPerPixel(normalWorld, data.ambient, data.worldPos);
        #endif

        //当采用Baked GI时
        #if defined(LIGHTMAP_ON)
            // Baked lightmaps
            //光照图的采样（核心）
            half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, data.lightmapUV.xy);
            half3 bakedColor = DecodeLightmap(bakedColorTex);

            //当开启Directional模式时
            #ifdef DIRLIGHTMAP_COMBINED
                fixed4 bakedDirTex = UNITY_SAMPLE_TEX2D_SAMPLER (unity_LightmapInd, unity_Lightmap, data.lightmapUV.xy);
                o_gi.indirect.diffuse += DecodeDirectionalLightmap (bakedColor, bakedDirTex, normalWorld);

                #if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
                    ResetUnityLight(o_gi.light);
                    o_gi.indirect.diffuse = SubtractMainLightWithRealtimeAttenuationFromLightmap (o_gi.indirect.diffuse, data.atten, bakedColorTex, normalWorld);
                #endif

            #else // not directional lightmap
                o_gi.indirect.diffuse += bakedColor;

                #if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
                    ResetUnityLight(o_gi.light);
                    o_gi.indirect.diffuse = SubtractMainLightWithRealtimeAttenuationFromLightmap(o_gi.indirect.diffuse, data.atten, bakedColorTex, normalWorld);
                #endif

            #endif
        #endif

        //当采用Realtime GI时
        #ifdef DYNAMICLIGHTMAP_ON
            // Dynamic lightmaps
            fixed4 realtimeColorTex = UNITY_SAMPLE_TEX2D(unity_DynamicLightmap, data.lightmapUV.zw);
            half3 realtimeColor = DecodeRealtimeLightmap (realtimeColorTex);

            #ifdef DIRLIGHTMAP_COMBINED
                half4 realtimeDirTex = UNITY_SAMPLE_TEX2D_SAMPLER(unity_DynamicDirectionality, unity_DynamicLightmap, data.lightmapUV.zw);
                o_gi.indirect.diffuse += DecodeDirectionalLightmap (realtimeColor, realtimeDirTex, normalWorld);
            #else
                o_gi.indirect.diffuse += realtimeColor;
            #endif
        #endif

        o_gi.indirect.diffuse *= occlusion;
        //返回计算后的gi
        return o_gi;
    }

    inline UnityGI UnityGlobalIllumination1 (UnityGIInput data, half occlusion, half3 normalWorld)
    {
        return UnityGI_Base1(data, occlusion, normalWorld);
    }

    inline void LightingLambert_GI1 (SurfaceOutput s,UnityGIInput data,inout UnityGI gi)
    {
        gi = UnityGlobalIllumination1 (data, 1.0, s.Normal);
    }

#endif