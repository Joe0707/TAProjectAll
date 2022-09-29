Shader "taecg/HeatDistort02"
{
    Properties
    {
        _DistortTex("DistortTex",2D) = "white"{}
        _Distort("SpeedX(X) SpeedY(Y) Distort(Z)",vector) = (0,0,0,0)
    }

    SubShader
    {
        Tags{"Queue" = "Transparent"}
        Cull Off

        GrabPass{"_GrabTex"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv:TEXCOORD;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos:SV_POSITION;
                float4 screenUV:TEXCOORD1;
            };

            sampler2D _GrabTex;
            sampler2D _DistortTex;float4 _DistortTex_ST;
            float4 _Distort;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_DistortTex) + _Distort.xy * _Time.y;
                o.screenUV = ComputeScreenPos(o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // float2 uv = i.screenUV.xy/i.screenUV.w * 0.5 + 0.5;
                // fixed2 screenUV = screenPos.xy/_ScreenParams.xy;

                fixed4 distortTex = tex2D(_DistortTex,i.uv);
                float2 uv = lerp(i.screenUV.xy/i.screenUV.w,distortTex,_Distort.z);
                // fixed4 grabTex = tex2Dproj(_GrabTex,i.screenUV);
                fixed4 grabTex = tex2D(_GrabTex,uv);
                return grabTex;
            }
            ENDCG
        }
    }
}
