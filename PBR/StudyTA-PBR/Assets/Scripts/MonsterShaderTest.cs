/**
 * @file            MonsterShaderTest 
 * @author          taecg     
 *
 * @brief           
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MonsterShaderTest : MonoBehaviour
{
    public GameObject Monster;
    private Material mMat;

    #region [Start/Update]
    void Start ()
    {
        mMat = Monster.GetComponentInChildren<SkinnedMeshRenderer> ().sharedMaterial;
    }
    #endregion

    #region  [OnGUI]
    private void OnGUI ()
    {
        if (GUI.Button (new Rect (10, 10, 100, 30), "Behit"))
        {
            Behit ();
        }

        if (GUI.Button (new Rect (10, 50, 100, 30), "Fire"))
        {
            Fire (3f);
        }

        if (GUI.Button (new Rect (10, 90, 100, 30), "Dead"))
        {
            Dead (2f);
        }
    }
    #endregion

    #region [Behit]
    void Behit ()
    {
        StopAllCoroutines ();
        StartCoroutine (WaitBehit (0.05f));
    }
    IEnumerator WaitBehit (float time)
    {
        mMat.DisableKeyword ("_DISSOLVEENABLED_ON");
        mMat.SetColor ("_Color", Color.white);
        yield return new WaitForSeconds (time);
        mMat.SetColor ("_Color", Color.black);
    }
    #endregion

    #region [Fire]
    void Fire (float time)
    {
        StopAllCoroutines ();
        StartCoroutine (WaitFire (time));
    }
    IEnumerator WaitFire (float time)
    {
        // mMat.SetColor ("_Color", new Color(0.6f,0.12f,0.07f));

        float _time = 0;
        while (true)
        {
            yield return new WaitForEndOfFrame ();
            _time += Time.deltaTime;
            if (_time >= time)
            {
                yield return new WaitForSeconds(0.5f);
                mMat.SetColor ("_Color", Color.black);
                break;
            }
            else
            {
                Color _color = Color.Lerp(new Color(0.6f,0.12f,0.07f),Color.black,_time/time);
                mMat.SetColor ("_Color", _color);
            }
        }
    }
    #endregion

    #region [Dead]
    void Dead (float time)
    {
        StopAllCoroutines ();
        StartCoroutine (WaitDead (time));
    }
    IEnumerator WaitDead (float time)
    {
        mMat.EnableKeyword ("_DISSOLVEENABLED_ON");
        mMat.SetFloat ("_Clip", 0);

        float _time = 0;
        while (true)
        {
            yield return new WaitForEndOfFrame ();
            _time += Time.deltaTime;
            if (_time >= time)
            {
                yield return new WaitForSeconds(0.5f);
                mMat.DisableKeyword ("_DISSOLVEENABLED_ON");
                mMat.SetFloat ("_Clip", 0);
                break;
            }
            else
            {
                mMat.SetFloat ("_Clip", _time / time);
            }
        }
    }
    #endregion
}