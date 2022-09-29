Shader "taecg/DynamicBatching"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

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
                float3 normal:NORMAL;
                float3 tangent:TANGENT;
                float2 uv1:TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float2 uv1:TEXCOORD1;
                float3 normal:TEXCOORD2;
                float3 tangent:TEXCOORD3;
                float3 wPos:TEXCOORD4;
            };

            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.wPos = mul(unity_ObjectToWorld,v.vertex);
                o.uv = v.uv;
                // o.uv1 = v.uv1;
                // o.normal = v.normal;
                // o.tangent = v.tangent;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return i.wPos.y*0.15+_Color;
            }
            ENDCG
        }
    }
}
