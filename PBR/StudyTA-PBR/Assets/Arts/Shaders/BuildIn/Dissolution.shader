Shader "jcy/Dissolution"
{
    Properties
    {
        [Header(Base)]
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        [Space(10)]
        [Header(Dissolve)]
        _Clip("Clip",Range(0,1)) = 0
        _DissolveTex("Dissolve Tex (R)",2D) = "white" {}
        [NoScaleOffset]_RampTex("Ramp Tex(RGB)",2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _DissolveTex;
            float4 _DissolveTex_ST;
            sampler2D _RampTex;
            float _Clip;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 dissolveTex = tex2D(_DissolveTex, i.uv);
                clip(dissolveTex.r-_Clip);
                fixed4 rampTex = tex2D(_RampTex,smoothstep(_Clip,1,dissolveTex.r));
                col +=rampTex;
                return col;
            }
            ENDCG
        }
    }
}
