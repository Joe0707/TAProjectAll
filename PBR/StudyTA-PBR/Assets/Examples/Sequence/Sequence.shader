Shader "taecg/Examples/Sequence"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcFactor("SrcFactor",int) = 0
        [Enum(UnityEngine.Rendering.BlendMode)]_DstFactor("DstFactor",int) = 0
        _BaseColor("Base Color",color) = (1,1,1,1)
        [NoScaleOffset]_BaseMap("BaseMap", 2D) = "white" {}
        _Sequence("Row(X) Cloum(Y) Speed(Z)",vector) = (3,3,3,0)
        [Enum(Billboard,1,VerticalBillboard,0)]_BillboardType("BillboardType",int) = 1
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" "RenderPipeline" = "UniversalPipeline" }
        LOD 100
        Blend [_SrcFactor] [_DstFactor]

        Pass
        {
            Name "Unlit"
            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            struct Attributes
            {
                float4 positionOS       : POSITION;
                float2 uv               : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS       : SV_POSITION;
                float2 uv           : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half4 _Sequence;
                half _BillboardType;
            CBUFFER_END
            TEXTURE2D (_BaseMap);SAMPLER(sampler_BaseMap);float4 _BaseMap_ST;
            // #define smp _linear_clampU_mirrorV
            // SAMPLER(smp);

            Varyings vert(Attributes v)
            {
                Varyings o = (Varyings)0;

                //目的是为了构建旋转后的基向量在模型本地空间下的坐标
                //viewDir相当于是我们自己定义的Z基向量，把相机从世界空间转换到本地空间，而本地空间就是以我们模型的原点为中心点的坐标，此时相机转换后的位置就是我们要的向量了
                float3 viewDir=mul(GetWorldToObjectMatrix(),float4(_WorldSpaceCameraPos,1));
                //对向量归一化，求出基
                viewDir = normalize(viewDir);
                viewDir.y *= _BillboardType;
                //假设向上的向量为世界坐标系下的上向量
                float3 upDir = float3(0,1,0);
                //利用叉积（左手法则）计算出向右的向量(比面向相机还需要转180才能看到显示面)
                float3 rightDir = -normalize(cross(upDir,viewDir));
                //再利用叉积计算出精确的向上的向量
                upDir = cross(rightDir,viewDir);

                //矩阵的写法
                // float4x4 M = float4x4(
                // rightDir.x,upDir.x,viewDir.x,0,
                // rightDir.y,upDir.y,viewDir.y,0,
                // rightDir.z,upDir.z,viewDir.z,0,
                // 0,0,0,1
                // );
                // float3 newVertex = mul(M,v.positionOS);
                //矩阵乘法的写法
                // float3 newVertex = half3(dot(half3(rightDir.x,upDir.x,viewDir.x), v.positionOS), dot(half3(rightDir.y,upDir.y,viewDir.y), v.positionOS), dot(half3(rightDir.z,upDir.z,viewDir.z), v.positionOS));
                //向量乘法的写法
                float3 newVertex = rightDir * v.positionOS.x + upDir * v.positionOS.y + viewDir * v.positionOS.z;

                o.positionCS = TransformObjectToHClip(newVertex);

                //UV的起始位置（左上角的格子）
                o.uv = float2(v.uv.x/_Sequence.y,v.uv.y/_Sequence.x+1/_Sequence.x*(_Sequence.x-1));
                //对U方向进行走格偏移
                o.uv.x += frac(floor(_Time.y * _Sequence.z)/_Sequence.y);
                //对V方向进行走格偏移
                o.uv.y -= frac(floor(_Time.y * _Sequence.z/_Sequence.y)/_Sequence.x);
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                half4 c;
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                c = baseMap * _BaseColor;
                c.rgb *= c.a;
                return c;
            }
            ENDHLSL
        }
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
        LOD 100
        Blend [_SrcFactor] [_DstFactor]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 position : SV_POSITION;
            };

            sampler2D _BaseMap;
            half4 _BaseColor;
            half4 _Sequence;
            fixed _BillboardType;

            v2f vert (appdata v)
            {
                v2f o;

                float3 viewDir=mul(unity_WorldToObject,float4(_WorldSpaceCameraPos,1));
                viewDir = normalize(viewDir);
                viewDir.y *= _BillboardType;
                float3 upDir = float3(0,1,0);
                float3 rightDir = normalize(cross(upDir,viewDir));
                // upDir = cross(rightDir,viewDir);
                float3 newVertex = rightDir * v.positionOS.x + upDir * v.positionOS.y + viewDir * v.positionOS.z;
                o.position = UnityObjectToClipPos(newVertex);
                //UV的起始位置（左上角的格子）
                o.uv = float2(v.uv.x/_Sequence.y,v.uv.y/_Sequence.x+1/_Sequence.x*(_Sequence.x-1));
                //对U方向进行走格偏移
                o.uv.x += frac(floor(_Time.y * _Sequence.z)/_Sequence.y);
                //对V方向进行走格偏移
                o.uv.y -= frac(floor(_Time.y * _Sequence.z/_Sequence.y)/_Sequence.x);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half4 c;
                half4 baseMap = tex2D(_BaseMap, i.uv);
                c = baseMap * _BaseColor;
                c.rgb *= c.a;
                return c;
            }
            ENDCG
        }
    }
}
