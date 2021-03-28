// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Crystal"
{
	Properties
	{
		_RimScale("RimScale", Float) = 1
		_RimPower("RimPower", Float) = 1
		_RimColor("RimColor", Color) = (0,0,0,0)
		_RimBias("RimBias", Float) = 0
		_NormalMap("NormalMap", 2D) = "bump" {}
		_EmissMask("EmissMask", 2D) = "black" {}
		_ReflectTex("ReflectTex", CUBE) = "white" {}
		_ReflectIntensity("ReflectIntensity", Float) = 1
		_InsideTex("InsideTex", 2D) = "white" {}
		_TillingOffset("TillingOffset", Vector) = (1,1,0,0)
		_UVDistort("UVDistort", Float) = 0
		_InsideColor("InsideColor", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 worldRefl;
		};

		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _RimBias;
		uniform float _RimScale;
		uniform float _RimPower;
		uniform sampler2D _EmissMask;
		uniform float4 _EmissMask_ST;
		uniform float4 _RimColor;
		uniform samplerCUBE _ReflectTex;
		uniform float _ReflectIntensity;
		uniform sampler2D _InsideTex;
		uniform float4 _TillingOffset;
		uniform float _UVDistort;
		uniform float4 _InsideColor;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 tex2DNode9 = UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) );
			float3 NormalWorld26 = (WorldNormalVector( i , tex2DNode9 ));
			float fresnelNdotV1 = dot( NormalWorld26, ase_worldViewDir );
			float fresnelNode1 = ( _RimBias + _RimScale * pow( 1.0 - fresnelNdotV1, _RimPower ) );
			float2 uv_EmissMask = i.uv_texcoord * _EmissMask_ST.xy + _EmissMask_ST.zw;
			float4 RimColor12 = ( ( fresnelNode1 + tex2D( _EmissMask, uv_EmissMask ).r ) * _RimColor );
			float3 NormalMap23 = tex2DNode9;
			float dotResult29 = dot( NormalWorld26 , ase_worldViewDir );
			float clampResult33 = clamp( ( 1.0 - dotResult29 ) , 0.0 , 1.0 );
			float FresnelFactor35 = clampResult33;
			float4 ReflectColor19 = ( texCUBE( _ReflectTex, WorldReflectionVector( i , NormalMap23 ) ) * _ReflectIntensity * ( FresnelFactor35 * FresnelFactor35 ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToView53 = mul( UNITY_MATRIX_MV, float4( ase_vertex3Pos, 1 ) ).xyz;
			float3 objToView54 = mul( UNITY_MATRIX_MV, float4( float3(0,0,0), 1 ) ).xyz;
			float3 worldToViewDir64 = mul( UNITY_MATRIX_V, float4( NormalWorld26, 0 ) ).xyz;
			float4 lerpResult66 = lerp( tex2D( _InsideTex, ( ( ( (( objToView53 - objToView54 )).xy * (_TillingOffset).xy ) + (_TillingOffset).zw ) + ( (worldToViewDir64).xy * _UVDistort ) ) ) , _InsideColor , FresnelFactor35);
			float4 InsideColor41 = lerpResult66;
			o.Emission = ( RimColor12 + ReflectColor19 + InsideColor41 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.worldRefl = -worldViewDir;
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
7;29;1522;788;1236.538;-1010.003;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;38;-2263.5,-1238.957;Inherit;False;998.2239;376.484;NormalMap;4;9;2;26;23;NormalMap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;65;-2254.899,1034.929;Inherit;False;2240.946;889.347;InsideColor;22;44;48;64;62;49;47;59;50;61;60;40;41;56;52;53;54;57;58;46;66;68;69;InsideColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;9;-2213.5,-1092.473;Inherit;True;Property;_NormalMap;NormalMap;4;0;Create;True;0;0;False;0;False;-1;None;eb4e44c60fdb95b46bceece8c533d2b4;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;52;-2135.312,1084.929;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;56;-2204.899,1316.378;Inherit;False;Constant;_Vector0;Vector 0;10;0;Create;True;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;2;-1774.228,-1053.502;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;54;-1988.576,1317.891;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;53;-1943.194,1118.209;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;-1508.276,-1007.274;Inherit;False;NormalWorld;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;22;-2267.637,314.211;Inherit;False;1600.906;564.9825;ReflectColor;13;19;18;34;17;15;35;16;25;33;32;29;27;31;ReflectColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;46;-1743.627,1526.649;Inherit;False;Property;_TillingOffset;TillingOffset;9;0;Create;True;0;0;False;0;False;1,1,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;57;-1702.669,1274.022;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-1732.867,1809.276;Inherit;False;26;NormalWorld;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;31;-2232.339,654.4756;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;27;-2206.594,551.4925;Inherit;False;26;NormalWorld;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;48;-1495.023,1298.836;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TransformDirectionNode;64;-1419.819,1557.259;Inherit;False;World;View;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;44;-1481.407,1124.871;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;13;-2265.486,-753.1864;Inherit;False;1533.402;868.7281;Comment;11;3;6;4;5;11;1;8;10;12;7;24;RimColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;29;-1990.329,613.2823;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-1178.861,1705.763;Inherit;False;Property;_UVDistort;UVDistort;10;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-2062.373,-146.6393;Inherit;False;Property;_RimPower;RimPower;1;0;Create;True;0;0;False;0;False;1;2.21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-1337.698,1197.484;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;59;-1148.657,1571.925;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;49;-1510.151,1422.88;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-1940.281,-1188.957;Inherit;False;NormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-1879.688,-632.1179;Inherit;False;26;NormalWorld;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;3;-1791.934,-464.1213;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;5;-2079.373,-232.6392;Inherit;False;Property;_RimScale;RimScale;0;0;Create;True;0;0;False;0;False;1;1.44;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;32;-1842.72,628.7299;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-2053.373,-332.6392;Inherit;False;Property;_RimBias;RimBias;3;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-2212.775,383.2936;Inherit;False;23;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-938.3363,1610.46;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-1095.661,1345.731;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;11;-1749.571,-249.6033;Inherit;True;Property;_EmissMask;EmissMask;5;0;Create;True;0;0;False;0;False;-1;None;60a64895c5f546c498f6e63d95c847fe;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;1;-1536.934,-472.1213;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;33;-1669.366,625.2972;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-1516.607,635.5955;Inherit;False;FresnelFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-787.0624,1459.186;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldReflectionVector;16;-1981.448,386.4168;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;8;-1453.527,-91.45828;Inherit;False;Property;_RimColor;RimColor;2;0;Create;True;0;0;False;0;False;0,0,0,0;0,0.4206896,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-1345.32,-264.677;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;15;-1747.945,389.2078;Inherit;True;Property;_ReflectTex;ReflectTex;6;0;Create;True;0;0;False;0;False;-1;None;9143b80d078e6064393fa54b89803e6d;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;69;-606.5383,1597.003;Inherit;False;35;FresnelFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;68;-657.5383,1373.003;Inherit;False;Property;_InsideColor;InsideColor;11;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;40;-795.6947,1155.7;Inherit;True;Property;_InsideTex;InsideTex;8;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-1176.231,-197.9405;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1451.969,362.6291;Inherit;False;Property;_ReflectIntensity;ReflectIntensity;7;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-1283.178,628.7298;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;-975.0839,-198.2156;Inherit;False;RimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;66;-379.3942,1304.523;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-1249.069,506.3325;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;-1172.84,365.5872;Inherit;False;ReflectColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;-229.4957,1129.544;Inherit;False;InsideColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;14;-579.3823,-138.7064;Inherit;False;12;RimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-610.8736,145.1749;Inherit;False;19;ReflectColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;-518.2177,340.7772;Inherit;False;41;InsideColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;37;-365.4641,-12.03503;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-91.0177,51.00566;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-133.8807,-43.32985;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;243.7425,-8.617199;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Crystal;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;2;0;9;0
WireConnection;54;0;56;0
WireConnection;53;0;52;0
WireConnection;26;0;2;0
WireConnection;57;0;53;0
WireConnection;57;1;54;0
WireConnection;48;0;46;0
WireConnection;64;0;58;0
WireConnection;44;0;57;0
WireConnection;29;0;27;0
WireConnection;29;1;31;0
WireConnection;47;0;44;0
WireConnection;47;1;48;0
WireConnection;59;0;64;0
WireConnection;49;0;46;0
WireConnection;23;0;9;0
WireConnection;32;0;29;0
WireConnection;61;0;59;0
WireConnection;61;1;62;0
WireConnection;50;0;47;0
WireConnection;50;1;49;0
WireConnection;1;0;24;0
WireConnection;1;4;3;0
WireConnection;1;1;4;0
WireConnection;1;2;5;0
WireConnection;1;3;6;0
WireConnection;33;0;32;0
WireConnection;35;0;33;0
WireConnection;60;0;50;0
WireConnection;60;1;61;0
WireConnection;16;0;25;0
WireConnection;10;0;1;0
WireConnection;10;1;11;1
WireConnection;15;1;16;0
WireConnection;40;1;60;0
WireConnection;7;0;10;0
WireConnection;7;1;8;0
WireConnection;34;0;35;0
WireConnection;34;1;35;0
WireConnection;12;0;7;0
WireConnection;66;0;40;0
WireConnection;66;1;68;0
WireConnection;66;2;69;0
WireConnection;18;0;15;0
WireConnection;18;1;17;0
WireConnection;18;2;34;0
WireConnection;19;0;18;0
WireConnection;41;0;66;0
WireConnection;37;0;14;0
WireConnection;36;0;37;0
WireConnection;36;1;20;0
WireConnection;36;2;42;0
WireConnection;21;0;14;0
WireConnection;21;1;20;0
WireConnection;0;2;36;0
ASEEND*/
//CHKSM=A60CE73FE4EF7339EF7EC5926B6778147CC12F6E