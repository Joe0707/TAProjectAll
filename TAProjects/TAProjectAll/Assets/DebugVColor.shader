Shader "jcy/DebugVColor"
{  
    Properties
    {
        _MainTex ("MainTex", 2D) = "" {}
        [Toggle]_ShowAlpha("Show Alpha",int) = 0 
    }
    SubShader
    {
        Tags { "Queue"="Geometry"
        }
        LOD 200
        Pass{
            Name "Unlit"
            Tags{
                "LightMode" = "ForwardBase"
            }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#include "UnityCG.cginc"


            struct appdata
            {
                float4 vertex:POSITION;
                float2 uv:TEXCOORD0;
                float4 color:COLOR;
            };

            struct v2f
            {
                float2 uv:TEXCOORD0;
                float4 pos:SV_POSITION;
                float4 color:TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            int _ShowAlpha;
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                o.color = v.color;
                return o;
            }
            
            half4 frag(v2f i):SV_Target
            {
                half4 color = _ShowAlpha==1?i.color.aaaa:i.color;
                return color;
            }
            
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}