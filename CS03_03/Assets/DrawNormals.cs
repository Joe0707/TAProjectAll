using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

public class DrawNormals : MonoBehaviour
{
#if UNITY_EDITOR
    [SerializeField]
    private MeshFilter _meshFilter = null;
    //[SerializeField]
    //private bool _displayWireframe = false;
    [SerializeField]
    private NormalsDrawData _vertexNormals = new NormalsDrawData(new Color32(0,0,255, 127), true);
    [SerializeField]
    private NormalsDrawData _vertexTangents = new NormalsDrawData(new Color32(0, 255, 0, 127), true);
    [SerializeField]
    private NormalsDrawData _vertexBinormals = new NormalsDrawData(new Color32(255, 0, 0, 127), true);

    [System.Serializable]
    private class NormalsDrawData
    {
        [SerializeField]
        protected DrawType _draw = DrawType.Selected;
        protected enum DrawType { Never, Selected, Always }
        [SerializeField]
        protected float _length = 0.3f;
        [SerializeField]
        protected Color _normalColor;
        private Color _baseColor = new Color32(255, 133, 0, 255);
        [SerializeField]
        protected  float _baseSize = 0.0125f;


        public NormalsDrawData(Color normalColor, bool draw)
        {
            _normalColor = normalColor;
            _draw = draw ? DrawType.Selected : DrawType.Never;
        }

        public bool CanDraw(bool isSelected)
        {
            return (_draw == DrawType.Always) || (_draw == DrawType.Selected && isSelected);
        }

        public void Draw(Vector3 from, Vector3 direction)
        {
                Gizmos.color = _baseColor;
                Gizmos.DrawWireSphere(from, _baseSize);

                Gizmos.color = _normalColor;
                Gizmos.DrawRay(from, direction * _length);
        }
    }

    void OnDrawGizmosSelected()
    {
        //EditorUtility.SetSelectedWireframeHidden(GetComponent<Renderer>(), !_displayWireframe);
        OnDrawNormals(true);
    }

    void OnDrawGizmos()
    {
        if (!Selection.Contains(this))
            OnDrawNormals(false);
    }

    private void OnDrawNormals(bool isSelected)
    {
        if (_meshFilter == null)
        {
            _meshFilter = GetComponent<MeshFilter>();
            if (_meshFilter == null)
                return;
        }

        Mesh mesh = _meshFilter.sharedMesh;

        //Draw Vertex Normals

        Vector3[] vertices = mesh.vertices;
        Vector3[] normals = mesh.normals;
        Vector4[] tangents = mesh.tangents;
        

        for (int i = 0; i < vertices.Length; i++)
        {
            Vector3 view_world = Vector3.Normalize(Camera.current.transform.forward - vertices[i]);
            Vector3 normal_world = Vector3.Normalize(transform.TransformVector(normals[i]));
            float NdotV = Vector3.Dot(normal_world, view_world);
            if (NdotV < 0.0)
            {
                Vector3 tangent_world = transform.TransformVector(new Vector3(tangents[i].x, tangents[i].y, tangents[i].z));
                if (_vertexNormals.CanDraw(isSelected))
                    _vertexNormals.Draw(transform.TransformPoint(vertices[i]), normal_world);
                if (_vertexTangents.CanDraw(isSelected))
                    _vertexTangents.Draw(transform.TransformPoint(vertices[i]), tangent_world);
                Vector3 binormal_world = Vector3.Normalize(Vector3.Cross(normal_world, tangent_world) * tangents[i].w);
                if (_vertexBinormals.CanDraw(isSelected))
                    _vertexBinormals.Draw(transform.TransformPoint(vertices[i]), binormal_world);
            }
        }
    }
#endif
}