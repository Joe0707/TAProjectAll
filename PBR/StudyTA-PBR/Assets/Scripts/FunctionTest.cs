using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FunctionTest : MonoBehaviour
{
    private void OnGUI() 
    {
        if(GUI.Button(new Rect(10,50,300,80),"nx2=?"))
        {
            //点击按钮时调用此方法函数,传递参数5到方法中，返回方法内执行后得到的数值
            Debug.Log(Multiply2(8));
        }
    }

    /// <summary>
    /// 方法函数：乘以2
    /// </summary>
    /// <param name="value">值</param>
    /// <returns></returns>
    float Multiply2(float value)
    {
        return value*2;
    }

}
