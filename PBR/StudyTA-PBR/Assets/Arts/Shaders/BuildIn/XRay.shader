Shader "taecg/XRay"
{
    SubShader
    {
        Pass
        {
            Name "XRAY"

            Tags {"Queue" = "Transparent"}
            Blend One One
            ZTest Greater
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                half3 normal :NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos:TEXCOORD1;
                half3 worldNormal:TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c = 1;
                fixed3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                fixed3 N = normalize(i.worldNormal);
                fixed VdotN = dot(V,N);
                fixed fresnel = 2 * pow(1-VdotN,2);
                c.rgb = fresnel * fixed3(1,0.5,0);
                
                fixed v = frac(i.worldPos.y*20 - _Time.y);
                c.rgb *= v;
                return c;
            }
            ENDCG
        }
    }
}
