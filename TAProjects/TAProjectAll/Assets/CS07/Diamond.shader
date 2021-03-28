// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Diamond"
{
	Properties
	{
		_ColorA("ColorA", Color) = (1,1,1,0)
		_ReflectTex("ReflectTex", CUBE) = "white" {}
		_RefractTex("RefractTex", CUBE) = "white" {}
		_ReflactIntensity("ReflactIntensity", Float) = 1
		_ReflectionStrength("ReflectionStrength", Float) = 1
		_RimPower("RimPower", Float) = 2
		_RimScale("RimScale", Float) = 1
		_RimBias("RimBias", Float) = 0
		_RimColor("RimColor", Color) = (0,0,0,0)

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" "Queue"="Geometry" }
	LOD 100

		
		
		Pass
		{
			Name "Unlit"
			Blend Off
						ZWrite On
			ZTest LEqual
			Cull Front

			// Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _ColorA;
			uniform samplerCUBE _RefractTex;
			uniform samplerCUBE _ReflectTex;
			uniform float _ReflactIntensity;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldReflection = reflect(-ase_worldViewDir, ase_worldNormal);
				float4 texCUBENode8 = texCUBE( _ReflectTex, ase_worldReflection );
				float4 temp_output_17_0 = ( _ColorA * texCUBE( _RefractTex, ase_worldReflection ) * texCUBENode8 * _ReflactIntensity );
				
				
				finalColor = temp_output_17_0;
				return finalColor;
			}
			ENDCG
		}
		
		Pass
		{
			Name "Second"
			Blend One One
			ZWrite On
			ZTest LEqual
			Cull Back
			// Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _ColorA;
			uniform samplerCUBE _RefractTex;
			uniform samplerCUBE _ReflectTex;
			uniform float _ReflactIntensity;
			uniform float _ReflectionStrength;
			uniform float _RimPower;
			uniform float _RimScale;
			uniform float _RimBias;
			uniform float4 _RimColor;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldReflection = reflect(-ase_worldViewDir, ase_worldNormal);
				float4 texCUBENode8 = texCUBE( _ReflectTex, ase_worldReflection );
				float4 temp_output_17_0 = ( _ColorA * texCUBE( _RefractTex, ase_worldReflection ) * texCUBENode8 * _ReflactIntensity );
				float4 temp_output_20_0 = ( temp_output_17_0 + ( texCUBENode8 * _ReflectionStrength ) );
				float dotResult25 = dot( ase_worldNormal , ase_worldViewDir );
				float clampResult27 = clamp( dotResult25 , 0.0 , 1.0 );
				float saferPower29 = max( ( 1.0 - clampResult27 ) , 0.0001 );
				float temp_output_34_0 = ( ( max( pow( saferPower29 , _RimPower ) , 0.0 ) * _RimScale ) + _RimBias );
				
				
				finalColor = ( temp_output_20_0 + ( temp_output_20_0 * temp_output_34_0 * ( temp_output_34_0 * _RimColor ) ) );
				return finalColor;
			}
			ENDCG
		}
		
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18500
7;29;1522;788;561.8478;-70.78892;1.398939;True;False
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;26;-997.7262,695.9022;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;23;-996.4745,523.4851;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;25;-756.5909,547.6318;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;27;-609.0131,521.6325;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;28;-325.215,606.3607;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-45.42078,791.1124;Inherit;False;Property;_RimPower;RimPower;5;0;Create;True;0;0;False;0;False;2;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;29;-28.94593,563.6793;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldReflectionVector;18;-1006.043,-280.0109;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;33;115.3172,799.4438;Inherit;False;Property;_RimScale;RimScale;6;0;Create;True;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;31;196.7171,621.4441;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-673.1464,-267.8589;Inherit;True;Property;_RefractTex;RefractTex;2;0;Create;True;0;0;False;0;False;-1;a76f1fb008cfa5e4d99dbe4eb0193b77;a76f1fb008cfa5e4d99dbe4eb0193b77;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;5;-610.3268,-512.0953;Inherit;False;Property;_ColorA;ColorA;0;0;Create;True;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;8;-808.2221,141.883;Inherit;True;Property;_ReflectTex;ReflectTex;1;0;Create;True;0;0;False;0;False;-1;9143b80d078e6064393fa54b89803e6d;9143b80d078e6064393fa54b89803e6d;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;19;-406.0873,85.80978;Inherit;False;Property;_ReflactIntensity;ReflactIntensity;3;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-466.6164,407.0503;Inherit;False;Property;_ReflectionStrength;ReflectionStrength;4;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;347.7171,647.4441;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;359.7171,765.4441;Inherit;False;Property;_RimBias;RimBias;7;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-107.0544,290.6241;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;40;534.9206,778.6521;Inherit;False;Property;_RimColor;RimColor;8;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;34;503.9269,620.6548;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-250.2452,-194.0775;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;620.3632,204.502;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;732.1708,645.7529;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;736.488,440.4433;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;38;951.3972,475.8282;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;1312.999,344.4534;Float;False;False;-1;2;ASEMaterialInspector;100;9;New Amplify Shader;59ec7c395dbc9594f9567d96a54a1241;True;Second;0;1;Second;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;966.8135,29.7501;Float;False;True;-1;2;ASEMaterialInspector;100;9;Diamond;59ec7c395dbc9594f9567d96a54a1241;True;Unlit;0;0;Unlit;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;2;True;True;False;;False;0
WireConnection;25;0;23;0
WireConnection;25;1;26;0
WireConnection;27;0;25;0
WireConnection;28;0;27;0
WireConnection;29;0;28;0
WireConnection;29;1;30;0
WireConnection;31;0;29;0
WireConnection;7;1;18;0
WireConnection;8;1;18;0
WireConnection;32;0;31;0
WireConnection;32;1;33;0
WireConnection;22;0;8;0
WireConnection;22;1;21;0
WireConnection;34;0;32;0
WireConnection;34;1;35;0
WireConnection;17;0;5;0
WireConnection;17;1;7;0
WireConnection;17;2;8;0
WireConnection;17;3;19;0
WireConnection;20;0;17;0
WireConnection;20;1;22;0
WireConnection;39;0;34;0
WireConnection;39;1;40;0
WireConnection;37;0;20;0
WireConnection;37;1;34;0
WireConnection;37;2;39;0
WireConnection;38;0;20;0
WireConnection;38;1;37;0
WireConnection;3;0;38;0
WireConnection;2;0;17;0
ASEEND*/
//CHKSM=066A68555524A0184028EAD572C0431DEF940BCC