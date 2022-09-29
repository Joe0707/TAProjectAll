/**
 * @file         ShaderReferenceMath.cs
 * @author       Hongwei Li(taecg@qq.com)
 * @created      2018-11-16
 * @updated      2019-11-20
 *
 * @brief        数学运算相关
 */

#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace taecg.tools.shaderReference
{
    public class ShaderReferenceMath : EditorWindow
    {
        #region [数据成员]
        private Vector2 scrollPos;
        #endregion

        #region [绘制界面]
        public void DrawMainGUI ()
        {
            scrollPos = EditorGUILayout.BeginScrollView (scrollPos);
            ShaderReferenceUtil.DrawTitle ("Math");
            ShaderReferenceUtil.DrawOneContent ("abs (x)", "取绝对值，即正值返回正值，负值返回的还是正值\nx值可以为向量");
            ShaderReferenceUtil.DrawOneContent ("acos (x)", "反余切函数,输入参数范围为[-1, 1],返回[0, π] 区间的角度值");
            ShaderReferenceUtil.DrawOneContent ("any (x)", "如果x=0，或者x中的所有分量为0，则返回0;否则返回1.");
            ShaderReferenceUtil.DrawOneContent ("ceil (x)", "对x进行向上取整，即x=0.1返回1，x=1.5返回2，x=-0.3返回0");
            ShaderReferenceUtil.DrawOneContent ("clamp(x,a,b)", "如果 x 值小于 a，则返回 a;如果 x 值大于 b,返回 ;否则，返回 x.");
            ShaderReferenceUtil.DrawOneContent ("clip (x)", "如果x<0则裁剪掉此片断");
            ShaderReferenceUtil.DrawOneContent ("cross (a,b)", "返回两个三维向量a与b的叉积,结果相当于a.yzx * b.zxy - a.zxy * b.yzx;");

            ShaderReferenceUtil.DrawOneContent ("dot (a,b)", "点乘，a和b可以为标量也可以为向量,其计算结果是两个向量夹角的余弦值，相当于|a|*|b|*cos(θ)或者a.x*b.x+a.y*b.y+a.z*b.z\na和b的位置无所谓前后，结果都是一样的");
            ShaderReferenceUtil.DrawOneContent ("distance (a,b)", "返回a,b间的距离.");
            ShaderReferenceUtil.DrawOneContent ("exp(x)", "计算e的x次方，e = 2.71828182845904523536");
            ShaderReferenceUtil.DrawOneContent ("exp2 (x)", "计算2的x次方");

            ShaderReferenceUtil.DrawOneContent ("floor (x)", "对x值进行向下取整(去尾求整)\n比如:floor (0.6) = 0.0,floor (-0.6) = -1.0");
            ShaderReferenceUtil.DrawOneContent ("fmod (x,y)", "返回x/y的余数。如果y为0，结果不可预料,注意！如果x为负值，返回的结果也是负值！");
            ShaderReferenceUtil.DrawOneContent ("frac (x)", "返回x的小数部分");

            ShaderReferenceUtil.DrawOneContent ("length (v)", "返回一个向量的模，即 sqrt(dot(v,v))");
            ShaderReferenceUtil.DrawOneContent ("lerp (A,B,alpha)", "线性插值.\n如果alpha=0，则返回A;\n如果alpha=1，则返回B;\n否则返回A与B的混合值;内部执行:A + alpha*(B-A)");
            ShaderReferenceUtil.DrawOneContent ("max (a,b)", "比较两个标量或等长向量元素，返回最大值");
            ShaderReferenceUtil.DrawOneContent ("min (a,b)", "比较两个标量或等长向量元素，返回最小值");
            ShaderReferenceUtil.DrawOneContent ("mul (M,V)", "表示矩阵M与向量V进行点乘，结果就是对向量V进行M矩阵变换后的值");

            ShaderReferenceUtil.DrawOneContent ("normalize (v)", "返回一个向量的归一化版本(方向一样，但是模为1)" +
                "\nnormalize(v) = rsqrt(dot(v,v))*v; rsqrt返回的是平方根的倒数");
            ShaderReferenceUtil.DrawOneContent ("pow (x,y)", "返回x的y次方");
            ShaderReferenceUtil.DrawOneContent ("reflect(I, N)", "根据入射光方向向量 I ，和顶点法向量 N ，计算反射光方向向量。其中 I 和 N 必须被归一化，需要非常注意的是，这个 I 是指向顶点的；函数只对三元向量有效。");
            ShaderReferenceUtil.DrawOneContent ("refract(I,N,eta)", "计算折射向量， I 为入射光线， N 为法向量， eta 为折射系数；其中 I 和 N 必须被归一化，如果 I 和 N 之间的夹角太大，则返回（ 0 ， 0 ， 0 ），也就是没有折射光线； I 是指向顶点的；函数只对三元向量有效。");
            ShaderReferenceUtil.DrawOneContent ("rsqrt (x)", "返回x的平方根倒数,注意x不能为0.相当于 pow(x, -0.5)");
            ShaderReferenceUtil.DrawOneContent ("saturate (x)", "如果x<0返回0,如果x>1返回1,否则返回x.");
            ShaderReferenceUtil.DrawOneContent ("sqrt (x)", "返回x的平方根.");
            ShaderReferenceUtil.DrawOneContent ("step (a,b)", "如果a<b返回1,否则返回0.");
            ShaderReferenceUtil.DrawOneContent ("sign (x)", "如果x=0返回0,如果x>0返回1,如果x<0返回-1.");
            ShaderReferenceUtil.DrawOneContent ("smoothstep (min,max,x)", "如果 x 比min 小，返回 0\n如果 x 比max 大，返回 1\n如果 x 处于范围 [min，max]中，则返回 0 和 1 之间的值(按值在min和max间的比例).\n如果只想要线性过渡，并不需要平滑的话，可以采用saturate((x - min)/(max - min))");

            switch (ShaderReferenceEditorWindow.mPipline)
            {
                case ShaderReferenceEditorWindow.Pipline.BuildIn:
                    ShaderReferenceUtil.DrawTitle ("纹理采样");
                    ShaderReferenceUtil.DrawOneContent ("tex1D(samper1D tex,float s)", "一维纹理采样");
                    ShaderReferenceUtil.DrawOneContent ("tex2D(samper2D tex,float2 s)", "二维纹理采样");
                    ShaderReferenceUtil.DrawOneContent ("tex2Dlod(samper2D tex,float4 s)", "二维纹理采样,s.w表示采样的是mipmap的几级,仅在ES3.0以上支持.");
                    ShaderReferenceUtil.DrawOneContent ("tex2DProj(samper2D tex,float2 s)", "二维投影纹理采样");
                    ShaderReferenceUtil.DrawOneContent ("texCUBE(samperCUBE tex,float3 s)", "立方体纹理采样");
                    break;
                case ShaderReferenceEditorWindow.Pipline.URP:
                    ShaderReferenceUtil.DrawOneContent ("SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);", "二维纹理采样" +
                        "\n_BaseMap:Properties中字义的纹理名称" +
                        "\nsampler_BaseMap:不再需要在HLSL中声明sampler2D XXX,而是直接放在这里声明" +
                        "\ni.uv:采样用的UV");
                    break;
            }

            ShaderReferenceUtil.DrawTitle ("常用指令");
            ShaderReferenceUtil.DrawOneContent ("mov dest, src1", "dest = src1");
            ShaderReferenceUtil.DrawOneContent ("add dest, src1, src2", "dest = src1 + src2 (可通过在src2前加-,实现减功能)");
            ShaderReferenceUtil.DrawOneContent ("mul dest, src1, src2", "dest = src1 * src2");
            ShaderReferenceUtil.DrawOneContent ("div dest, src1, src2", "dest = src1 / src2");
            ShaderReferenceUtil.DrawOneContent ("mad dest, src1, src2 , src3", "dest = src1 * src2 + src3");
            ShaderReferenceUtil.DrawOneContent ("dp2 dest, src1, src2", "(src1.x * src2.x) + (src1.y * src2.y)");
            ShaderReferenceUtil.DrawOneContent ("dp3 dest, src1, src2", "(src1.x * src2.x) + (src1.y * src2.y) + (src1.z * src2.z)");
            ShaderReferenceUtil.DrawOneContent ("dp4 dest, src1, src2", "(src1.x * src2.x) + (src1.y * src2.y) + (src1.z * src2.z) + (src1.w * src2.w)");
            ShaderReferenceUtil.DrawOneContent ("rsq dest, src1", "rsqrt(src1) 对src1进行平方根的倒数，然后将值存入dest中");
            EditorGUILayout.EndScrollView ();
        }
        #endregion
    }
}
#endif