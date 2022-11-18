Shader "jcy/ToonShading"
{  
    Properties
    {
        _MainTex ("主纹理", 2D) = "" {}
        _OutlineWidth("轮廓宽度",float) = 1
        _OutlineColor("轮廓颜色",color) = (0,0,0,1)
        _PixelWidth("轮廓使用固定宽度",Range(0,1)) = 1
        [Toggle]_UseAvgNormal("处理断边",int) = 1
        [Toggle]_UseVertexColor("使用顶点色",int) = 1

        [IntRange]_StepMode("分色模式(1 二阶 2 多阶 3 GradientTex 4 RampStepMap)",range(1,4)) = 1 
        _Step("色阶数",range(0,1)) = 0.5
        [IntRange]_StepCount("色阶数(多阶模式可用)",range(1,4)) = 2
        _RampStepMap("色阶贴图(RampStepMap模式可用)",2D) = ""{}
        _RampColorMap("区块色贴图",2D) = ""{}
        [Toggle]_UseRampColorMap("是否使用区块色贴图",int) = 0
        [Toggle]_UseAOMap("是否使用AO贴图",int) = 0
        _AOMap("AO贴图",2d) = ""{}
        [Toggle]_UseFaceInfo("使用面部信息",int) = 0
        _FaceInfo("面部中心点坐标(XYZ 模型空间) 面部平滑度系数(W)",vector) = (0,0,0,0)
        [Toggle]_UseSpecular("是否开启高光",int) = 0
        _SpecColor("高光颜色",color) = (0,0,0,0)
        _SpecPower("高光集中度",range(1,256)) = 1
        _SpecSmoothness("高光柔和度",range(0,1)) = 1
        _SpecOpacity("高光不透明度",range(0,1)) = 1
        _SpecIntensity("高光强度",range(1,10)) = 1
        [Toggle]_UseRimLight("是否开启外发光",int)=0
        _RimColor("外发光颜色",color) = (0,0,0,1)
        _RimPower("外发光集中度",range(1,8)) = 1
        _RimSmoothness("外发光柔和度",range(0,1)) = 1
        _RimIntensity("外发光强度",range(1,10)) = 1
        [Toggle]_UseShadow("是否开启阴影",int) = 0
        // _StencilRef("Stencil Ref",int) = 1
    }
    SubShader
    {
        Tags { "Queue"="Geometry"
            "RenderPipeline" = "UniversalPipeline"
        }
        LOD 200
        Pass{
            Name "Unlit"
            Tags{
                "LightMode" = "UniversalForward"
            }
            // Stencil
            // {
                //     Ref [_StencilRef]
                //     Comp Always
                //     Pass Replace
            // }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex:POSITION;
                float2 uv:TEXCOORD0;
                float3 normalOS:NORMAL;//normal in object space
            };

            struct v2f
            {
                float2 uv:TEXCOORD0;
                float4 pos:SV_POSITION;
                half3 normalWS:TEXCOORD1;    //normal in world space
                half3 viewWS:TEXCOORD2;
                float4 shadowCoord:TEXCOORD3;
            };
            CBUFFER_START(UnityPerMaterial)
                sampler2D _MainTex;     //固有色
                sampler2D _GradientTex;     //色条贴图
                sampler2D _RampColorMap;   //色条贴图
                sampler2D _RampStepMap;//区块
                sampler2D _AOMap;
                float4 _MainTex_ST;
                float4 _OutlineColor;
                float _OutlineWidth;
                float _PixelWidth;
                int _UseAvgNormal;
                float _Step;
                float _StepCount;
                int _StepMode;
                int _UseRampColorMap;
                int _UseAOMap;
                int _UseFaceInfo;
                float4 _FaceInfo;
                float4 _SpecColor;
                float _SpecPower;
                float _SpecIntensity;
                float _UseSpecular;
                float _SpecSmoothness;
                float _SpecOpacity;
                float4 _RimColor;
                float _RimPower;
                float _RimSmoothness;
                int _UseRimLight;
                float _RimIntensity;
                int _UseShadow;
            CBUFFER_END
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                if(_UseFaceInfo){
                    half3 sphNormal = normalize(v.vertex - _FaceInfo.xyz);//球面化面部法线方向向量
                    v.normalOS = lerp(v.normalOS,sphNormal,_FaceInfo.w);
                }
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                half3 posWS = TransformObjectToWorld(v.vertex);
                o.viewWS = normalize(_WorldSpaceCameraPos - posWS);
                o.shadowCoord = TransformWorldToShadowCoord(posWS);
                return o;
            }
            
            half4 frag(v2f i):SV_Target
            {
                half3 n = normalize(i.normalWS);
                half3 v = normalize(i.viewWS);
                half nl = dot(_MainLightPosition,n);
                nl = nl*0.5+0.5;//[0,1]
                // return nl;
                half lvl;   //色阶
                if(_StepMode==1){
                    lvl = step(_Step,nl);
                }
                else if(_StepMode == 2)
                {
                    lvl = ceil(nl*_StepCount)/_StepCount;
                }
                else if(_StepMode == 3){
                    lvl = tex2D(_GradientTex,nl).r;
                }
                else
                {
                    lvl = tex2D(_RampStepMap,nl).r;
                }

                if(_UseAOMap){
                    lvl *= tex2D(_AOMap,i.uv);
                }
                if(_UseShadow){
                    Light mainLight = GetMainLight(i.shadowCoord);
                    lvl*= mainLight.shadowAttenuation;
                }
                half4 baseColor = tex2D(_MainTex,i.uv);
                half4 col;
                if(_UseRampColorMap){
                    half4 rampColor = tex2D(_RampColorMap,i.uv);
                    col = lerp(rampColor*baseColor,baseColor,lvl);
                }
                else
                {
                    col = baseColor*lvl;
                }
                if(_UseSpecular){
                    half h = normalize(normalize(v)+_MainLightPosition);//半程向量
                    half specFinal = _SpecIntensity*pow(max(dot(n,h),0),_SpecPower);//光照强度系数
                    specFinal = smoothstep(0.3,0.3+_SpecSmoothness,specFinal);
                    col+=_SpecColor*specFinal*_SpecOpacity;
                }   
                if(_UseRimLight)
                {
                    half rimFinal = 1-max(dot(n,v),0);
                    rimFinal = _RimIntensity*pow(rimFinal,_RimPower);
                    rimFinal = smoothstep(0.3,0.3+_RimSmoothness,rimFinal);
                    col+= rimFinal*_RimColor;
                }

                return  col;
            }
            
            ENDHLSL
        }
        Pass{
            Name "Outline"
            Tags{
                "LightMode" = "Outline"
            }
            // Stencil
            // {
                //     Ref [_StencilRef]
                //     Comp NotEqual
            // }
            Cull Front
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 tangent : TANGENT;
                float2 uv:TEXCOORD0;
                float4 vertexColor : COLOR;
            };

            struct v2f
            {
                float2 uv:TEXCOORD0;
                float4 pos:SV_POSITION;
                float4 color : COLOR;
            };
            CBUFFER_START(UnityPerMaterial)
                sampler2D _MainTex;
                float4 _MainTex_ST;
                float _OutlineWidth;
                float4 _OutlineColor;
                float _PixelWidth;
                int _UseAvgNormal;
                sampler2D _RampColorMap;
                float _UseVertexColor;
            CBUFFER_END
            v2f vert(appdata v)
            {
                v2f o;
                //从顶点颜色中读取法线信息，并将其值范围从0~1还原为-1~1
                float3 vertNormal = v.vertexColor.rgb * 2 - 1;
                //使用法线与切线叉乘计算副切线用于构建切线→模型空间转换矩阵
                float3 bitangent = cross(v.normal,v.tangent.xyz) * v.tangent.w * unity_WorldTransformParams.w;
                //构建切线→模型空间转换矩阵
                float3x3 TtoO = float3x3(v.tangent.x, bitangent.x, v.normal.x,
                v.tangent.y, bitangent.y, v.normal.y,
                v.tangent.z, bitangent.z, v.normal.z);
                //将法线转换到模型空间下
                vertNormal = mul(TtoO, vertNormal);
                float3 normal = _UseAvgNormal==1?vertNormal:v.normal;
                float3 p1 = mul(unity_ObjectToWorld,v.vertex).xyz;
                float camDistance = length(_WorldSpaceCameraPos-p1);
                float camFactor = camDistance*_ProjectionParams.w;
                float3 width = vertNormal* _OutlineWidth*camFactor*v.vertexColor.a;

                float3 pos = v.vertex+width;
                o.pos = TransformObjectToHClip(pos); //clip space
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                o.color = v.vertexColor;
                return o;
            }
            
            half4 frag(v2f i):SV_Target
            {
                half4 rampColor = tex2D(_RampColorMap,i.uv);
                return _UseVertexColor?i.color:_OutlineColor*rampColor;
            }
            
            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _GLOSSINESS_FROM_BASE_ALPHA

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}