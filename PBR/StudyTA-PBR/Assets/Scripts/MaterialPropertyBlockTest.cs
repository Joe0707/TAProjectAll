using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialPropertyBlockTest : MonoBehaviour
{
    [Header("生成的对象")]
    public GameObject GameObj;
    [Header("生成数量")]
    public int Count = 100;
    [Header("生成范围")]
    public float Range = 10;
    private GameObject[] GameObjs;
    private MaterialPropertyBlock prop;

    void Start()
    {
        GameObjs = new GameObject[Count];
        prop = new MaterialPropertyBlock();

        for (int i = 0; i < Count; i++)
        {
            //随机位置并生成对象
            Vector2 pos = Random.insideUnitCircle * Range;
            GameObject go = Instantiate(GameObj, new Vector3(pos.x, 0, pos.y), Quaternion.identity);
            GameObjs[i] = go;
        }
    }

    // Update is called once per frame
    void Update()
    {
        //没有使用MaterialPropertyBlock
        // for (int i = 0; i < GameObjs.Length; i++)
        // {
        //     float r = Random.Range (0f, 1f);
        //     float g = Random.Range (0f, 1f);
        //     float b = Random.Range (0f, 1f);
        //     Color _newColor = new Color (r, g, b, 1);
        //     GameObjs[i].GetComponentInChildren<MeshRenderer> ().material.SetColor ("_Color", _newColor);
        // }

        //使用MaterialPropertyBlock方案
        for (int i = 0; i < GameObjs.Length; i++)
        {
            float r = Random.Range(0f, 1f);
            float g = Random.Range(0f, 1f);
            float b = Random.Range(0f, 1f);
            Color _newColor = new Color(r, g, b, 1);
            var mr = GameObjs[i].GetComponentInChildren<MeshRenderer>();
            mr.GetPropertyBlock(prop);
            prop.SetColor("_Color", _newColor);
            mr.SetPropertyBlock(prop);
        }
    }
}