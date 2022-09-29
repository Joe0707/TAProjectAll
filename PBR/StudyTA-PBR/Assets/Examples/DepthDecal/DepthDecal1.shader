Shader "jcy/URP/DepthDecal1"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
        _MainTex("MainTex",2D) = "white"{}
    }
    SubShader
    {
        Tags
        {
            //告诉引擎此SubShader是用于URP渲染管线下的
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        
        Pass
        {
            Name "Pass"
            Tags 
            { 
                // LightMode: <None>
            }
            
            // Render State
            Blend One One
            Cull Back
            ZTest LEqual
            ZWrite On
            // ColorMask: <None>
            
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            
            // Pragmas
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"
            
            CBUFFER_START(UnityPerMaterial)
                half4 _Color;
            CBUFFER_END
            // sampler2D _MainTex;
            TEXTURE2D(_MainTex);    //纹理的定义，如果是编译到GLES2.0平台，则相当于sampler2D _MainTex;否则相当于Texture2D _MainTex;
            //SAMPLER(sampler_MainTex);  //采样器的定义，如果是编译到GLES2.0平台，就相当于空，否则就相当于SamplerState sampler_MainTex
            TEXTURE2D(_CameraDepthTexture);SAMPLER(sampler_CameraDepthTexture);
            #define smp _linear_clamp
            SAMPLER(smp);
            // SAMPLER(SamplerState_Linear_Repeat);
            float4 _MainTex_ST;
            //顶点着色器的输入(模型的数据信息)
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv:TEXCOORD;
            };
            
            //顶点着色器的输出
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv:TEXCOORD;
                float4 positionOS : TEXCOORD1;
                float3 positionVS: TEXCOORD2;//顶点在观察空间下的坐标
                float fogCoord:TEXCOORD3;
            };

            //顶点着色器
            Varyings vert(Attributes v)
            {
                Varyings o = (Varyings)0;
                float3 positionWS = TransformObjectToWorld(v.positionOS);
                o.positionCS = TransformWorldToHClip(positionWS);
                o.fogCoord = ComputeFogFactor(o.positionCS.z);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                o.positionOS = v.positionOS;
                o.positionVS = TransformWorldToView(TransformObjectToWorld(v.positionOS));
                return o;
            }

            half4 frag(Varyings i) : SV_TARGET 
            {    
                //思路：
                //通过深度图求出像素所在的观察空间中的Z值
                //通过当前渲染的面片求出像素在观察空间下的坐标
                //通过以上两者求出深度图中的像素的XYZ坐标
                //再将此坐标转换面片模型的本地空间，把XY当作UV来进行纹理采样
                float2 screenUV = i.positionCS.xy/_ScreenParams.xy;
                half depthMap = SAMPLE_TEXTURE2D(_CameraDepthTexture,sampler_CameraDepthTexture,screenUV);
                half depthZ = LinearEyeDepth(depthMap,_ZBufferParams);
                // return depthZ;
                //构建深度图上的像素在观察空间下的坐标
                float4 depthVS = 1;
                depthVS.xy = i.positionVS.xy*depthZ/-i.positionVS.z;
                depthVS.z = depthZ;
                //构建深度图上的像素在世界空间下的坐标
                float3 depthWS = mul(unity_CameraToWorld,depthVS);
                float3 depthOS = mul(unity_WorldToObject,float4(depthWS,1));
                // return frac(depthOS.x);
                float2 uv = depthOS.xz+0.5;
                half4 c;
                // half4 mainTex = tex2D(_MainTex,i.uv);    默认管线的纹理采样操作
                half4 mainTex = SAMPLE_TEXTURE2D(_MainTex,smp,uv);
                c = mainTex*_Color;
                //针对Blend One One的雾效混合方式
                c.rgb*= saturate(lerp(1,0,i.fogCoord));
                // c.rgb = MixFog(c.rgb,i.fogCoord);
                // return i.fogCoord.xxxx;
                return c;
            }            
            ENDHLSL
        }
        
    }
    FallBack "Hidden/Shader Graph/FallbackError"
}
