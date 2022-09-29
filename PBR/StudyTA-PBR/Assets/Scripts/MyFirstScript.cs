using System.Collections;
using System.Collections.Generic;
using UnityEngine;
// using taecg.math;

namespace taecg.math
{
    //[] = 可选项
    //<> = 必选项
    //[访问修饰符] class <类名(派生类)> [:继承(基类)]
    public class MyFirstScript : MonoBehaviour
    {
        //public = 公共
        //private = 私有

        //变量命名规则:
        //首字母不能以数字和特殊符号开头
        //private通常用小驼峰命名：首字母小写，其它单词的首字母大写
        //public通常用大驼峰命名：所有单词的首字母全部用大写

        //变量类型：
        //int = 整型
        //float = 浮点数值
        //string = 字符串
        //bool = 布尔类型(真假)
        //vectorX = 向量
        //[访问修饰符] [const常量标识符] <变量类型> <变量名称> [=默认值] <;>
        private const string startText = "游戏一开始时执行一次!";
        private const string updateText = "游戏运行后每一帧都会执行~";

        public GameObject mGO;
        // public float Number01;
        // public float Number02;
        // public float Number03;
        public float[] Numbers = new float[] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
        public Vector4 Number;  //float4

        //方法的默认访问修饰符=private
        //[访问修饰符] <返回类型> <方法名称> ([参数列表])
        // Start is called before the first frame update
        void Start()
        {

        }

        // Update is called once per frame
        void Update()
        {

        }

        void OnGUI()
        {
            if (GUI.Button(new Rect(10, 10, 200, 50), "计算"))
            {
                Debug.Log(Numbers[5]);

                // //类在使用前须实例化
                // MyMath myMath =new MyMath();
                // float value = myMath.Add(Number.x,Number.y,Number.z,Number.w);
                // Debug.Log(value);

                // while(Number01<10)
                // {
                //     Debug.Log(Number01);
                //     Number01++;
                // }

                // do
                // {
                //     Debug.Log(Number01);
                //     Number01++;
                // }
                // while(Number01<10);

                // for(int i=0;i<10;i++)
                // {
                //     Debug.Log(i);
                // }

                // foreach(float i in Numbers)
                // {
                //     Debug.Log(i);
                // }

                // Debug.Log("继续往下执行");

                // string _score;
                // if(Number01==100)
                // {
                //     _score = "S";
                // }
                // else if(Number01>=90)
                // {
                //     _score = "A";
                // }
                // else if(Number01>=60)
                // {
                //     _score = "B";
                // }
                // else
                // {
                //     _score ="C";
                // }

                // switch(_score)
                // {
                //     case "S":
                //     case "A":
                //     Debug.Log("分数评级A!!!");
                //     break;
                //     case "B":
                //     Debug.Log("分数评级B!!!");
                //     break;
                //     case "C":
                //     Debug.Log("分数评级C!!!");
                //     break;
                //     default:
                //     Debug.LogError("评级超出给定范围，有误!");
                //     break;
                // }
            }
        }

        //<变量类型1> <变量名称1> [=默认值1],<变量类型2> <变量名称2> [=默认值2],....
    }
}
