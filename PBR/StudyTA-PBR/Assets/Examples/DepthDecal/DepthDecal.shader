Shader "taecg/URP/Depth Decal"
{
    Properties
    {
        _BaseColor("Base Color",color) = (1,1,1,1)
        _BaseMap("BaseMap", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" "RenderPipeline" = "UniversalPipeline" }
        LOD 100

        Pass
        {
            Blend One One

            Name "Unlit"
            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS       : POSITION;
                float2 uv               : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS       : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float fogCoord      : TEXCOORD1;
                float4 positionOS   : TEXCOORD2;
                float3 positionVS   : TEXCOORD3;    //顶点在观察空间下的坐标
            };

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
            CBUFFER_END
            TEXTURE2D (_BaseMap);//SAMPLER(sampler_BaseMap);
            TEXTURE2D(_CameraDepthTexture);SAMPLER(sampler_CameraDepthTexture);
            #define smp _linear_clamp
            SAMPLER(smp);

            Varyings vert(Attributes v)
            {
                Varyings o = (Varyings)0;

                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                o.fogCoord = ComputeFogFactor(o.positionCS.z);
                o.positionOS = v.positionOS;
                o.positionVS = TransformWorldToView(TransformObjectToWorld(v.positionOS));
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                //思路：
                //通过深度图求出像素所在的观察空间中的Z轴
                //通过当前渲染的面片求出像素在观察空间下的坐标
                //通过以上两者求出深度图中的像素的XYZ坐标
                //再将此坐标转换面片模型的本地空间,把XY当作UV来进行纹理采样。

                float2 screenUV = i.positionCS.xy/_ScreenParams.xy;
                half depthMap = SAMPLE_TEXTURE2D(_CameraDepthTexture,sampler_CameraDepthTexture,screenUV);
                half depthZ = LinearEyeDepth(depthMap,_ZBufferParams);

                //构建深度图上的像素在观察空间下的坐标
                float4 depthVS = 1;
                depthVS.xy = i.positionVS.xy*depthZ/-i.positionVS.z;
                depthVS.z = depthZ;
                //构建深度图上的像素在世界空间下的坐标
                float3 depthWS = mul(unity_CameraToWorld,depthVS);
                float3 depthOS = mul(unity_WorldToObject,float4(depthWS,1));

                // return frac(depthOS.y);
                float2 uv = depthOS.xz + 0.5;

                half4 c;
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, smp, uv);
                c = baseMap * _BaseColor;
                
                //针对Blend One One的雾效混合方式
                c.rgb *= saturate(lerp(1,0,i.fogCoord));
                return c;
            }
            ENDHLSL
        }
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
        LOD 100

        Pass
        {
            Blend One One

            Name "Unlit"
            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS       : POSITION;
                float2 uv               : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS       : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float fogCoord      : TEXCOORD1;
                float4 positionOS   : TEXCOORD2;
                float3 positionVS   : TEXCOORD3;    //顶点在观察空间下的坐标
            };

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
            CBUFFER_END
            TEXTURE2D (_BaseMap);//SAMPLER(sampler_BaseMap);
            TEXTURE2D(_CameraDepthTexture);SAMPLER(sampler_CameraDepthTexture);
            #define smp _linear_clamp
            SAMPLER(smp);

            Varyings vert(Attributes v)
            {
                Varyings o = (Varyings)0;

                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                o.fogCoord = ComputeFogFactor(o.positionCS.z);
                o.positionOS = v.positionOS;
                o.positionVS = TransformWorldToView(TransformObjectToWorld(v.positionOS));
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                //思路：
                //通过深度图求出像素所在的观察空间中的Z轴
                //通过当前渲染的面片求出像素在观察空间下的坐标
                //通过以上两者求出深度图中的像素的XYZ坐标
                //再将此坐标转换面片模型的本地空间,把XY当作UV来进行纹理采样。

                float2 screenUV = i.positionCS.xy/_ScreenParams.xy;
                half depthMap = SAMPLE_TEXTURE2D(_CameraDepthTexture,sampler_CameraDepthTexture,screenUV);
                half depthZ = LinearEyeDepth(depthMap,_ZBufferParams);

                //构建深度图上的像素在观察空间下的坐标
                float4 depthVS = 1;
                depthVS.xy = i.positionVS.xy*depthZ/-i.positionVS.z;
                depthVS.z = depthZ;
                //构建深度图上的像素在世界空间下的坐标
                float3 depthWS = mul(unity_CameraToWorld,depthVS);
                float3 depthOS = mul(unity_WorldToObject,float4(depthWS,1));

                // return frac(depthOS.y);
                float2 uv = depthOS.xz + 0.5;

                half4 c;
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, smp, uv);
                c = baseMap * _BaseColor;

                //针对Blend One One的雾效混合方式
                c.rgb *= saturate(lerp(1,0,i.fogCoord));
                return c;
            }
            ENDHLSL
        }
    }
}
