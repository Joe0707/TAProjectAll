using UnityEngine;

//-----------------------------------------------------------------------------
// Copyright 2012-2019 RenderHeads Ltd.  All rights reserved.
//-----------------------------------------------------------------------------

namespace RenderHeads.Media.AVProMovieCapture.Demos
{
	/// <summary>
	/// Animates a procedural texture effect driven by a shader
	/// </summary>
	public class TextureCaptureDemo : MonoBehaviour
	{
		[SerializeField]
		private Shader _shader = null;

		[SerializeField]
		private int _textureWidth = 1024;

		[SerializeField]
		private int _textureHeight = 1024;

		[SerializeField]
		private CaptureFromTexture _movieCapture = null;

		// State
		private Material _material;
		private RenderTexture _texture;

		private void Start()
		{
			_material = new Material(_shader);

			_texture = new RenderTexture(_textureWidth, _textureHeight, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
			_texture.filterMode = FilterMode.Bilinear;
			_texture.Create();

			if (_movieCapture)
			{
				_movieCapture.SetSourceTexture(_texture);
			}
		}

		private void OnDestroy()
		{
			if (_material != null)
			{
				Material.Destroy(_material);
				_material = null;
			}
			if (_texture != null)
			{
				RenderTexture.Destroy(_texture);
				_texture = null;
			}
		}

		private void Update()
		{
			UpdateTexture();
		}

		private void UpdateTexture()
		{
			Graphics.Blit(Texture2D.whiteTexture, _texture, _material);
		}

		private void OnGUI()
		{
			if (_texture != null)
			{
				GUI.depth = 100;
				GUI.DrawTexture(new Rect(0f, 0f, Screen.width, Screen.height), _texture, ScaleMode.ScaleToFit, false);
			}
		}
	}
}