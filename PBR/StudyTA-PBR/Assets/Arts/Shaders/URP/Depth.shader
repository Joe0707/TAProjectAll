Shader "jcy/Depth"
{
    Properties
    {
        _BaseColor ("Base Color", color) = (1,1,1,1)
        _BaseMap ("BaseMap",2D) = "white"{}
    }
    SubShader
    {
        Tags {"Queue"="Geometry""RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" }
        LOD 100
        Pass
        {
            HLSLPROGRAM
            
            
            // Pragmas
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma vertex vert
            #pragma fragment frag
            // #define REQUIRE_DEPTH_TEXTURE
            #define REQUIRE_OPAQUE_TEXTURE

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"
            

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
            CBUFFER_END
            // sampler2D _MainTex;
            TEXTURE2D(_BaseMap);    //纹理的定义，如果是编译到GLES2.0平台，则相当于sampler2D _MainTex;否则相当于Texture2D _MainTex;
            SAMPLER(sampler_BaseMap);  //采样器的定义，如果是编译到GLES2.0平台，就相当于空，否则就相当于SamplerState sampler_MainTex
            TEXTURE2D(_CameraDepthTexture);SAMPLER(sampler_CameraDepthTexture);
            // TEXTURE2D(_CameraOpaqueTexture);SAMPLER(sampler_CameraOpaqueTexture);
            // SAMPLER(SamplerState_Linear_Repeat);
            float4 _BaseMap_ST;
            //顶点着色器的输入(模型的数据信息)
            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv:TEXCOORD;
            };
            
            //顶点着色器的输出
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv:TEXCOORD;
                // float4 screenPos : TEXCOORD1;
            };

            //顶点着色器
            Varyings vert(Attributes v)
            {
                Varyings o = (Varyings)0;
                float3 positionWS = TransformObjectToWorld(v.positionOS);
                o.positionCS = TransformWorldToHClip(positionWS);
                o.uv = TRANSFORM_TEX(v.uv,_BaseMap);
                // o.screenPos = ComputeScreenPos(o.positionCS);
                return o;
            }

            half4 frag(Varyings i) : SV_TARGET 
            {    
                // float2 screenUV = i.positionCS/_ScreenParams.xy;
                // // half4 opaqueMap = SAMPLE_TEXTURE2D(_CameraOpaqueTexture,sampler_CameraOpaqueTexture,screenUV);
                // half3 opaqueMap = SampleSceneColor(screenUV);
                // return half4(1-opaqueMap,1);

                float2 screenUV = i.positionCS/_ScreenParams.xy;
                // float2 uv = i.screenPos.xy/i.screenPos.w;
                //NDC下的Z值存到深度图
                half4 depthMap = SAMPLE_TEXTURE2D(_CameraDepthTexture,sampler_CameraDepthTexture,screenUV);
                // half depth = LinearEyeDepth(depthMap,_ZBufferParams);
                half depth = Linear01Depth(depthMap,_ZBufferParams);
                return depth;
                half4 c;
                // half4 mainTex = tex2D(_MainTex,i.uv);    默认管线的纹理采样操作
                half4 mainTex = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,i.uv);
                c = mainTex*_BaseColor;
                return c;
            }            
            ENDHLSL
        }
    }
}
