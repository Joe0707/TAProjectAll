Shader "taecg/LightModel"
{
    Properties
    {
        _DiffuseIntensity("Diffuse Intensity",float) = 1
        _SpecularColor("Specular Color",Color) = (1,1,1,1)
        _SpecularIntensity("Specular Intensity",float) = 1
        _Shininess("Shininess",float) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                half3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half3 worldNormal:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
            };

            half _DiffuseIntensity;
            fixed4 _SpecularColor;
            half _SpecularIntensity,_Shininess;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c=0;
                //Diffuse = Ambient + Kd * LightColor * max(0,dot(N,L))
                fixed4 Ambient = unity_AmbientSky;
                half Kd = _DiffuseIntensity;
                fixed4 LightColor = _LightColor0;
                fixed3 N = normalize(i.worldNormal);
                fixed3 L = _WorldSpaceLightPos0;
                fixed NdotL = dot(N,L);
                fixed4 Diffuse = Ambient + Kd * LightColor * NdotL;
                c += Diffuse;

                // Spcular = SpecularColor * Ks * pow(max(0,dot(R,V)), Shininess)
                fixed3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                // fixed3 R = 2 * NdotL * N - L;
                // fixed3 R = reflect(-L,N);
                // fixed4 Specular = _SpecularColor * _SpecularIntensity * pow(max(0,dot(R,V)),_Shininess);
                // c += Specular;

                // Specular = SpecularColor * Ks * pow(max(0,dot(N,H)), Shininess)
                fixed3 H = normalize(L + V);
                fixed4 BlinnSpecular = _SpecularColor * _SpecularIntensity * pow(max(0,dot(N,H)),_Shininess);
                c +=BlinnSpecular;

                return c;
            }
            ENDCG
        }

        Pass
        {
            Tags {"LightMode" = "ForwardAdd"}
            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            #pragma skip_variants DIRECTIONAL DIRECTIONAL_COOKIE POINT_COOKIE
            // #pragma multi_compile POINT SPOT
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                half3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half3 worldNormal:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
            };

            half _DiffuseIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // #if DIRECTIONAL
                // return 1;
                // #elif POINT
                // return fixed4(0,1,0,1);
                // #elif SPOT
                // return fixed4(0,0,1,1);
                // #endif

                // float3 lightCoord = mul(unity_WorldToLight,float4(i.worldPos,1)).xyz;
                // fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord));
                UNITY_LIGHT_ATTENUATION(atten,0,i.worldPos)
                
                //Diffuse = Ambient + Kd * LightColor * max(0,dot(N,L))
                fixed4 LightColor = _LightColor0 * atten;
                fixed3 N = normalize(i.worldNormal);
                fixed3 L = _WorldSpaceLightPos0;
                fixed4 Diffuse = LightColor * max(0,dot(N,L));
                return Diffuse;
            }
            ENDCG
        }
    }
}
