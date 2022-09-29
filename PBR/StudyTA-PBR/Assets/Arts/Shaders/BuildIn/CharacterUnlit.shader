Shader "taecg/Character Unlit"
{
    Properties
    {
        [Header(Base)]
        [NoScaleOffset]_MainTex("MainTex",2D) = "white"{}
        _Color ("Color",Color) = (0,0,0,0)

        [Space(10)]
        [Header(Dissolve)]
        [Toggle]_DissolveEnabled("Dissolve Enabled",int) = 0
        _DissolveTex("DissolveTex(R)",2D) = "white"{}
        [NoScaleOffset]_RampTex("RampTex(RGB)",2D)= "white"{}
        _Clip("Clip",Range(0,1)) = 0

        [Header(Shadow)]
        _Shadow("Offset(XZ) Height(Y) Alpha(W)",vector) = (0.2,0,0.3,0)
    }

    SubShader
    {
        Tags{"Queue" = "Geometry"}
        LOD 600
        Blend Off
        Cull Back
        Offset 0,0

        UsePass "taecg/XRay/XRAY"

        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _DISSOLVEENABLED_ON
            // #pragma multi_compile_fwdbase
            #pragma multi_compile DIRECTIONAL SHADOWS_SCREEN
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            fixed4 _Color;
            sampler2D _DissolveTex;float4 _DissolveTex_ST;
            sampler _RampTex;
            fixed _Clip;

            struct appdata
            {
                float4 vertex   :POSITION;
                float4 uv       :TEXCOORD;
            };

            struct v2f
            {
                float4 pos  :SV_POSITION;
                float4 uv   :TEXCOORD;
                float4 worldPos:TEXCOORD1;
                UNITY_SHADOW_COORDS(2)
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.uv.xy;
                // o.uv.zw = v.uv*_DissolveTex_ST.xy+_DissolveTex_ST.zw;
                o.uv.zw = TRANSFORM_TEX(v.uv,_DissolveTex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);

                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos)

                fixed4 c;
                fixed4 tex = tex2D(_MainTex,i.uv.xy);
                c = tex * atten;
                c += _Color;

                #if _DISSOLVEENABLED_ON
                    fixed4 dissolveTex=tex2D(_DissolveTex,i.uv.zw);
                    clip(dissolveTex.r-_Clip);
                    fixed dissolveValue = saturate((dissolveTex.r-_Clip)/(_Clip+0.1-_Clip));
                    fixed4 rampTex = tex1D(_RampTex,dissolveValue);
                    c += rampTex;
                #endif

                return c;
            }

            ENDCG
        }

        // pass
        // {
        //     Tags {"LightMode" = "ShadowCaster"}
        //     CGPROGRAM
        //     #pragma vertex vert
        //     #pragma fragment frag
        //     #pragma multi_compile _ _DISSOLVEENABLED_ON
        //     #pragma multi_compile_shadowcaster
        //     #include "UnityCG.cginc"

        //     struct appdata
        //     {
        //         float4 vertex:POSITION;
        //         half3 normal:NORMAL;
        //         float4 uv:TEXCOORD;
        //     };

        //     struct v2f
        //     {
        //         float4 uv:TEXCOORD;
        //         V2F_SHADOW_CASTER;
        //     };

        //     sampler2D _DissolveTex;float4 _DissolveTex_ST;
        //     fixed _Clip;

        //     v2f vert(appdata v)
        //     {
        //         v2f o;
        //         o.uv.zw = TRANSFORM_TEX(v.uv,_DissolveTex);
        //         TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
        //         return o;
        //     }

        //     fixed4 frag(v2f i):SV_TARGET
        //     {
        //         #if _DISSOLVEENABLED_ON
        //             fixed4 dissolveTex=tex2D(_DissolveTex,i.uv.zw);
        //             clip(dissolveTex.r-_Clip);
        //         #endif
                
        //         SHADOW_CASTER_FRAGMENT(i)
        //     }
        //     ENDCG
        // }
    }

    SubShader
    {
        LOD 400
        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _DISSOLVEENABLED_ON
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            fixed4 _Color;
            sampler2D _DissolveTex;float4 _DissolveTex_ST;
            sampler _RampTex;
            fixed _Clip;

            struct appdata
            {
                float4 vertex   :POSITION;
                float4 uv       :TEXCOORD;
            };

            struct v2f
            {
                float4 pos  :SV_POSITION;
                float4 uv   :TEXCOORD;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.uv.xy;
                // o.uv.zw = v.uv*_DissolveTex_ST.xy+_DissolveTex_ST.zw;
                o.uv.zw = TRANSFORM_TEX(v.uv,_DissolveTex);
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                fixed4 c;
                fixed4 tex = tex2D(_MainTex,i.uv.xy);
                c = tex;
                c += _Color;

                #if _DISSOLVEENABLED_ON
                    fixed4 dissolveTex=tex2D(_DissolveTex,i.uv.zw);
                    clip(dissolveTex.r-_Clip);
                    fixed dissolveValue = saturate((dissolveTex.r-_Clip)/(_Clip+0.1-_Clip));
                    fixed4 rampTex = tex1D(_RampTex,dissolveValue);
                    c += rampTex;
                #endif

                return c;
            }

            ENDCG
        }

        pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            Stencil
            {
                Ref 100
                Comp NotEqual
                Pass Replace
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float4 _Shadow;

            struct appdata
            {
                float4 vertex:POSITION;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                float4 worldPos = mul(unity_ObjectToWorld,v.vertex);
                float worldPosY = worldPos.y;
                worldPos.y = _Shadow.y;
                worldPos.xz += _Shadow.xz * (worldPosY - _Shadow.y);
                o.pos = mul(UNITY_MATRIX_VP,worldPos);
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                fixed4 c = 0;
                c.a = _Shadow.w;
                return c;
            }
            ENDCG
        }
    }

    //Fallback "Legacy Shaders/VertexLit"
}