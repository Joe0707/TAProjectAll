using System;
using UnityEngine;
public class MathUtil
{
    public const float GOLDEN_SECTION_RATIO = 0.618f; //黄金分割比例
    const int DefaultPercision = 2;//默认精度是0.1^2 = 0.01
                                   //数字近似相等
    public static bool NearlyEquals(float a, float b, int percision = DefaultPercision)
    {
        if (a != b)
        {
            var value = Math.Abs(a - b) < Math.Pow(0.1, percision);
            return value;
        }
        return true;
    }

    public static bool V3NearlyEquals(Vector3 a, Vector3 b, int percision = DefaultPercision)
    {
        return NearlyEquals(a.x, b.x, percision) && NearlyEquals(a.y, b.y, percision) && NearlyEquals(a.z, b.z, percision);
    }


    public static bool NearlyGreater(float a, float b, int percision = DefaultPercision)
    {
        if (a > b)
        {
            return !NearlyEquals(a, b);
        }
        return false;
    }

    public static bool NearlyLess(float a, float b, int percision = DefaultPercision)
    {
        if (a < b)
        {
            return !NearlyEquals(a, b);
        }
        return false;
    }

    public static bool NearlyLessEquals(float value1, float value2)
    {
        if (value1 >= value2)
            return NearlyEquals(value1, value2);
        return true;
    }

    public static bool NearlyGreaterEquals(float value1, float value2)
    {
        if (value1 <= value2)
            return NearlyEquals(value1, value2);
        return true;
    }

    //位置近似相等
    public static bool Vector2NearlyEquals(Vector2 a, Vector2 b, int percision = DefaultPercision)
    {
        return NearlyEquals(a.x, b.x, percision) && NearlyEquals(a.y, b.y, percision);
    }
    //角度转弧度
    public static float Degree2Radian(float degree)
    {
        return (float)(degree * Math.PI / 180);
    }
    //计算源位置指向目标位置的旋转角
    public static float ComputeOrientationFaceToPos(Vector3 sourcePosition, Vector3 targetPosition)
    {
        var dir = new Vector3(targetPosition.x - sourcePosition.x, targetPosition.y - sourcePosition.y, targetPosition.z - sourcePosition.z);
        return ComputeOrientationFaceToDir(Vector3.forward, dir);
    }
    //计算源向方向的旋转角
    public static float ComputeOrientationFaceToDir(Vector3 sourceDir, Vector3 toDir)
    {
        toDir.y = 0;
        var angle = Vector3.Angle(sourceDir, toDir);
        var cross = Vector3.Cross(sourceDir, toDir);
        if (cross.y < 0)
        {
            angle = -angle;
        }
        if (angle < 0)
        {
            angle = angle + 360;
        }
        return angle;
    }

    //位置字符串转向量
    public static Vector2 PositionStr2Vector(string position)
    {
        var result = Vector2.zero;
        var positions = position.Split(',');
        if (positions.Length == 2)
        {
            var position1 = positions[0];
            var position2 = positions[1];
            float x = 0;
            float.TryParse(position1, out x);
            float y = 0;
            float.TryParse(position2, out y);
            result = new Vector2(x, y);
        }
        return result;
    }
    //向量到平面投影
    public static Vector3 VectorPlaneProjection(Vector3 v, Plane p)
    {
        //计算v到平面法向量投影
        //用v-投影向量
        var projectV = Vector3.Dot(v, p.normal) * p.normal;
        return v - projectV;
    }

    // 计算线ln[2] 与平面plane[4]的交点 interPt
    public static bool LineInterPlane(Vector3 a, Vector3 b, Plane plane, out Vector3 interPt)
    {
        interPt = Vector3.zero;
        // 直线方程P(t) = Q + tV
        Vector3 Q = a;
        Vector3 V = b - a;
        V.Normalize();

        // 平面方程 N * P(x,y,z) + D = 0 
        Vector3 N = plane.normal; ;
        //N.normalize();
        float D = plane.distance;

        float s = Vector3.Dot(N, V);

        if (s == 0.0) // 直线与平面平行
            return false;

        float q = -D - Vector3.Dot(N, Q);
        float t = q / s;
        // 将t带入直线方程P(t) = Q + tV,就可得到直线与平面的交点
        interPt.x = Q.x + t * V.x;
        interPt.y = Q.y + t * V.y;
        interPt.z = Q.z + t * V.z;
        return true;
    }
    /// <summary>
    /// 计算射线与平面的焦点
    /// </summary>
    /// <param name="point"></param>
    /// <param name="direct"></param>
    /// <param name="planeNormal"></param>
    /// <param name="planePoint"></param>
    /// <returns></returns>
    public static bool RayPlaneIntersection(Vector3 point, Vector3 direct, Vector3 planeNormal, Vector3 planePoint, out Vector3 result)
    {
        result = Vector3.zero;
        //判断如果平行返回空
        if (Vector3.Dot(planeNormal, direct) == 0)
        {
            return false;
        }
        float t;
        t = (Vector3.Dot(planeNormal, planePoint) - Vector3.Dot(planeNormal, point)) / (Vector3.Dot(planeNormal, direct));
        if (t < 0)
        {
            return false;
        }
        result = point + t * direct;
        return true;
    }
    // //Calculate the intersection point of two lines. Returns true if lines intersect, otherwise false.
    // //Note that in 3d, two lines do not intersect most of the time. So if the two lines are not in the 
    // //same plane, use ClosestPointsOnTwoLines() instead.
    // public static bool LineLineIntersection(out Vector3 intersection, Vector3 linePoint1, Vector3 lineVec1, Vector3 linePoint2, Vector3 lineVec2)
    // {

