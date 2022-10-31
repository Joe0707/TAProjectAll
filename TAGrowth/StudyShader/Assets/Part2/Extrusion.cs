using UnityEngine;
using System.Collections;

public class Extrusion : MonoBehaviour {
	public float range;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
		float f = Mathf.PingPong (Time.time*0.001f, range)-range/2;
		GetComponent<MeshRenderer> ().materials [0].SetFloat ("_Amount", f);
	}
}
