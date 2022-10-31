using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class BWEffect : MonoBehaviour {
	public Material m;

	[Range(0,1)]
	public float intensity = 0;
	
	void Awake()
	{
		//m = new Material(Shader.Find("Hidden/BWDiffuse"));
	}

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		//m.SetFloat("_bwBlend", intensity);
		Graphics.Blit(src, dest, m);
	}
}
