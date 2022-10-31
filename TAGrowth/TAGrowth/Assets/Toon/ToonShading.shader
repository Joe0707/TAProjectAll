Shader "jcy/ToonShading"
{  
    Properties
    {
        _MainTex ("MainTex", 2D) = "" {}
        _OutlineWidth("Outline Width",float) = 1
        _OutlineColor("Outline Color",color) = (0,0,0,1)
        _FixedWidth("Fixed Width",Range(0,1)) = 1
        // _StencilRef("Stencil Ref",int) = 1
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
            // Stencil
            // {
            //     Ref [_StencilRef]
            //     Comp Always
            //     Pass Replace
            // }
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
            // Stencil
            // {
            //     Ref [_StencilRef]
            //     Comp NotEqual
            // }
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
                float _FixedWidth;
            CBUFFER_END
            v2f vert(appdata v)
            {
                v2f o;
                float3 p1 = mul(GetObjectToWorldMatrix(),v.vertex).xyz;
                float camDistance = length(_WorldSpaceCameraPos-p1);
                camDistance = lerp(1,camDistance,_FixedWidth);
                float3 width = v.normal * _OutlineWidth*camDistance*0.01;

                float3 pos = v.vertex+width;
                o.pos = TransformObjectToHClip(pos); //clip space
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