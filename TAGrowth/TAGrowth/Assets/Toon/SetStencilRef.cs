using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetStencilRef : MonoBehaviour
{
    public int refValue;
    // Start is called before the first frame update
    void Start()
    {
        var renders = GetComponentsInChildren<Renderer>();
        foreach (var render in renders)
        {
            render.material.SetInt("_StencilRef", refValue);
        }
    }
}
