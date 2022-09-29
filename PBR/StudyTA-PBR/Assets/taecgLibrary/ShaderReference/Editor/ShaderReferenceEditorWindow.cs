/**
 * @file         ShaderReferenceEditorWindow.cs
 * @author       Hongwei Li(taecg@qq.com)
 * @created      2018-11-10
 * @updated      2019-09-10
 *
 * @brief        着色器语法参考工具
 */

#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace taecg.tools.shaderReference
{
    public class ShaderReferenceEditorWindow : EditorWindow
    {
        public static int FONTSIZE;
        #region 数据成员
        public enum Pipline
        {
            BuildIn = 0,
            URP = 1,
        }
        public static Pipline mPipline = Pipline.BuildIn;
        private string[] tabNames = new string[] { "GPU", "Pipline", "Properties", "Semantics", "Tags", "Render State", "Compile Directives", "Other", "BuildIn Variables", "BuildIn Functions", "Predefined Macros", "Math", "Lighting", "Miscellaneous", "About" };
        private int selectedTabID;
        private ShaderReferenceGPU gpu;
        private ShaderReferencePipline pipline;
        private ShaderReferenceProperties properties;
        private ShaderReferenceSemantics semantics;
        private ShaderReferenceTags tags;
        private ShaderReferenceRenderState renderState;
        private ShaderReferencePragma pragma;
        private ShaderReferenceOther other;
        private ShaderReferenceBuildInVariables buildInVariables;
        private ShaderReferenceBuildInFunctions buildInFunctions;
        private ShaderReferencePredefinedMacros predefinedMacros;
        private ShaderReferenceLighting lighting;
        private ShaderReferenceMath math;
        private ShaderReferenceMiscellaneous miscellaneous;
        private ShaderReferenceAbout about;
        #endregion

        #region 编缉器入口
        [MenuItem("Window/Shader参考大全...", false, 0)]
        public static void Open()
        {
            ShaderReferenceEditorWindow window = EditorWindow.GetWindow<ShaderReferenceEditorWindow>();
            window.titleContent = new GUIContent("Shader Ref");
            window.Show();
        }
        #endregion

        #region OnEnable/OnDisable
        void OnEnable()
        {
            mPipline = (Pipline)(EditorPrefs.HasKey("taecg_ShaderReferencemPipline") ? EditorPrefs.GetInt("taecg_ShaderReferencemPipline") : 0);
            selectedTabID = EditorPrefs.HasKey("taecg_ShaderReferenceSelectedTabID") ? EditorPrefs.GetInt("taecg_ShaderReferenceSelectedTabID") : 0;
            // properties = ScriptableObject.CreateInstance<ShaderReferenceProperties>();
            gpu = ScriptableObject.CreateInstance<ShaderReferenceGPU>();
            pipline = ScriptableObject.CreateInstance<ShaderReferencePipline>();
            properties = ScriptableObject.CreateInstance<ShaderReferenceProperties>();
            semantics = ScriptableObject.CreateInstance<ShaderReferenceSemantics>();
            tags = ScriptableObject.CreateInstance<ShaderReferenceTags>();
            renderState = ScriptableObject.CreateInstance<ShaderReferenceRenderState>();
            pragma = ScriptableObject.CreateInstance<ShaderReferencePragma>();
            other = ScriptableObject.CreateInstance<ShaderReferenceOther>();
            buildInVariables = ScriptableObject.CreateInstance<ShaderReferenceBuildInVariables>();
            buildInFunctions = ScriptableObject.CreateInstance<ShaderReferenceBuildInFunctions>();
            predefinedMacros = ScriptableObject.CreateInstance<ShaderReferencePredefinedMacros>();
            lighting = ScriptableObject.CreateInstance<ShaderReferenceLighting>();
            math = ScriptableObject.CreateInstance<ShaderReferenceMath>();
            miscellaneous = ScriptableObject.CreateInstance<ShaderReferenceMiscellaneous>();
            about = ScriptableObject.CreateInstance<ShaderReferenceAbout>();
        }
        void OnDisable()
        {
            EditorPrefs.SetInt("taecg_ShaderReferencemPipline", (int)mPipline);
            EditorPrefs.SetInt("taecg_ShaderReferenceSelectedTabID", selectedTabID);
        }
        #endregion

        #region OnGUI
        void OnGUI()
        {
            EditorGUILayout.BeginHorizontal();

            //绘制左侧标签栏
            float _width = 150;
            float _heigth = position.height - 10;

            EditorGUILayout.BeginVertical(EditorStyles.helpBox, GUILayout.MaxWidth(_width), GUILayout.MinHeight(_heigth));
            mPipline = (Pipline)EditorGUILayout.EnumPopup(mPipline);

            selectedTabID = GUILayout.SelectionGrid(selectedTabID, tabNames, 1);
            EditorGUILayout.EndVertical();

            //绘制右侧内容区
            EditorGUILayout.BeginVertical(EditorStyles.helpBox, GUILayout.MinWidth(position.width - _width), GUILayout.MinHeight(_heigth));
            switch (selectedTabID)
            {
                case 0:
                    gpu.DrawMainGUI();
                    break;
                case 1:
                    pipline.DrawMainGUI();
                    break;
                case 2:
                    properties.DrawMainGUI();
                    break;
                case 3:
                    semantics.DrawMainGUI();
                    break;
                case 4:
                    tags.DrawMainGUI();
                    break;
                case 5:
                    renderState.DrawMainGUI();
                    break;
                case 6:
                    pragma.DrawMainGUI();
                    break;
                case 7:
                    other.DrawMainGUI();
                    break;
                case 8:
                    buildInVariables.DrawMainGUI();
                    break;
                case 9:
                    buildInFunctions.DrawMainGUI();
                    break;
                case 10:
                    predefinedMacros.DrawMainGUI();
                    break;
                case 11:
                    math.DrawMainGUI();
                    break;
                case 12:
                    lighting.DrawMainGUI();
                    break;
                case 13:
                    miscellaneous.DrawMainGUI();
                    break;
                case 14:
                    about.DrawMainGUI();
                    break;
            }
            EditorGUILayout.EndVertical();

            EditorGUILayout.EndVertical();
            Repaint();
        }
        #endregion
    }
}
#endif