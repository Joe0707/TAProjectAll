using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;

public class Swapper : MonoBehaviour{
    public GameObject[] character;
    public Animator[] animators;
    public int index;
    public Texture btn_tex;

    private int cur_animid = 1;


    void Awake()
    {
        foreach (GameObject c in character)
        {
            c.SetActive(false);
        }
        character[0].SetActive(true);
    }
    void OnGUI()
    {
        if (GUI.Button(new Rect(Screen.width - 100, 0, 100, 100), btn_tex))
        {
            var req_rotate = character[index].transform.rotation;
            character[index].SetActive(false);
            index++;
            index %= character.Length;
            character[index].SetActive(true);
            character[index].transform.rotation = req_rotate;
            string anim_id = "animation," + cur_animid.ToString();
            SetInt(anim_id);
            Camera.main.transform.GetComponent<MouseOrbit>().targetObj = character[index];
        }
    }
    
    public void SetFloat(string parameter = "key,value")
    {
        char[] separator = { ',', ';' };
        string[] param = parameter.Split(separator);

        string name = param[0];
        float value = (float)Convert.ToDouble(param[1]);

        Debug.Log(name + " " + value);

        foreach (Animator a in animators)
        {
            if(a != null)
            a.SetFloat(name, value);
        }
    }
    public void SetInt(string parameter = "key,value")
    {
        char[] separator = { ',', ';' };
        string[] param = parameter.Split(separator);

        string name = param[0];
        int value = Convert.ToInt32(param[1]);

        Debug.Log(name + " " + value);
        this.GetComponent<Swapper>().cur_animid = value;
        foreach (Animator a in animators)
        {
            if (a != null)
            a.SetInteger(name, value);
        }
    }

    public void SetBool(string parameter = "key,value")
    {
        char[] separator = { ',', ';' };
        string[] param = parameter.Split(separator);

        string name = param[0];
        bool value = Convert.ToBoolean(param[1]);

        Debug.Log(name + " " + value);

        foreach (Animator a in animators)
        {
            if (a != null)
            a.SetBool(name, value);
        }
    }

    public void SetTrigger(string parameter = "key,value")
    {
        char[] separator = { ',', ';' };
        string[] param = parameter.Split(separator);

        string name = param[0];

        Debug.Log(name);

        foreach (Animator a in animators)
        {
            if (a != null)
            a.SetTrigger(name);
        }
    }
}

