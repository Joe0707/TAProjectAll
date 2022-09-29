using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GPUInstancing : MonoBehaviour
{
    [Header("生成的对象")]
    public GameObject Prefab;
    [Header("生成的数量")]
    public int Count;
    [Header("生成的范围")]
    public float Range = 30;

    void Start()
    {
        for (int i = 0; i < Count; i++)
        {
            Vector2 pos = Random.insideUnitCircle * Range;
            GameObject tree = Instantiate(Prefab, new Vector3(pos.x, 0, pos.y), Quaternion.identity);

            Color newCol = new Color(Random.value, Random.value, Random.value);
            //必须通过材质属性块去修改每一个材质的属性
            MaterialPropertyBlock prop = new MaterialPropertyBlock();
            prop.SetColor("_Color", newCol);
            tree.GetComponentInChildren<MeshRenderer>().SetPropertyBlock(prop);
        }
    }
}
