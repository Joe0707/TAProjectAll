using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
[CustomEditor(typeof(GradientGenerator))]
public class GradientGeneratorEditor : Editor
{
    private GradientGenerator gradientGenerator;
    void OnEnable()
    {
        gradientGenerator = target as GradientGenerator;
    }

    public override void OnInspectorGUI()
    {
        base.DrawDefaultInspector();
        if (GUILayout.Button("生成纹理"))
        {
            string path = EditorUtility.SaveFilePanel("保持纹理", Application.dataPath, "GradientTexture", "png");
            File.WriteAllBytes(path, gradientGenerator.tex.EncodeToPNG());
            AssetDatabase.Refresh();
        }
    }

}
