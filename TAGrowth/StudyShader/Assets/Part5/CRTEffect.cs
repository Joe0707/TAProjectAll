using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CRTEffect : MonoBehaviour {
	public Material m;

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (m == null)
		{
			Graphics.Blit(src, dest);
		}
		else
		{
			Graphics.Blit(src, dest, m);
		}
	}
}
