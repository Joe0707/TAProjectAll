using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode()]
public class CustomBloom : MonoBehaviour {
    public Material material;
    [Range(0, 10)]
    public float _Intensity = 1;
    [Range(0, 10)]
    public float _Threshold = 1;


    void Start () {
        if (material == null || SystemInfo.supportsImageEffects == false
            || material.shader == null || material.shader.isSupported == false)
        {
            enabled = false;
            return;
        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        RenderTexture RT1 = RenderTexture.GetTemporary(source.width / 2, source.height / 2,0,source.format);
        RenderTexture RT2 = RenderTexture.GetTemporary(source.width / 4, source.height / 4, 0, source.format);
        RenderTexture RT3 = RenderTexture.GetTemporary(source.width / 8, source.height / 8, 0, source.format);
        RenderTexture RT4 = RenderTexture.GetTemporary(source.width / 16, source.height / 16, 0, source.format);
        RenderTexture RT5 = RenderTexture.GetTemporary(source.width / 32, source.height / 32, 0, source.format);
        RenderTexture RT6 = RenderTexture.GetTemporary(source.width / 64, source.height / 64, 0, source.format);
        RenderTexture RT5_up = RenderTexture.GetTemporary(source.width / 32, source.height / 32, 0, source.format);
        RenderTexture RT4_up = RenderTexture.GetTemporary(source.width / 16, source.height / 16, 0, source.format);
        RenderTexture RT3_up = RenderTexture.GetTemporary(source.width / 8, source.height / 8, 0, source.format);
        RenderTexture RT2_up = RenderTexture.GetTemporary(source.width / 4, source.height / 4, 0, source.format);
        RenderTexture RT1_up = RenderTexture.GetTemporary(source.width / 2, source.height / 2, 0, source.format);
        RenderTexture[] rt_list = new RenderTexture[] { RT1 , RT2, RT3, RT4, RT5, RT6,
        RT5_up,RT4_up,RT3_up,RT2_up,RT1_up};
        float intensity = Mathf.Exp(_Intensity / 10.0f * 0.693f) - 1.0f;
        material.SetFloat("_Intensity", intensity);
        material.SetFloat("_Threshold", _Threshold);
        //阈值
        Graphics.Blit(source, RT1, material,0);
        //模糊（降采样）
        Graphics.Blit(RT1, RT2, material, 1);
        Graphics.Blit(RT2, RT3, material, 1);
        Graphics.Blit(RT3, RT4, material, 1);
        Graphics.Blit(RT4, RT5, material, 1);
        Graphics.Blit(RT5, RT6, material, 1);
        //模糊（升采样）
        material.SetTexture("_BloomTex", RT5);
        Graphics.Blit(RT6, RT5_up, material, 2);
        material.SetTexture("_BloomTex", RT4);
        Graphics.Blit(RT5_up, RT4_up, material, 2);
        material.SetTexture("_BloomTex", RT3);
        Graphics.Blit(RT4_up, RT3_up, material, 2);
        material.SetTexture("_BloomTex", RT2);
        Graphics.Blit(RT3_up, RT2_up, material, 2);
        material.SetTexture("_BloomTex", RT1);
        Graphics.Blit(RT2_up, RT1_up, material, 2);
        //合并
        material.SetTexture("_BloomTex", RT1_up);
        Graphics.Blit(source, destination, material, 3);

        //release
        for (int i = 0; i < rt_list.Length; i++)
        {
            RenderTexture.ReleaseTemporary(rt_list[i]);
        }
    }
}
