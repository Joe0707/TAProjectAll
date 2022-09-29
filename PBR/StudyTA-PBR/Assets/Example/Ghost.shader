Shader "jcy/Examples/Ghost"
{
    Properties
    {
        _FresnelColor("Fresnel Color",Color) = (1,1,1,1)
        _Fresnel("Fade(X) Intensity(Y) Top(Z) Offset(W)",vector) = (4,1,1,0)
        _Offset("Offset",Range(-1,1)) = 0
        _Animation("Repeat(XZ) Intensity(YW)",vector) = (3,0.05,5,0.05)
    }
    SubShader
    {
        Tags { 
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "Queue" = "Transparent"
        }
        Blend One One
        ZWrite Off
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //Include
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"

            struct Attributes
            {
                float4 vertexOS : POSITION;
                half3 normalOS:NORMAL;//OS = Object Space
            };

            struct Varyings
            {
                float4 vertexCS : SV_POSITION;
                half3 normalWS:TEXCOORD; //WS = World Space
                float3 vertexWS : TEXCOORD1;
                float4 vertexOS:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            CBUFFER_START(UnityPerMaterial)
                half4 _Fresnel;
                half4 _FresnelColor;
                half4 _Animation;
            CBUFFER_END

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.vertexOS = v.vertexOS;
                v.vertexOS.x+=sin((_Time.y+v.vertexOS.y)*_Animation.x)*_Animation.y;
                v.vertexOS.z+=sin((_Time.y+v.vertexOS.y)*_Animation.z)*_Animation.w;
                o.vertexCS = TransformObjectToHClip(v.vertexOS);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                o.vertexWS = TransformObjectToWorld(v.vertexOS);
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                //max(0,dot(N,V))
                half3 N = normalize(i.normalWS);
                half3 V = normalize(_WorldSpaceCameraPos - i.vertexWS);
                half dotNV = 1-saturate(dot(N,V));
                half4 fresnel = pow(dotNV,_Fresnel.x)*_Fresnel.y*_FresnelColor;
                //创建从上到下的遮罩
                half mask =saturate(i.vertexOS.y + _Fresnel.w+i.vertexOS.z);
                fresnel = lerp(fresnel,mask*_FresnelColor,mask*_Fresnel.z);
                half4 c = fresnel*mask;
                return c ;
            }
            ENDHLSL
        }
    }
}
