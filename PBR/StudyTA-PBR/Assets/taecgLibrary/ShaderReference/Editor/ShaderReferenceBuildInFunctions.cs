/**
 * @file         ShaderReferenceBuildInFunctions.cs
 * @author       Hongwei Li(taecg@qq.com)
 * @created      2019-09-23
 * @updated      2019-09-30
 *
 * @brief        内置常用函数
 */

#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace taecg.tools.shaderReference
{
    public class ShaderReferenceBuildInFunctions : EditorWindow
    {
        #region 数据成员
        private Vector2 scrollPos;
        #endregion

        public void DrawMainGUI ()
        {
            scrollPos = EditorGUILayout.BeginScrollView (scrollPos);
            switch (ShaderReferenceEditorWindow.mPipline)
            {
                case ShaderReferenceEditorWindow.Pipline.BuildIn:
                    ShaderReferenceUtil.DrawTitle ("空间变换");
                    ShaderReferenceUtil.DrawOneContent ("UnityObjectToClipPos(v.vertex)", "将模型空间下的顶点转换到齐次裁剪空间");
                    ShaderReferenceUtil.DrawOneContent ("UnityObjectToWorldNormal(v.normal)", "将模型空间下的法线转换到世界空间(已归一化)");
                    ShaderReferenceUtil.DrawOneContent ("UnityObjectToWorldDir (v.tangent)", "将模型空间下的切线转换到世界空间(已归一化)");
                    ShaderReferenceUtil.DrawOneContent ("UnityWorldSpaceLightDir (i.worldPos)", "世界空间下顶点到灯光方向的向量(未归一化)");
                    ShaderReferenceUtil.DrawOneContent ("UnityWorldSpaceViewDir (i.worldPos)", "世界空间下顶点到视线方向的向量(未归一化)");
                    ShaderReferenceUtil.DrawTitle ("");
                    ShaderReferenceUtil.DrawOneContent ("UNITY_INITIALIZE_OUTPUT(type,name)", "用0初始化结构");
                    ShaderReferenceUtil.DrawOneContent ("TRANSFORM_TEX(i.uv,_MainTex)", "对UV进行Tiling与Offset变换");
                    ShaderReferenceUtil.DrawOneContent ("float3 UnityWorldSpaceLightDir( float3 worldPos )", "返回顶点到灯光的向量");
                    ShaderReferenceUtil.DrawOneContent ("ComputeScreenPos(float4 pos)", "pos为裁剪空间下的坐标位置，返回的是某个投影点下的屏幕坐标位置" +
                        "\n由于这个函数返回的坐标值并未除以齐次坐标，所以如果直接使用函数的返回值的话，需要使用：tex2Dproj(_ScreenTexture, uv.xyw);" +
                        "\n也可以自己处理其次坐标,使用：tex2D(_ScreenTexture, uv.xy / uv.w);");
                    ShaderReferenceUtil.DrawOneContent ("Luminance(float rgb)", "去色,内部公式为：dot(rgb,fixed3(0.22,0.707,0.071)).");
                    break;
                case ShaderReferenceEditorWindow.Pipline.URP:
                    ShaderReferenceUtil.DrawTitle ("空间变换");
                    ShaderReferenceUtil.DrawOneContent ("float3 TransformObjectToWorld (float3 positionOS)", "从本地空间变换到世界空间");
                    ShaderReferenceUtil.DrawOneContent ("float3 TransformWorldToObject (float3 positionWS)", "从世界空间变换到本地空间");
                    ShaderReferenceUtil.DrawOneContent ("float3 TransformWorldToView(float3 positionWS)", "从世界空间变换到视图空间");

                    ShaderReferenceUtil.DrawOneContent ("float4 TransformObjectToHClip(float3 positionOS)", "将模型空间下的顶点变换到齐次裁剪空间");
                    ShaderReferenceUtil.DrawOneContent ("float4 TransformWorldToHClip(float3 positionWS)", "将世界空间下的顶点变换到齐次裁剪空间");
                    ShaderReferenceUtil.DrawOneContent ("float4 TransformWViewToHClip (float3 positionVS)", "将视图空间下的顶点变换到齐次裁剪空间");
                    ShaderReferenceUtil.DrawOneContent ("float3 TransformObjectToWorldNormal (float3 normalOS)", "将法线从本地空间变换到世界空间(已归一化)");

                    break;
            }

            EditorGUILayout.EndScrollView ();
        }
    }
}
#endif