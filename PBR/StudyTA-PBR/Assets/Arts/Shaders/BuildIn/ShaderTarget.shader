Shader "taecg/ShaderTarget"
{
    CGINCLUDE

    #include "UnityCG.cginc"
    struct appdata
    {
        float4 vertex : POSITION;
    };

    struct v2f
    {
        float2 uv : TEXCOORD0;
        float4 vertex : SV_POSITION;
    };

    v2f vert (appdata v)
    {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        return o;
    }

    fixed4 frag (v2f i) : SV_Target
    {
        #if (SHADER_TARGET >= 30)
        return fixed4(1,1,0,1);
        #else
        return fixed4(0,1,0,1);
        #endif
    }

    ENDCG

    //高配
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 400
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            ENDCG
        }
    }

    //低配
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            ENDCG
        }
    }
}
