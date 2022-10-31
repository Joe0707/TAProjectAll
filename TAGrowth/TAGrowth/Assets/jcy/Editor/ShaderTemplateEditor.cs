using System.Collections;
using System.Collections.Generic;
using UnityEditor;
public class ShaderTemplateEditor : Editor
{
    [MenuItem("Assets/Create/Shader/Unlit URP Shader")]
    static void UnlitURPShader()
    {
        string path = AssetDatabase.GetAssetPath(Selection.activeObject);
        string templatePath = AssetDatabase.GUIDToAssetPath("80ca5940cea503544b651337d227a4bf");
        string newPath = string.Format("{0}/New Unlit URP Shader.shader", path);
        AssetDatabase.CopyAsset(templatePath, newPath);
        AssetDatabase.ImportAsset(newPath);
    }
}
