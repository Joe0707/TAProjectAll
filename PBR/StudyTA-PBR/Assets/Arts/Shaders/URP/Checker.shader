Shader "jcy/Checker"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Repeat ("Repeat",float) = 5
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull Mode",int) = 0
    }
    SubShader
    {
        Tags {"RenderType"="Opaque"
            "RenderPipeline" = "UniversalPipeline" 
        }
        LOD 100
        Cull [_Cull]
        Pass
        {
            HLSLPROGRAM
            
            
            // Pragmas
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"
            
            //顶点着色器的输入(模型的数据信息)
            struct Attributes
            {
                float3 vertexOS : POSITION;
                float2 uv:TEXCOORD0;
            };
            
            //顶点着色器的输出
            struct Varyings
            {
                float2 uv:TEXCOORD0;
                float4 vertexCS : SV_POSITION;
                float3 vertexOS : TEXCOORD1;
                float fogCoord :TEXCOORD2;
                // float4 screenPos : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
                half _Repeat;
                half4 _Color;
            CBUFFER_END

            //顶点着色器
            Varyings vert(Attributes v)
            {
                Varyings o;
                o.vertexOS = v.vertexOS;
                o.vertexCS = TransformObjectToHClip(v.vertexOS);
                o.uv = v.uv*_Repeat;
                o.fogCoord = ComputeFogFactor(o.vertexCS.z);
                return o;
            }

            half4 frag(Varyings i) : SV_TARGET 
            {    
                half4 c;
                float2 uv = floor(i.uv*2)*0.5;
                float checker = frac(uv.x+uv.y)*2;
                half mask = i.vertexOS.y+0.53;
                c = checker*mask;
                c*=_Color;
                c.rgb = MixFog(c,i.fogCoord);
                return c;
            }            
            ENDHLSL
        }
    }
}
