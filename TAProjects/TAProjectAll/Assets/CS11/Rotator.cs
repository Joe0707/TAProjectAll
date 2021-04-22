using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotator : MonoBehaviour {
    public float speed = 1.0f;
    public Vector3 direction = new Vector3(0.0f, 0.0f, 0.0f);
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
        this.transform.eulerAngles = this.transform.eulerAngles + new Vector3(Time.deltaTime * speed * direction.x, Time.deltaTime * speed * direction.y, Time.deltaTime * speed * direction.z);
	}
}
