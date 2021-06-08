using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
 
public class BatchSetLodGroupWindow : EditorWindow{
 
    LODFadeMode fadeMode = LODFadeMode.None;
    float cullRatio = 0.01f;
    public float[] lodWeights = new float[] { 0.6f, 0.3f, 0.1f };
    public GameObject rootGo;
 
    [MenuItem("Tools/BatchSetLodGroups")]
    public static void ShowWindow() {
        //Show existing window instance. If one doesn't exist, make one.
        EditorWindow.GetWindow(typeof(BatchSetLodGroupWindow));
    }

    void OnGUI()
    {

        GUILayout.Label("LODGroup Settings", EditorStyles.boldLabel);
        rootGo = EditorGUILayout.ObjectField("RootObject", rootGo, typeof(GameObject), true) as GameObject;
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.PrefixLabel("Fade Mode");
        fadeMode = (LODFadeMode)EditorGUILayout.EnumPopup((Enum)fadeMode);
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.PrefixLabel("Cull Ratio (0.01 = 1%)");
        cullRatio = EditorGUILayout.FloatField(cullRatio);
        EditorGUILayout.EndHorizontal();

        ScriptableObject target = this;
        SerializedObject so = new SerializedObject(target);
        SerializedProperty prop = so.FindProperty("lodWeights");
        EditorGUILayout.PropertyField(prop, true);
        so.ApplyModifiedProperties();


        if (GUILayout.Button("Apply"))
        {
            if (rootGo != null)
            {
                var lodgrouds = rootGo.GetComponentsInChildren<LODGroup>();
                foreach (var lodGroup in lodgrouds)
                {
                    lodGroup.fadeMode = fadeMode;
                    LOD[] lods = lodGroup.GetLODs();

                    float weightSum = 0;
                    for (int k = 0; k < lods.Length; k++)
                    {

                        if (k >= lodWeights.Length)
                        {
                            weightSum += lodWeights[lodWeights.Length - 1];
                        }
                        else
                        {
                            weightSum += lodWeights[k];
                        }
                    }


                    float maxLength = 1 - cullRatio;
                    float curLodPos = 1;
                    for (int j = 0; j < lods.Length; j++)
                    {

                        float weight = j < lodWeights.Length ? lodWeights[j] : lodWeights[lodWeights.Length - 1];

                        float lengthRatio = weightSum != 0 ? weight / weightSum : 1;

                        float lodLength = maxLength * lengthRatio;
                        curLodPos = curLodPos - lodLength;

                        lods[j].screenRelativeTransitionHeight = curLodPos;
                        var render = lodGroup.transform.GetChild(j).GetComponent<Renderer>();
                        if(render != null)
                        lods[j].renderers = new Renderer[] { render };
                    }


                    lodGroup.SetLODs(lods);
                }
            }
        }
    }
}