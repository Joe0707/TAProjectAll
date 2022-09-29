Shader "taecg/HeatDistort"
{
    Properties
    {
        _DistortTex("DistortTex",2D) = "white"{}
        // _Distort("Distort",Range(0,1)) = 0
        // _SpeedX("SpeedX",float) = 0
        // _SpeedY("SpeedY",float) = 0
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

            struct v2f
            {
                float2 uv : TEXCOORD0;
            };

            sampler2D _GrabTex;
            sampler2D _DistortTex;float4 _DistortTex_ST;
            // fixed _Distort;
            // float _SpeedX,_SpeedY;
            float4 _Distort;

            v2f vert (
            float4 vertex : POSITION,
            float2 uv:TEXCOORD,
            out float4 pos:SV_POSITION
            )
            {
                v2f o;
                pos = UnityObjectToClipPos(vertex);
                o.uv = TRANSFORM_TEX(uv,_DistortTex) + _Distort.xy * _Time.y;
                return o;
            }

            fixed4 frag (v2f i,UNITY_VPOS_TYPE screenPos : VPOS) : SV_Target
            {
                fixed2 screenUV = screenPos.xy/_ScreenParams.xy;

                fixed4 distortTex = tex2D(_DistortTex,i.uv);
                float2 uv = lerp(screenUV,distortTex,_Distort.z);
                fixed4 grabTex = tex2D(_GrabTex,uv);

                return grabTex;
            }
            ENDCG
        }
    }
}
