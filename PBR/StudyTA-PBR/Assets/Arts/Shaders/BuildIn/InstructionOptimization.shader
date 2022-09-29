Shader "taecg/InstructionOptimization"
{
    Properties
    {
        _Value("Value",vector) = (0,0,0,0)
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
                float2 uv:TEXCOORD;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv:TEXCOORD;
            };

            float4 _Value;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //数据的准备
                float a = _Value.x;
                float b = _Value.y;
                float c = _Value.z;
                float d = _Value.w;

                //常量运算
                // return 5*4;

                //可以正常申请临时用的变量，对性能没有影响
                // float e0 = 5*4/0.3+sin(1/5)/3.2;
                // float e1 = e0;
                // return e1;

                //基本运算
                // float e2 = 5 + a;
                // e2 = 5 - a;
                // e2 = 5 * a;
                // e2 = 5 / a;
                // e2 = 5 * a * b;
                // //乘加运算指令，对优化特别重要
                // e2 = 5 * a + b;
                // return e2;

                //if
                // if(i.uv.x>0.5)
                //     i.uv.x = 1;
                // else
                //     i.uv.x = 0;         
                // return i.uv.x;
                // return step(0.5,i.uv.x);

                //for循环
                // float e3 = 0;
                // for(int i=0;i<5;i++)
                // {
                    //     e3 += 0.1;
                // }
                // return e3;

                //mad指令优化
                //aa-bb
                //aa+(-bb)
                // float e4 = (a+b)*(a-b); 
                // e4 = a*a+(-b*b);
                // return e4;

                //透过编绎后的代码来直观的看出函数的内部执行
                //rsqrt(dot(a,a))*a
                // float e5 = normalize(a);
                // float4 e6 = normalize(_Value);
                // return e6;

                //如果abs是作为输入修饰符的话，那么它就是免费的，如果是作为输出修饰符的话就是收费的
                // float e7 = abs(a*b);
                // e7 = abs(a) * abs(b);
                // return e7;

                //负号可以适当的移到变量中
                // float e8 = -dot(a,a);
                // e8 = dot(-a,a);
                // return e8;

                //尽量把同一维度的向量进行结合运算
                // float3 e9 = _Value.xyz * a * b * _Value.yzw * c * d;
                // e9 = (_Value.xyz * _Value.yzw) * (a*b*c*d);
                // return float4(e9,1);

                //asin/atan/acos开销很大，尽量不要使用
                // float e10 = acos(a);
                // return e10;

                return 1;
            }
            ENDCG
        }
    }
}
