Shader "taecg/HeatDistort03"
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
            };

            sampler2D _GrabTex;
            sampler2D _DistortTex;float4 _DistortTex_ST;
            float4 _Distort;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_DistortTex) + _Distort.xy * _Time.y;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 screenUV = i.pos.xy/_ScreenParams.xy;
                fixed4 distortTex = tex2D(_DistortTex,i.uv);
                float2 uv = lerp(screenUV,distortTex,_Distort.z);
                fixed4 grabTex = tex2D(_GrabTex,uv);
                return grabTex;
            }
            ENDCG
        }
    }
}
