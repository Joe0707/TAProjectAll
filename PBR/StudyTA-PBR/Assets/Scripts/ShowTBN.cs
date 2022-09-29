using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShowTBN : MonoBehaviour
{
    [Header ("显示长度")]
    public float Length = 0.1f;
    public int maxShowNum = 100;
    [Header ("是否显示法线")]
    public bool showNormal = true;
    [Header ("是否显示切线")]
    public bool showTangent = true;
    [Header ("是否显示副切线")]
    public bool showBiTangent = true;

    MeshRenderer meshRenderer;
    SkinnedMeshRenderer skinnedMeshRenderer;
    Mesh sharedMesh;

    Matrix4x4 localToWorld;
    Matrix4x4 localToWorldInverseTranspose;

    private void OnDrawGizmos ()
    {
        meshRenderer = GetComponent<MeshRenderer> ();
        if (meshRenderer)
            sharedMesh = GetComponent<MeshFilter> ().sharedMesh;
        skinnedMeshRenderer = GetComponent<SkinnedMeshRenderer> ();
        if (skinnedMeshRenderer)
            sharedMesh = skinnedMeshRenderer.sharedMesh;

        localToWorld = transform.localToWorldMatrix;
        localToWorldInverseTranspose = localToWorld.inverse.transpose;

        Vector3[ ] vertices = sharedMesh.vertices;
        Vector3[ ] normals = sharedMesh.normals;
        Vector4[ ] tangents = sharedMesh.tangents;

        int tangentsLen = (tangents != null ? tangents.Length : 0);
        Vector3[ ] biTangents = new Vector3[tangentsLen];
        Vector3[ ] tangentsData = new Vector3[tangentsLen];
        for (int i = 0; i < tangentsLen; i++)
        {
            //切向量数据 Vector4 转 Vector3
            tangentsData[i].x = tangents[i].x;
            tangentsData[i].y = tangents[i].y;
            tangentsData[i].z = tangents[i].z;
            //计算副切线 cross(法向量，切向量)*坐标系方向参数
            biTangents[i] = Vector3.Cross (normals[i], tangentsData[i]) * tangents[i].w;
        }

        /*
         * localToWorld 将 顶点位置 从模型坐标系转到世界坐标系矩阵
         * localToWorldInverseTranspose 将 向量 从模型坐标系转到世界坐标系矩阵
         *      1、切向量t和副切向量b 由于方向与纹理坐标系一致 使用localToWorld和localToWorldInverseTranspose矩阵转换到世界坐标系 结果相同
         *      2、normal 由于模型有非等比缩放的情况，缩放后顶点的法向量使用localToWorld矩阵转换的结果不正确
         *      设矩阵M为切向量t的转换矩阵,矩阵G为法向量n的转换矩阵,
         *      转换后的切向量且t2 = M*t， 转换后的法向量n2 = G*n，同时要求 n2 * t2 = 0
         *      所以  (G*n)' * (M*t) = 0  =>  n'*G'*M*t = 0  (n'表示向量n的转置, G'表示矩阵G的转置)
         *      已知 n'*t = 0(法向量和切向量垂直)， 此时如果令 G'*M = I(单位矩阵)
         *      则有 n'*G'*M*t = n'*I*t = n'*t = 0 成立
         *      可得 G'*M = I => G = (inverse(M))'
         */
        if (showNormal) DrawVectors (vertices, normals, ref localToWorld, ref localToWorldInverseTranspose, Color.red, Length);
        if (showTangent) DrawVectors (vertices, tangentsData, ref localToWorld, ref localToWorld, Color.green, Length);
        if (showBiTangent) DrawVectors (vertices, biTangents, ref localToWorld, ref localToWorld, Color.blue, Length);
    }

    /*显示向量
     * vertexs 向量初始位置
     * vectors 向量方向
     * vertexMatrix 向量初始位置从模型坐标系转到世界坐标系矩阵
     * vectorMatrix 向量方向从模型坐标系转到世界坐标系矩阵
     * color 向量颜色
     * */
    void DrawVectors (Vector3[ ] vertexs, Vector3[ ] vectors, ref Matrix4x4 vertexMatrix, ref Matrix4x4 vectorMatrix, Color color, float vectorLen)
    {
        Gizmos.color = color;
        int len = (vertexs == null || vectors == null ? 0 : vertexs.Length);
        len = Mathf.Min (len, maxShowNum);
        if (vertexs.Length != vectors.Length)
        {
            Debug.LogError ("vertexs lenght not equal vectors length!!!");
            return;
        }
        for (int i = 0; i < len; i++)
        {
            Vector3 vertexData = vertexMatrix.MultiplyPoint (vertexs[i]);
            Vector3 vectorData = vectorMatrix.MultiplyVector (vectors[i]);
            vectorData.Normalize ();
            Gizmos.DrawLine (vertexData, vertexData + vectorData * vectorLen);
        }
    }
}