    //     Vector3 lineVec3 = linePoint2 - linePoint1;
    //     Vector3 crossVec1and2 = Vector3.Cross(lineVec1, lineVec2);
    //     Vector3 crossVec3and2 = Vector3.Cross(lineVec3, lineVec2);

    //     float planarFactor = Vector3.Dot(lineVec3, crossVec1and2);

    //     //is coplanar, and not parrallel
    //     if (Mathf.Abs(planarFactor) < 0.0001f && crossVec1and2.sqrMagnitude > 0.0001f)
    //     {
    //         float s = Vector3.Dot(crossVec3and2, crossVec1and2) / crossVec1and2.sqrMagnitude;
    //         intersection = linePoint1 + (lineVec1 * s);
    //         return true;
    //     }
    //     else
    //     {
    //         intersection = Vector3.zero;
    //         return false;
    //     }
    // }

    /// <summary>
    /// 判断线与线之间的相交
    /// </summary>
    /// <param name="intersection">交点</param>
    /// <param name="p1">直线1上一点</param>
    /// <param name="v1">直线1方向</param>
    /// <param name="p2">直线2上一点</param>
    /// <param name="v2">直线2方向</param>
    /// <returns>是否相交</returns>
    public static bool LineLineIntersection(out Vector3 intersection, Vector3 p1, Vector3 v1, Vector3 p2, Vector3 v2)
    {
        intersection = Vector3.zero;
        if (Vector3.Dot(v1, v2) == 1)
        {
            // 两线平行
            return false;
        }

        Vector3 startPointSeg = p2 - p1;
        Vector3 vecS1 = Vector3.Cross(v1, v2);            // 有向面积1
        Vector3 vecS2 = Vector3.Cross(startPointSeg, v2); // 有向面积2
        float num = Vector3.Dot(startPointSeg, vecS1);

        // 判断两这直线是否共面
        if (MathUtil.NearlyEquals(num, 0) == false)
        {
            return false;
        }

        // 有向面积比值，利用点乘是因为结果可能是正数或者负数
        float num2 = Vector3.Dot(vecS2, vecS1) / vecS1.sqrMagnitude;

        intersection = p1 + v1 * num2;
        return true;
    }

    /// <summary>
    /// 计算直线与平面的交点
    /// </summary>
    /// <param name="point">直线上某一点</param>
    /// <param name="direct">直线的方向</param>
    /// <param name="planeNormal">垂直于平面的的向量</param>
    /// <param name="planePoint">平面上的任意一点</param>
    /// <returns></returns>
    public static bool GetIntersectWithLineAndPlane(Vector3 point, Vector3 direct, Vector3 planeNormal, Vector3 planePoint, out Vector3 result)
    {
        result = Vector3.zero;
        //平行返回
        if (Vector3.Dot(direct.normalized, planeNormal) == 0)
        {
            return false;
        }
        float d = Vector3.Dot(planePoint - point, planeNormal) / Vector3.Dot(direct.normalized, planeNormal);
        result = d * direct.normalized + point;
        return true;
    }
    //Clamp函数
    public static float Clamp(float value, float min, float max)
    {
        if (value > max)
        {
            return max;
        }
        if (value < min)
        {
            return min;
        }
        return value;
    }
    //归一化向量
    public static Vector3 NormalizeVector(Vector3 vector)
    {
        float magnitude = vector.magnitude;
        float factor = 1 / magnitude;
        float x = vector.x * factor;
        float z = vector.z * factor;
        return new Vector3(x, vector.y * factor, z);
    }
    //是否点都在一条直线上
    public static bool IsPointsInSameLine(Vector3 a, Vector3 b, Vector3 c)
    {
        var dirab = (b - a).normalized;
        var dirbc = (c - b).normalized;
        return NearlyEquals(Mathf.Abs(Vector3.Dot(dirab, dirbc)), 1);
    }

    //计算2d AABB包围盒求交
    public static bool ComputeAABB2DIntersection(Bounds b1, Bounds b2, out Bounds inter)
    {
        inter = default(Bounds);
        bool isInterSect = b1.Intersects(b2);
        if (isInterSect == false)
        {
            return false;
        }
        //取最大值里的比较小的作为新的最大值 取最小值里的比较大的作为新的最小值
        float xMax = Mathf.Min(b1.max.x, b2.max.x);
        float yMax = Mathf.Min(b1.max.y, b2.max.y);
        float xMin = Mathf.Max(b1.min.x, b2.min.x);
        float yMin = Mathf.Max(b1.min.y, b2.min.y);
        inter.SetMinMax(new Vector3(xMin, yMin, b1.center.z), new Vector3(xMax, yMax, b1.center.z));
        return true;
    }

}