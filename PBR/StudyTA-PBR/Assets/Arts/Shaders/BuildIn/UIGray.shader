Shader "taecg/UIGray"
{
    Properties
    {
        [PerRendererData]_MainTex("MainTex",2D) = "white"{}
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle]_GrayEnabled("Gray Enabled",int) = 0
    }

    SubShader
    {
        Tags{"Queue" = "Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ UNITY_UI_CLIP_RECT
            #pragma multi_compile _ _GRAYENABLED_ON
            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            struct appdata
            {
                float4 vertex:POSITION;
                float2 uv:TEXCOORD;
                fixed4 color:COLOR;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD;
                fixed4 color:COLOR;
                float4 vertex:TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _ClipRect;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.color = v.color;
                o.vertex = v.vertex;
                return o;
            }

            fixed4 frag(v2f i) :SV_TARGET
            {
                fixed4 c;
                fixed4 mainTex = tex2D(_MainTex,i.uv);
                c = mainTex;
                c *= i.color;
                
                #if UNITY_UI_CLIP_RECT
                    //方法一,利用if来理解原理
                    // if(_ClipRect.x<i.vertex.x && i.vertex.x<_ClipRect.z && _ClipRect.y<i.vertex.y && i.vertex.y<_ClipRect.w) return 1;
                    // else return 0;

                    //方法二，利用step优化掉if指令
                    //return step(_ClipRect.x,i.vertex.x) * step(i.vertex.x,_ClipRect.z) * step(_ClipRect.y,i.vertex.y) * step(i.vertex.y,_ClipRect.w);

                    //方法三，优化step的数量
                    // fixed2 rect = step(_ClipRect.xy,i.vertex.xy) * step(i.vertex.xy,_ClipRect.zw);
                    // c.a *= rect.x * rect.y;

                    //利用unity自带函数实现
                    c.a *= UnityGet2DClipping(i.vertex,_ClipRect);
                #endif

                #if _GRAYENABLED_ON
                //不精确的单通道去色
                //c.rgb = c.rrr;
                //c.rgb = c.b;

                //方法二，去色公式dot(rgb,fixed3(0.22,0.707,0.071)).
                //c.rgb = c.r * 0.22 + c.g * 0.707 + c.b * 0.071;

                //方法三，利用内置方法实现
                c.rgb = Luminance(c.rgb);
                #endif

                return c;
            }
            ENDCG
        }
    }
}