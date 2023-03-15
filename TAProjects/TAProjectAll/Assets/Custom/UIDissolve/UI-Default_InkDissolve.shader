// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "UI/Default_InkDissolve"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
        _TAndO2("Till and Offset 2",Vector) = (5,10,0,0)
        _TAndO3("Till and Offset 3",Vector) = (1,1,-1.81,1)
        _TAndO4("Till and Offset 4",Vector) = (10,10,0,0)
        _FlowSpeed("Flow Speed",Vector) = (-5,0,-5,0)
        _Tiling_Tex("Tiling Texture",2D) = "white" {}
        _P1("Param 1",Float) = 0.151
        _CutValue("Cut Value",Range(0,1)) = 0.9
        _StartCutValue("Start Cut Value",Range(0,1)) = 0.7
        _CutRange("Cut Range",Range(0,1)) = 0.1
        _RampCutStartValue("Ramp Cut Start Value",Range(0,1)) = 0.4
        _RampCutRange("Ramp Cut Range",Range(0,1)) = 0.1
        _RampColorScale("Ramp Color Scale",Range(0,1)) =0.8
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma enable_d3d11_debug_symbols
            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                float4 texcoord  : TEXCOORD0;
                fixed4 color    : COLOR;
                float4 texcoord2  : TEXCOORD1;
                float4 worldPosition : TEXCOORD2;
                float4 texcoord3 : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            sampler2D _Tiling_Tex;
            sampler2D _RampTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            float4 _TAndO2;
            float4 _TAndO3;
            float4 _TAndO4;
            float4 _FlowSpeed;
            float _P1;
            float _CutValue;
            float _StartCutValue;
            float _CutRange;
            float _RampCutStartValue;
            float _RampCutRange;
            float _RampColorScale;
            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                // UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord.xy = TRANSFORM_TEX(v.texcoord, _MainTex).xy;
                // OUT.texcoord.zw = v.texcoord*_TAndO2.xy+_TAndO2.zw;

                OUT.color = v.color * _Color;
                OUT.texcoord2.xy = v.texcoord*_TAndO3.xy+_TAndO3.zw;
                OUT.texcoord2.zw = v.texcoord.xy;

                OUT.texcoord3.xy = OUT.vertex.xy*0.5+(0.5,0.5);
                OUT.texcoord3.zw = OUT.vertex.zw;
                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                half4 color = tex2D(_MainTex, IN.texcoord);
                half4 r0 = half4(0,0,0,0);
                half4 r1 = half4(0,0,0,0);
                half4 r2 = half4(0,0,0,0);
                r0.y = _Time.y*0.05;
                r0.x = r0.y;
                r0.yz = IN.texcoord3.xy/IN.texcoord3.w;
                r1.xy = r0.yz*_TAndO2.xy+_TAndO2.zw;
                r0.yz = r0.yz*_TAndO3.xy+_TAndO3.zw;
                r0.yz = r0.x*_FlowSpeed.xy+r0.yz;
                r2 = tex2D(_Tiling_Tex,r0.yz);
                // return r2;
                r0.yz = r1.xy*_TAndO4.xy+_TAndO4.zw;
                r0.xy = r0.x*_FlowSpeed.zw+r0.yz;
                r0 = tex2D(_Tiling_Tex,r0.xy);
                // return r0;
                r0.x = saturate(r0.x+r2.x);
                // return r0.xxxx;
                r0.y = 1-r0.x;
                r0.x = r0.x*_P1;
                // r0.zw = half2(1,0)-half2(0.5,0);
                // r0.zw = IN.color.r*r0.zw+half2(0.5,0);
                r0.zw = half2(1,2);
                r1.xy = IN.texcoord2.zw+half2(-1.81,1);
                r0.zw = r0.zw+r1.xy;
                r1.x = cos(3.2);
                r1.y = sin(-3.2);
                r0.z = dot(r1.xy,r0.zw);
                r0.w = r0.z;
                r0.z = r0.w;
                // return r0.zzzz;
                r0.z = saturate(1-r0.z);
                half4 ramp = tex2D(_RampTex,IN.texcoord);
                // return r0.yyyy;
                r0.z = ramp.r;
                r0.z = smoothstep(_RampCutStartValue,_RampCutStartValue+_RampCutRange,IN.texcoord.x)*_RampColorScale;
                // return r0.zzzz;
                r0.y = r0.y+r0.z;
                r0.y = r0.y*r0.z;
                // return r0.zzzz;
                r0.y = min(r0.y,1);
                // r0.y = saturate(r0.y-_CutValue);
                // r0.y = r0.y*0.5;
                // r0.z = 0.5;
                // r0.z = r0.z-0.5;
                // r0.z = 1/r0.z;
                // r0.z = 1;
                // // r0.z=1;
                // r0.y = saturate(r0.z*r0.y);
                // r0.z = r0.y*-2+3;
                // r0.y = r0.y*r0.y;
                // r0.y = r0.y*r0.z;
                // // r0.y = min(r0.y,1);
                // r0.y = saturate(r0.y);
                r1 = tex2D(_MainTex,IN.texcoord);
                r0.y = saturate(r0.y);
                // return r0.yyyy;
                // return (1-r0.y).xxxx;
                // return smoothstep(_StartCutValue,_StartCutValue+_CutRange,(1-r0.y));
                // // return smoothstep(0.7,0.8,r1.w*(1-r0.y).xxxx);
                // return smoothstep(0.6,0.7,r1.w*(1-r0.y).xxxx);
                // r0.y = smoothstep(0,0.1,r0.y);
                // return r0.yyyy;
                r0.y = smoothstep(_StartCutValue,_StartCutValue+_CutRange,(1-r0.y));
                // return r0.yyyy;
                // return r0.yyyy;
                // return r0.yyyy;
                // r1.xyz = r1.xyz*half3(0,0,0);
                color.a = r0.y*IN.color.a*color.a;
                // r0.yzw = half3(0.58,0.46,0.46)-half3(0.113,0.04,0.04);
                // r0.xyz = r0.x*r0.yzw+half3(0.113,0.04,0.04);
                color.rgb = r1.xyz;
                // #ifdef UNITY_UI_CLIP_RECT
                //     color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                // #endif

                // #ifdef UNITY_UI_ALPHACLIP
                //     clip (color.a - 0.001);
                // #endif

                return color;
            }
            ENDCG
        }
    }
}
