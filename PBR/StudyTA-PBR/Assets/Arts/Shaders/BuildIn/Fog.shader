Shader "taecg/Fog"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;

                //自定义雾效插值器
                // float fogFactor:TEXCOORD;

                // 内置方法一
                //相当于是在雾效开启时定义一个float类型的变量fogCoord
                // UNITY_FOG_COORDS(1)

                //内置方法二
                //无需额外定义雾效插值器，把worldPos.w利用起来
                float4 worldPos:TEXCOORD;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                //手动计算雾效插值器的值
                // float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
                // float z = length(_WorldSpaceCameraPos - worldPos);
                // #if defined(FOG_LINEAR)
                //     //(end-z)/(end-start) = z *(-1/(end-start)) +(end/(end-start))
                //     o.fogFactor = z * unity_FogParams.z + unity_FogParams.w;
                // #elif defined(FOG_EXP)
                //     //exp2(-density *z)
                //     o.fogFactor = exp2(-unity_FogParams.y * z);
                // #elif defined(FOG_EXP2)
                //     //exp2(-(density*z)^2)
                //     float density = unity_FogParams.x * z;
                //     o.fogFactor = exp2(-density * density);
                // #endif

                //内置方法一
                // UNITY_TRANSFER_FOG(o,o.pos);

                //内置方法二
                o.worldPos.xyz = mul(unity_ObjectToWorld,v.vertex).xyz;

                UNITY_TRANSFER_FOG_COMBINED_WITH_WORLD_POS(o,o.worldPos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c = 1;

                //自定义雾效插值
                // #if defined(FOG_LINEAR) || defined(FOG_EXP) ||defined(FOG_EXP2)
                //     c = lerp(unity_FogColor,c,i.fogFactor);
                // #endif

                // 内置方法一
                // UNITY_APPLY_FOG(i.fogCoord, c);

                //内置方法二
                // UNITY_EXTRACT_FOG_FROM_WORLD_POS(i);
                UNITY_APPLY_FOG(i.worldPos.w, c);
                return c;
            }
            ENDCG
        }
    }
}
