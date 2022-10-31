Shader "jcy/Template/Unlit"
{  
    Properties
    {
        _MainTex ("MainTex", 2D) = "" {}
    }
    SubShader
    {
        Tags { "Queue"="Geometry"
            "RenderPipeline" = "UniversalPipeline"
        }
        LOD 200
        Pass{
            Name "Unlit"
            Tags{
                "LightMode" = "UniversalForward"
            }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex:POSITION;
                float2 uv:TEXCOORD0;
            };

            struct v2f
            {
                float2 uv:TEXCOORD0;
                float4 pos:SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                return o;
            }
            
            half4 frag(v2f i):SV_Target
            {
                half4 col = tex2D(_MainTex,i.uv);
                return col;
            }
            
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}