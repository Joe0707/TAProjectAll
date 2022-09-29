#ifndef MYPHYSICALLYBASEDRENDERING_CGINCLUDE
    #define MYPHYSICALLYBASEDRENDERING_CGINCLUDE
    
    //GI中镜面反射的Fresnel过渡
    //F0 = 视线与物体法线夹角为0度的情况 
    //F90 = 视线与物体法线夹角为90度的情况
    inline half3 FresnelLerp1 (half3 F0, half3 F90, half cosA)
    {
        half t = Pow5 (1 - cosA);   // ala Schlick interpoliation
        return lerp (F0, F90, t);
    }

    //F项的计算
    inline half3 FresnelTerm1 (half3 F0, half cosA)
    {
        half t = Pow5 (1 - cosA);   // ala Schlick interpoliation
        return F0 + (1-F0) * t;
    }

    //V项的计算
    // Ref: http://jcgt.org/published/0003/02/03/paper.pdf
    inline float SmithJointGGXVisibilityTerm1 (float NdotL, float NdotV, float roughness)
    {
        #if 0
            // Original formulation:
            //  lambda_v    = (-1 + sqrt(a2 * (1 - NdotL2) / NdotL2 + 1)) * 0.5f;
            //  lambda_l    = (-1 + sqrt(a2 * (1 - NdotV2) / NdotV2 + 1)) * 0.5f;
            //  G           = 1 / (1 + lambda_v + lambda_l);

            // Reorder code to be more optimal
            half a          = roughness;
            half a2         = a * a;

            half lambdaV    = NdotL * sqrt((-NdotV * a2 + NdotV) * NdotV + a2);
            half lambdaL    = NdotV * sqrt((-NdotL * a2 + NdotL) * NdotL + a2);

            // Simplify visibility term: (2.0f * NdotL * NdotV) /  ((4.0f * NdotL * NdotV) * (lambda_v + lambda_l + 1e-5f));
            return 0.5f / (lambdaV + lambdaL + 1e-5f);  // This function is not intended to be running on Mobile,
            // therefore epsilon is smaller than can be represented by half
        #else
            //上面公式的一个近似实现(简化平方根，数学上不太精确但是效果比较接近)
            // Approximation of the above formulation (simplify the sqrt, not mathematically correct but close enough)
            float a = roughness;
            float lambdaV = NdotL * (NdotV * (1 - a) + a);
            float lambdaL = NdotV * (NdotL * (1 - a) + a);

            #if defined(SHADER_API_SWITCH)
                return 0.5f / (lambdaV + lambdaL + 1e-4f); // work-around against hlslcc rounding error
            #else
                return 0.5f / (lambdaV + lambdaL + 1e-5f);
            #endif

        #endif
    }

    //D项的计算
    inline float GGXTerm1 (float NdotH, float roughness)
    {
        float a2 = roughness * roughness;
        float d = (NdotH * a2 - NdotH) * NdotH + 1.0f; // 2 mad
        return UNITY_INV_PI * a2 / (d * d + 1e-7f); // This function is not intended to be running on Mobile,
        // therefore epsilon is smaller than what can be represented by half
    }

    //为了保证分母不为0而使用的一种安全的归一化
    inline float3 Unity_SafeNormalize1(float3 inVec)
    {
        //normalize(v) = rsqrt(dot(v,v))*v;
        float dp3 = max(0.001f, dot(inVec, inVec));
        return inVec * rsqrt(dp3);
    }

    //迪士尼的漫反射计算
    // Note: Disney diffuse must be multiply by diffuseAlbedo / PI. This is done outside of this function.
    half DisneyDiffuse1(half NdotV, half NdotL, half LdotH, half perceptualRoughness)
    {
        half fd90 = 0.5 + 2 * LdotH * LdotH * perceptualRoughness;
        // Two schlick fresnel term
        half lightScatter   = (1 + (fd90 - 1) * Pow5(1 - NdotL));
        half viewScatter    = (1 + (fd90 - 1) * Pow5(1 - NdotV));

        return lightScatter * viewScatter;
    }

    // Note: BRDF entry points use smoothness and oneMinusReflectivity for optimization
    // purposes, mostly for DX9 SM2.0 level. Most of the math is being done on these (1-x) values, and that saves
    // a few precious ALU slots.


    // Main Physically Based BRDF
    // Derived from Disney work and based on Torrance-Sparrow micro-facet model
    //
    //   BRDF = kD / pi + kS * (D * V * F) / 4
    //   I = BRDF * NdotL
    //
    // * NDF (depending on UNITY_BRDF_GGX):
    //  a) Normalized BlinnPhong
    //  b) GGX
    // * Smith for Visiblity term
    // * Schlick approximation for Fresnel
    half4 BRDF1_Unity_PBS1 (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
    float3 normal, float3 viewDir,
    UnityLight light, UnityIndirect gi)
    {
        //感性的粗糙度 = (1 - smoothness);
        float perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
        //通过光线方向与视线方向相加可得到它们的半角向量
        float3 halfDir = Unity_SafeNormalize1 (float3(light.dir) + viewDir);

        //法线与视线的点积在可见像素上不应该出现负值，但是它有可能发生在投影与法线映射时，可以通过某些方式来修正，但是会产生额外的指令运算
        //替代方案采用abs的形式，同样可以工作只是正确性会少一些。
        // NdotV should not be negative for visible pixels, but it can happen due to perspective projection and normal mapping
        // In this case normal should be modified to become valid (i.e facing camera) and not cause weird artifacts.
        // but this operation adds few ALU and users may not want it. Alternative is to simply take the abs of NdotV (less correct but works too).
        // Following define allow to control this. Set it to 0 if ALU is critical on your platform.
        // This correction is interesting for GGX with SmithJoint visibility function because artifacts are more visible in this case due to highlight edge of rough surface
        // Edit: Disable this code by default for now as it is not compatible with two sided lighting used in SpeedTree.
        #define UNITY_HANDLE_CORRECTLY_NEGATIVE_NDOTV 0

        #if UNITY_HANDLE_CORRECTLY_NEGATIVE_NDOTV
            // The amount we shift the normal toward the view vector is defined by the dot product.
            half shiftAmount = dot(normal, viewDir);
            normal = shiftAmount < 0.0f ? normal + viewDir * (-shiftAmount + 1e-5f) : normal;
            // A re-normalization should be applied here but as the shift is small we don't do it to save ALU.
            //normal = normalize(normal);

            float nv = saturate(dot(normal, viewDir)); // TODO: this saturate should no be necessary here
        #else
            half nv = abs(dot(normal, viewDir));    // This abs allow to limit artifact
        #endif

        //各种方向的点积运算
        float nl = saturate(dot(normal, light.dir));
        float nh = saturate(dot(normal, halfDir));
        half lv = saturate(dot(light.dir, viewDir));
        half lh = saturate(dot(light.dir, halfDir));

        // 迪士尼原则的漫反射
        //理论上漫反射项中应该除以PI，但是由于以下两点却没有这样做
        //1.这样会导致颜色比旧的材质更暗
        //2.从引擎层面看的话，被标记为不重要的灯光在SH时还会进行除以PI的操作
        // HACK: theoretically we should divide diffuseTerm by Pi and not multiply specularTerm!
        // BUT 1) that will make shader look significantly darker than Legacy ones
        // and 2) on engine side "Non-important" lights have to be divided by Pi too in cases when they are injected into ambient SH
        half diffuseTerm = DisneyDiffuse1(nv, nl, lh, perceptualRoughness) * nl;

        // Specular term
        //声明一个学术上的粗糙度，perceptualRoughness * perceptualRoughness
        float roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
        //GGX模型拥有比较好的效果
        #if UNITY_BRDF_GGX
            // GGX with roughtness to 0 would mean no specular at all, using max(roughness, 0.002) here to match HDrenderloop roughtness remapping.
            roughness = max(roughness, 0.002);
            float V = SmithJointGGXVisibilityTerm1 (nl, nv, roughness);
            float D = GGXTerm1 (nh, roughness);
        #else
            // Legacy
            half V = SmithBeckmannVisibilityTerm (nl, nv, roughness);
            half D = NDFBlinnPhongNormalizedTerm (nh, PerceptualRoughnessToSpecPower(perceptualRoughness));
        #endif

        //镜面反射中的DV项的计算
        //最后乘以PI的原因是因为上面漫反射部分应该除的PI没有除，所以式子两边同时乘以PI
        float specularTerm = V*D * UNITY_PI; // Torrance-Sparrow model, Fresnel is applied later

        //如果处于GAMMA空间的话
        #   ifdef UNITY_COLORSPACE_GAMMA
        specularTerm = sqrt(max(1e-4h, specularTerm));
        #   endif

        // specularTerm * nl can be NaN on Metal in some cases, use max() to make sure it's a sane value
        specularTerm = max(0, specularTerm * nl);
        //材质上的镜面高光开关
        #if defined(_SPECULARHIGHLIGHTS_OFF)
            specularTerm = 0.0;
        #endif

        // surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(roughness^2+1)
        half surfaceReduction;
        #   ifdef UNITY_COLORSPACE_GAMMA
        //GAMMA空间,采用一个近似的公式来简化计算(1-0.28*x^3)
        surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;      // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
        #   else
        //线性空间
        surfaceReduction = 1.0 / (roughness*roughness + 1.0);           // fade \in [0.5;1]
        #   endif

        // To provide true Lambert lighting, we need to be able to kill specular completely.
        //=?:这是一个三目运算符
        //当metallic=1时，并且Albedo为纯黑色时的情况
        specularTerm *= any(specColor) ? 1.0 : 0.0;

        half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
        //漫反射
        half3 diffuse = diffColor * (gi.diffuse + light.color * diffuseTerm);
        //镜面反射DFG/4coslcosv
        //DG = specularTerm
        //F = FresnelTerm
        half3 specular =  specularTerm * light.color * FresnelTerm1 (specColor, lh);
        //IBL （Image Based Lighting）基于图像的光照
        //surfaceReduction = 衰减
        //gi.specular = 间接光中的镜面反射
        //FresnelLerp = 镜面反射在不同角度下的过渡(F0-F90)
        half3 ibl = surfaceReduction * gi.specular * FresnelLerp1 (specColor, grazingTerm, nv);

        half3 color =   diffuse + specular + ibl;
        return half4(color, 1);
    }

    // Default BRDF to use:
    //TierSetting中设置
    //StandardShaderQuality = low （UNITY_PBS_USE_BRDF3）
    //StandardShaderQuality = Medium UNITY_PBS_USE_BRDF2
    //StandardShaderQuality = High UNITY_PBS_USE_BRDF1
    #if !defined (UNITY_BRDF_PBS1) // allow to explicitly override BRDF in custom shader
        // still add safe net for low shader models, otherwise we might end up with shaders failing to compile
        #if SHADER_TARGET < 30 || defined(SHADER_TARGET_SURFACE_ANALYSIS) // only need "something" for surface shader analysis pass; pick the cheap one
            #define UNITY_BRDF_PBS BRDF3_Unity_PBS  //效果最差的BRDF
        #elif defined(UNITY_PBS_USE_BRDF3)
            #define UNITY_BRDF_PBS BRDF3_Unity_PBS
        #elif defined(UNITY_PBS_USE_BRDF2)
            #define UNITY_BRDF_PBS BRDF2_Unity_PBS
        #elif defined(UNITY_PBS_USE_BRDF1)
            #define UNITY_BRDF_PBS1 BRDF1_Unity_PBS1
        #else
            #error something broke in auto-choosing BRDF
        #endif
    #endif

    inline half OneMinusReflectivityFromMetallic1(half metallic)
    {
        // We'll need oneMinusReflectivity, so
        //   1-reflectivity = 1-lerp(dielectricSpec, 1, metallic) = lerp(1-dielectricSpec, 0, metallic)
        // store (1-dielectricSpec) in unity_ColorSpaceDielectricSpec.a, then
        //   1-reflectivity = lerp(alpha, 0, metallic) = alpha + metallic*(0 - alpha) =
        //                  = alpha - metallic * alpha
        half oneMinusDielectricSpec = unity_ColorSpaceDielectricSpec.a;
        return oneMinusDielectricSpec - metallic * oneMinusDielectricSpec;
    }

    inline half3 DiffuseAndSpecularFromMetallic1 (half3 albedo, half metallic, out half3 specColor, out half oneMinusReflectivity)
    {
        //计算反射颜色
        //当metallic = 0时(非金属时，或者绝缘体)，返回unity_ColorSpaceDielectricSpec.rgb
        //unity_ColorSpaceDielectricSpec表示的是绝缘体的通用反射颜色，迪士尼经大量测量用0.04来表示
        //当metallic = 1时（金属时）,返回albedo,也就是物体本身的颜色信息
        specColor = lerp (unity_ColorSpaceDielectricSpec.rgb, albedo, metallic);
        //计算1-反射率(漫反射反射率)
        oneMinusReflectivity = OneMinusReflectivityFromMetallic1(metallic);
        return albedo * oneMinusReflectivity;
    }

    //进行BRDF之前的数准备
    //s = 物体表面数据信息
    //viewDir = 视线方向
    //gi = 全局光照(GI漫反射与GI镜面反射)
    inline half4 LightingStandard1 (SurfaceOutputStandard s, float3 viewDir, UnityGI gi)
    {
        s.Normal = normalize(s.Normal);

        half oneMinusReflectivity;
        half3 specColor;
        s.Albedo = DiffuseAndSpecularFromMetallic1 (s.Albedo, s.Metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

        // shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
        // this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
        // 当开启透明模式时进行的Alpha相关计算
        half outputAlpha;
        s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);

        //具体的BRDF
        //s.Albedo = 物体表面的基础颜色
        //specColor = 镜面反射颜色
        //oneMinusReflectivity = 漫反射率(1-镜面反射率)
        //s.Smoothness = 物体表面的光滑度
        //s.Norma = 物体表面的法线
        //viewDir = 视线方向
        //gi.light = 直接光信息
        //gi.indirect = 间接光信息
        half4 c = UNITY_BRDF_PBS1 (s.Albedo, specColor, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);
        c.a = outputAlpha;
        return c;
    }

    half3 Unity_GlossyEnvironment1 (UNITY_ARGS_TEXCUBE(tex), half4 hdr, Unity_GlossyEnvironmentData glossIn)
    {
        //声明感性粗糙度
        half perceptualRoughness = glossIn.roughness /* perceptualRoughness */ ;

        // TODO: CAUTION: remap from Morten may work only with offline convolution, see impact with runtime convolution!
        // For now disabled
        #if 0
            float m = PerceptualRoughnessToRoughness(perceptualRoughness); // m is the real roughness parameter
            const float fEps = 1.192092896e-07F;        // smallest such that 1.0+FLT_EPSILON != 1.0  (+1e-4h is NOT good here. is visibly very wrong)
            float n =  (2.0/max(fEps, m*m))-2.0;        // remap to spec power. See eq. 21 in --> https://dl.dropboxusercontent.com/u/55891920/papers/mm_brdf.pdf

            n /= 4;                                     // remap from n_dot_h formulatino to n_dot_r. See section "Pre-convolved Cube Maps vs Path Tracers" --> https://s3.amazonaws.com/docs.knaldtech.com/knald/1.0.0/lys_power_drops.html

            perceptualRoughness = pow( 2/(n+2), 0.25);      // remap back to square root of real roughness (0.25 include both the sqrt root of the conversion and sqrt for going from roughness to perceptualRoughness)
        #else
            // MM: came up with a surprisingly close approximation to what the #if 0'ed out code above does.
            // r = r*(1.7-0.7*r)
            //由于粗糙度与反射探针的mip变化不呈现线性正比，所以需要一个公式来改变
            perceptualRoughness = perceptualRoughness*(1.7 - 0.7*perceptualRoughness);
        #endif

        //perceptualRoughnessToMipmapLevel = perceptualRoughness * UNITY_SPECCUBE_LOD_STEPS; 粗糙度x6得到最终的mip级别
        //UNITY_SPECCUBE_LOD_STEPS = 6,表示反射探针的mip级别有6档
        half mip = perceptualRoughnessToMipmapLevel(perceptualRoughness);
        half3 R = glossIn.reflUVW;
        half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(tex, R, mip);
        //颜色解码返回
        return DecodeHDR(rgbm, hdr);
    }

    //GI中的镜面反射计算
    inline half3 UnityGI_IndirectSpecular1(UnityGIInput data, half occlusion, Unity_GlossyEnvironmentData glossIn)
    {
        //声明返回的变量specular
        half3 specular;

        //如果开启了BoxProjection模式的话
        #ifdef UNITY_SPECCUBE_BOX_PROJECTION
            // we will tweak reflUVW in glossIn directly (as we pass it to Unity_GlossyEnvironment twice for probe0 and probe1), so keep original to pass into BoxProjectedCubemapDirection
            half3 originalReflUVW = glossIn.reflUVW;
            glossIn.reflUVW = BoxProjectedCubemapDirection (originalReflUVW, data.worldPos, data.probePosition[0], data.boxMin[0], data.boxMax[0]);
        #endif

        //如果勾选了Standard材质面板中的禁用反射功能的话
        #ifdef _GLOSSYREFLECTIONS_OFF
            specular = unity_IndirectSpecColor.rgb;
        #else
            half3 env0 = Unity_GlossyEnvironment1 (UNITY_PASS_TEXCUBE(unity_SpecCube0), data.probeHDR[0], glossIn);
            //如果开启了反射探针的混合的话
            #ifdef UNITY_SPECCUBE_BLENDING
                const float kBlendFactor = 0.99999;
                float blendLerp = data.boxMin[0].w;
                UNITY_BRANCH
                if (blendLerp < kBlendFactor)
                {
                    #ifdef UNITY_SPECCUBE_BOX_PROJECTION
                        glossIn.reflUVW = BoxProjectedCubemapDirection (originalReflUVW, data.worldPos, data.probePosition[1], data.boxMin[1], data.boxMax[1]);
                    #endif

                    half3 env1 = Unity_GlossyEnvironment (UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1,unity_SpecCube0), data.probeHDR[1], glossIn);
                    specular = lerp(env1, env0, blendLerp);
                }
                else
                {
                    specular = env0;
                }
            #else
                specular = env0;
            #endif
        #endif
        return specular * occlusion;
    }

    //GI计算
    inline UnityGI UnityGlobalIllumination1 (UnityGIInput data, half occlusion, half3 normalWorld, Unity_GlossyEnvironmentData glossIn)
    {
        //声明返回结构UnityGI,并计算得出GI中的漫反射
        UnityGI o_gi = UnityGI_Base(data, occlusion, normalWorld);
        o_gi.indirect.specular = UnityGI_IndirectSpecular1(data, occlusion, glossIn);
        return o_gi;
    }

    float SmoothnessToPerceptualRoughness1(float smoothness)
    {
        return (1 - smoothness);
    }

    Unity_GlossyEnvironmentData UnityGlossyEnvironmentSetup1(half Smoothness, half3 worldViewDir, half3 Normal, half3 fresnel0)
    {
        //声明返回的结构体g
        Unity_GlossyEnvironmentData g;

        //粗糙度
        g.roughness /* perceptualRoughness */   = SmoothnessToPerceptualRoughness1(Smoothness);
        //反射球的采样坐标
        g.reflUVW   = reflect(-worldViewDir, Normal);

        return g;
    }

    //PBR光照模型的GI计算
    inline void LightingStandard_GI1 (SurfaceOutputStandard s,UnityGIInput data,inout UnityGI gi)
    {
        //如果是延迟渲染PASS并且开启了延迟渲染反射探针的话
        #if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
            gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
        #else
            //Unity_GlossyEnvironmentData表示GI中的反射准备数据
            Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup1(s.Smoothness, data.worldViewDir, s.Normal, lerp(unity_ColorSpaceDielectricSpec.rgb, s.Albedo, s.Metallic));
            //进行GI计算并返回输出gi
            gi = UnityGlobalIllumination1(data, s.Occlusion, s.Normal, g);
        #endif
    }

#endif