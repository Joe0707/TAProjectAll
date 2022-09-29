using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyMonsterShaderTest : MonoBehaviour
{
    #region [成员变量]
    public GameObject Monster;
    private Material mat;
    #endregion

    #region [Start/Update]
    void Start()
    {
        mat = Monster.GetComponentInChildren<SkinnedMeshRenderer>().sharedMaterial;
    }

    void Update()
    {
    }
    #endregion

    #region [GUI]
    void OnGUI()
    {
        if (GUI.Button(new Rect(10, 10, 150, 50), "被击"))
        {
            StopAllCoroutines();
            StartCoroutine(WaitBehit());
        }

        if (GUI.Button(new Rect(10, 70, 150, 50), "中毒"))
        {
            StopAllCoroutines();
            StartCoroutine(WaitDu(3f));
        }

        if (GUI.Button(new Rect(10, 130, 150, 50), "死亡"))
        {
            StopAllCoroutines();
            StartCoroutine(WaitDead(3f));
        }
    }
    #endregion

    #region [被击]
    IEnumerator WaitBehit()
    {
        mat.SetColor("_Color", Color.white);

        yield return new WaitForSeconds(0.07f);

        mat.SetColor("_Color", Color.black);
    }
    #endregion

    #region [中毒]
    IEnumerator WaitDu(float time)
    {
        float _time = 0;
        while (true)
        {
            _time += Time.deltaTime;
            yield return new WaitForEndOfFrame();

            if (_time > time)
            {
                yield break;
            }
            else
            {
                Color _color = Color.Lerp(Color.green, Color.black, _time / time);
                mat.SetColor("_Color", _color);
            }
        }
    }
    #endregion

    #region [死亡]
    IEnumerator WaitDead(float time)
    {
        float _time = 0;
        while (true)
        {
            _time += Time.deltaTime;
            yield return new WaitForEndOfFrame();

            if (_time > time)
            {
                mat.DisableKeyword("_DISSOLVEENABLED_ON");
                mat.SetFloat("_Clip", 0);
                yield break;
            }
            else
            {
                mat.EnableKeyword("_DISSOLVEENABLED_ON");
                mat.SetFloat("_Clip", _time / time);
            }
        }
    }
    #endregion
}
