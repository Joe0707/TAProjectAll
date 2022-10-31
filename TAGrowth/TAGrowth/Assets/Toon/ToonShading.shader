Shader "jcy/ToonShading"
{  
    Properties
    {
        _MainTex ("MainTex", 2D) = "" {}
        _OutlineWidth("Outline Width",float) = 1
        _OutlineColor("Outline Color",color) = (0,0,0,1)
        _StencilRef("Stencil Ref",int) = 1
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
            Stencil
            {
                Ref [_StencilRef]
                Comp Always
                Pass Replace
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
            CBUFFER_START(UnityPerMaterial)
                sampler2D _MainTex;
                float4 _MainTex_ST;
                float4 _OutlineColor;
                float _OutlineWidth;
            CBUFFER_END
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
        Pass{
            Name "Outline"
            Tags{
                "LightMode" = "Outline"
            }
            Stencil
            {
                Ref [_StencilRef]
                Comp NotEqual
            }
            Cull Front
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float2 uv:TEXCOORD0;
            };

            struct v2f
            {
                float2 uv:TEXCOORD0;
                float4 pos:SV_POSITION;
            };
            CBUFFER_START(UnityPerMaterial)
                sampler2D _MainTex;
                float4 _MainTex_ST;
                float _OutlineWidth;
                float4 _OutlineColor;
            CBUFFER_END
            v2f vert(appdata v)
            {
                v2f o;
                float3 pos = v.vertex+v.normal*_OutlineWidth;
                o.pos = TransformObjectToHClip(pos);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                return o;
            }
            
            half4 frag(v2f i):SV_Target
            {
                return _OutlineColor;
            }
            
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}