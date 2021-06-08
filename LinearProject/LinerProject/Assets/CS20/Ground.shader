// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Ground"
{
	Properties
	{
		_Albedo("Albedo", 2D) = "white" {}
		_Height("Height", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalIntensity("NormalIntensity", Float) = 1
		_RoughnessMap("RoughnessMap", 2D) = "white" {}
		_RoughnessMax("RoughnessMax", Range( 0 , 1)) = 0
		_RoughnessMin("RoughnessMin", Range( 0 , 1)) = 0
		_AOMap("AOMap", 2D) = "white" {}
		_Tilling("Tilling", Float) = 1
		_POMScale("POMScale", Range( -0.5 , 0.5)) = 0
		_POMPlane("POMPlane", Float) = 0
		_BlendContrast("BlendContrast", Range( 0 , 1)) = 0
		_PudlleColor("PudlleColor", Color) = (0,0,0,0)
		_PuddleDepth("PuddleDepth", Range( 0 , 1)) = 0
		_WaterRoughness("WaterRoughness", Range( 0 , 0.1)) = 0
		_WaterNormal("WaterNormal", 2D) = "bump" {}
		_WaveTilling("WaveTilling", Float) = 1
		_WaveSpeed("WaveSpeed", Vector) = (1,1,0,0)
		_WaveIntensity("WaveIntensity", Range( 0 , 1)) = 0
		_RainDrop("RainDrop", 2D) = "bump" {}
		_RainIntensity("RainIntensity", Float) = 1
		_RainDropTilling("RainDropTilling", Float) = 1
		_Columns("Columns", Float) = 8
		_RainDropSpeed("RainDropSpeed", Float) = 25
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
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
			float3 viewDir;
			INTERNAL_DATA
			float3 worldNormal;
			float4 vertexColor : COLOR;
		};

		uniform sampler2D _NormalMap;
		uniform float _Tilling;
		uniform sampler2D _Height;
		uniform float _POMScale;
		uniform float _POMPlane;
		uniform float4 _Height_ST;
		uniform float _NormalIntensity;
		uniform sampler2D _WaterNormal;
		uniform float _WaveTilling;
		uniform float2 _WaveSpeed;
		uniform float _WaveIntensity;
		uniform sampler2D _RainDrop;
		uniform float _RainDropTilling;
		uniform float _Columns;
		uniform float _RainDropSpeed;
		uniform float _RainIntensity;
		uniform float _BlendContrast;
		uniform sampler2D _Albedo;
		uniform float4 _PudlleColor;
		uniform float _PuddleDepth;
		uniform float _RoughnessMin;
		uniform float _RoughnessMax;
		uniform sampler2D _RoughnessMap;
		uniform float _WaterRoughness;
		uniform sampler2D _AOMap;


		inline float2 POM( sampler2D heightMap, float2 uvs, float2 dx, float2 dy, float3 normalWorld, float3 viewWorld, float3 viewDirTan, int minSamples, int maxSamples, float parallax, float refPlane, float2 tilling, float2 curv, int index )
		{
			float3 result = 0;
			int stepIndex = 0;
			int numSteps = ( int )lerp( (float)maxSamples, (float)minSamples, saturate( dot( normalWorld, viewWorld ) ) );
			float layerHeight = 1.0 / numSteps;
			float2 plane = parallax * ( viewDirTan.xy / viewDirTan.z );
			uvs.xy += refPlane * plane;
			float2 deltaTex = -plane * layerHeight;
			float2 prevTexOffset = 0;
			float prevRayZ = 1.0f;
			float prevHeight = 0.0f;
			float2 currTexOffset = deltaTex;
			float currRayZ = 1.0f - layerHeight;
			float currHeight = 0.0f;
			float intersection = 0;
			float2 finalTexOffset = 0;
			while ( stepIndex < numSteps + 1 )
			{
			 	currHeight = tex2Dgrad( heightMap, uvs + currTexOffset, dx, dy ).r;
			 	if ( currHeight > currRayZ )
			 	{
			 	 	stepIndex = numSteps + 1;
			 	}
			 	else
			 	{
			 	 	stepIndex++;
			 	 	prevTexOffset = currTexOffset;
			 	 	prevRayZ = currRayZ;
			 	 	prevHeight = currHeight;
			 	 	currTexOffset += deltaTex;
			 	 	currRayZ -= layerHeight;
			 	}
			}
			int sectionSteps = 6;
			int sectionIndex = 0;
			float newZ = 0;
			float newHeight = 0;
			while ( sectionIndex < sectionSteps )
			{
			 	intersection = ( prevHeight - prevRayZ ) / ( prevHeight - currHeight + currRayZ - prevRayZ );
			 	finalTexOffset = prevTexOffset + intersection * deltaTex;
			 	newZ = prevRayZ - intersection * layerHeight;
			 	newHeight = tex2Dgrad( heightMap, uvs + finalTexOffset, dx, dy ).r;
			 	if ( newHeight > newZ )
			 	{
			 	 	currTexOffset = finalTexOffset;
			 	 	currHeight = newHeight;
			 	 	currRayZ = newZ;
			 	 	deltaTex = intersection * deltaTex;
			 	 	layerHeight = intersection * layerHeight;
			 	}
			 	else
			 	{
			 	 	prevTexOffset = finalTexOffset;
			 	 	prevHeight = newHeight;
			 	 	prevRayZ = newZ;
			 	 	deltaTex = ( 1 - intersection ) * deltaTex;
			 	 	layerHeight = ( 1 - intersection ) * layerHeight;
			 	}
			 	sectionIndex++;
			}
			return uvs.xy + finalTexOffset;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 OffsetPOM32 = POM( _Height, ( (ase_worldPos).xz * _Tilling ), ddx(( (ase_worldPos).xz * _Tilling )), ddy(( (ase_worldPos).xz * _Tilling )), ase_worldNormal, ase_worldViewDir, i.viewDir, 8, 8, ( _POMScale * 0.1 ), ( _POMPlane + ( i.vertexColor.b - 1.0 ) ), _Height_ST.xy, float2(0,0), 0 );
			float2 WorldUV17 = OffsetPOM32;
			float2 temp_output_75_0 = ( (ase_worldPos).xz * _WaveTilling );
			float2 temp_output_79_0 = ( _WaveSpeed * _Time.y * 0.1 );
			float3 lerpResult90 = lerp( float3(0,0,1) , BlendNormals( UnpackNormal( tex2D( _WaterNormal, ( temp_output_75_0 + temp_output_79_0 ) ) ) , UnpackNormal( tex2D( _WaterNormal, ( ( temp_output_75_0 * 2.0 ) + ( temp_output_79_0 * -0.5 ) ) ) ) ) , _WaveIntensity);
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles98 = _Columns * _Columns;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset98 = 1.0f / _Columns;
			float fbrowsoffset98 = 1.0f / _Columns;
			// Speed of animation
			float fbspeed98 = _Time[ 1 ] * _RainDropSpeed;
			// UV Tiling (col and row offset)
			float2 fbtiling98 = float2(fbcolsoffset98, fbrowsoffset98);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex98 = round( fmod( fbspeed98 + 0.0, fbtotaltiles98) );
			fbcurrenttileindex98 += ( fbcurrenttileindex98 < 0) ? fbtotaltiles98 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox98 = round ( fmod ( fbcurrenttileindex98, _Columns ) );
			// Multiply Offset X by coloffset
			float fboffsetx98 = fblinearindextox98 * fbcolsoffset98;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy98 = round( fmod( ( fbcurrenttileindex98 - fblinearindextox98 ) / _Columns, _Columns ) );
			// Reverse Y to get tiles from Top to Bottom
			fblinearindextoy98 = (int)(_Columns-1) - fblinearindextoy98;
			// Multiply Offset Y by rowoffset
			float fboffsety98 = fblinearindextoy98 * fbrowsoffset98;
			// UV Offset
			float2 fboffset98 = float2(fboffsetx98, fboffsety98);
			// Flipbook UV
			half2 fbuv98 = frac( ( (ase_worldPos).xz * _RainDropTilling ) ) * fbtiling98 + fboffset98;
			// *** END Flipbook UV Animation vars ***
			float3 PuddleNormal88 = BlendNormals( lerpResult90 , UnpackScaleNormal( tex2D( _RainDrop, fbuv98 ), _RainIntensity ) );
			float temp_output_10_0_g12 = _BlendContrast;
			float4 tex2DNode47 = tex2D( _Height, WorldUV17 );
			float clampResult8_g12 = clamp( ( ( tex2DNode47.r - 1.0 ) + ( i.vertexColor.b * 2.0 ) ) , 0.0 , 1.0 );
			float lerpResult12_g12 = lerp( ( 0.0 - temp_output_10_0_g12 ) , ( temp_output_10_0_g12 + 1.0 ) , clampResult8_g12);
			float clampResult13_g12 = clamp( lerpResult12_g12 , 0.0 , 1.0 );
			float BChannelLerp51 = clampResult13_g12;
			float3 lerpResult65 = lerp( UnpackScaleNormal( tex2D( _NormalMap, WorldUV17 ), _NormalIntensity ) , PuddleNormal88 , ( 1.0 - BChannelLerp51 ));
			float3 Normal22 = lerpResult65;
			o.Normal = Normal22;
			float4 tex2DNode1 = tex2D( _Albedo, WorldUV17 );
			float4 lerpResult52 = lerp( tex2DNode1 , _PudlleColor , _PuddleDepth);
			float temp_output_10_0_g13 = _BlendContrast;
			float clampResult8_g13 = clamp( ( ( tex2DNode47.r - 1.0 ) + ( i.vertexColor.r * 2.0 ) ) , 0.0 , 1.0 );
			float lerpResult12_g13 = lerp( ( 0.0 - temp_output_10_0_g13 ) , ( temp_output_10_0_g13 + 1.0 ) , clampResult8_g13);
			float clampResult13_g13 = clamp( lerpResult12_g13 , 0.0 , 1.0 );
			float RChannelLerp49 = clampResult13_g13;
			float4 lerpResult55 = lerp( tex2DNode1 , lerpResult52 , ( 1.0 - RChannelLerp49 ));
			float4 BaseColor21 = lerpResult55;
			o.Albedo = BaseColor21.rgb;
			o.Metallic = 0.0;
			float lerpResult11 = lerp( _RoughnessMin , _RoughnessMax , tex2D( _RoughnessMap, WorldUV17 ).r);
			float lerpResult70 = lerp( _WaterRoughness , 0.1 , BChannelLerp51);
			float temp_output_10_0_g11 = _BlendContrast;
			float clampResult8_g11 = clamp( ( ( tex2DNode47.r - 1.0 ) + ( i.vertexColor.g * 2.0 ) ) , 0.0 , 1.0 );
			float lerpResult12_g11 = lerp( ( 0.0 - temp_output_10_0_g11 ) , ( temp_output_10_0_g11 + 1.0 ) , clampResult8_g11);
			float clampResult13_g11 = clamp( lerpResult12_g11 , 0.0 , 1.0 );
			float GChannelLerp50 = clampResult13_g11;
			float lerpResult60 = lerp( lerpResult11 , lerpResult70 , ( 1.0 - GChannelLerp50 ));
			float Roughness24 = lerpResult60;
			o.Smoothness = ( 1.0 - Roughness24 );
			float AO23 = tex2D( _AOMap, WorldUV17 ).r;
			o.Occlusion = AO23;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

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
				float4 tSpace0 : TEXCOORD1;
				float4 tSpace1 : TEXCOORD2;
				float4 tSpace2 : TEXCOORD3;
				half4 color : COLOR0;
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
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
7;29;1522;788;3068.44;345.0254;1.307056;True;False
Node;AmplifyShaderEditor.CommentaryNode;18;-2472.842,-533.0096;Inherit;False;1251.415;1093.107;WorldUV;15;38;17;32;33;36;37;35;34;9;8;10;7;108;109;110;WorldUV;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;108;-1945.986,386.0046;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;7;-2422.842,-483.0096;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;89;-3692.6,1784.108;Inherit;False;2883.465;1555.568;PuddleNormal;32;100;90;99;97;98;88;87;91;92;72;73;77;84;82;85;79;83;86;75;78;80;76;96;81;95;101;102;103;104;105;106;107;PuddleNormal;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-2203.044,81.66383;Inherit;False;Constant;_Float1;Float 1;9;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-2331.044,-6.336264;Inherit;False;Property;_POMScale;POMScale;9;0;Create;True;0;0;False;0;False;0;-0.2;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;109;-1767.737,414.2021;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;95;-3489.505,1839.281;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;8;-2184.522,-366.3412;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-2203.022,-275.269;Inherit;False;Property;_Tilling;Tilling;8;0;Create;True;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-1980.764,309.3137;Inherit;False;Property;_POMPlane;POMPlane;10;0;Create;True;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-1975.021,-340.2689;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;33;-2434.818,298.2067;Inherit;True;Property;_Height;Height;1;0;Create;True;0;0;False;0;False;None;e866cf37fd59e054081a2e811698704d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SwizzleNode;96;-3221.494,1862.917;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-2036.043,-3.336168;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;80;-3351.629,2493.908;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-3123.328,2005.108;Inherit;False;Property;_WaveTilling;WaveTilling;16;0;Create;True;0;0;False;0;False;1;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;78;-3321.629,2317.908;Inherit;False;Property;_WaveSpeed;WaveSpeed;17;0;Create;True;0;0;False;0;False;1,1;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;37;-2030.088,136.6946;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;81;-3319.629,2587.908;Inherit;False;Constant;_Float2;Float 2;18;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;110;-1676.095,301.4117;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxOcclusionMappingNode;32;-1756.034,-90.7153;Inherit;False;0;8;False;-1;16;False;-1;6;0.02;0;False;1,1;False;0,0;7;0;FLOAT2;0,0;False;1;SAMPLER2D;;False;2;FLOAT;0.02;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT2;0,0;False;6;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-2962.511,2209.674;Inherit;False;Constant;_Float3;Float 3;18;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;101;-3566.721,2692.593;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-3139.629,2375.908;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-2932.328,1931.108;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-2953.411,2550.275;Inherit;False;Constant;_Float4;Float 4;18;0;Create;True;0;0;False;0;False;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-3419.721,2841.593;Inherit;False;Property;_RainDropTilling;RainDropTilling;21;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;-1496.433,-96.54652;Inherit;False;WorldUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;48;-2544.649,662.8112;Inherit;False;1230.271;742.0634;BlendFactor;10;42;47;44;43;41;39;45;49;50;51;BlendFactor;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-2766.211,2447.574;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;102;-3367.831,2698.213;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-2753.012,2183.673;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;84;-2562.111,2305.874;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-2734.328,2024.108;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;-2494.649,712.8112;Inherit;False;17;WorldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-3215.211,2710.452;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-3169.31,2882.509;Inherit;False;Property;_RainDropSpeed;RainDropSpeed;23;0;Create;True;0;0;False;0;False;25;25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;105;-3060.59,2719.998;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-3158.31,2800.509;Inherit;False;Property;_Columns;Columns;22;0;Create;True;0;0;False;0;False;8;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;39;-2481.159,1047.038;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;47;-2285.675,768.9249;Inherit;True;Property;_TextureSample0;Texture Sample 0;11;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;72;-2371.309,1898.471;Inherit;True;Property;_WaterNormal;WaterNormal;15;0;Create;True;0;0;False;0;False;-1;None;922f535b90b89af4ab8a2658b6a31c3f;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;73;-2364.928,2248.108;Inherit;True;Property;_WaterNormal1;WaterNormal;15;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Instance;72;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;42;-2481.277,1252.691;Inherit;False;Property;_BlendContrast;BlendContrast;11;0;Create;True;0;0;False;0;False;0;0.34;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;98;-2801.731,2696.181;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;92;-2137.012,2456.666;Inherit;False;Property;_WaveIntensity;WaveIntensity;18;0;Create;True;0;0;False;0;False;0;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;91;-2039.512,2073.166;Inherit;False;Constant;_Vector1;Vector 1;18;0;Create;True;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;43;-1918.801,1100.173;Inherit;False;HeightLerp;-1;;11;a8ba8fadb96f68b49910512cf434e486;0;3;1;FLOAT;0;False;5;FLOAT;0;False;10;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;87;-2056.911,2255.475;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;63;-1128.996,1119.485;Inherit;False;1742.92;558.6622;Roughness;12;30;13;59;3;12;61;11;60;24;69;70;71;Roughness;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;99;-2717.911,2890.53;Inherit;False;Property;_RainIntensity;RainIntensity;20;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;44;-1911.801,1224.173;Inherit;False;HeightLerp;-1;;12;a8ba8fadb96f68b49910512cf434e486;0;3;1;FLOAT;0;False;5;FLOAT;0;False;10;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;97;-2422.624,2693.907;Inherit;True;Property;_RainDrop;RainDrop;19;0;Create;True;0;0;False;0;False;-1;None;a0f55a97801096747b82a50c148635c2;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;50;-1614,1146.883;Inherit;False;GChannelLerp;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-1078.996,1250.494;Inherit;False;17;WorldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;41;-1918.801,963.8557;Inherit;False;HeightLerp;-1;;13;a8ba8fadb96f68b49910512cf434e486;0;3;1;FLOAT;0;False;5;FLOAT;0;False;10;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;90;-1812.767,2253.714;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-1605.742,1270.752;Inherit;False;BChannelLerp;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;58;-1125.146,-567.4202;Inherit;False;1402.376;505.37;BaseColor;9;19;1;21;53;54;52;56;57;55;BaseColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;-604.8823,1545.87;Inherit;False;51;BChannelLerp;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;68;-1119.994,-8.358879;Inherit;False;1611.606;575.6407;Normal;8;64;14;20;66;2;65;22;94;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;59;-392.0924,1563.147;Inherit;False;50;GChannelLerp;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-801.1433,1466.652;Inherit;False;Property;_WaterRoughness;WaterRoughness;14;0;Create;True;0;0;False;0;False;0;0.01;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;100;-1580.689,2523.193;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-534.1769,1169.485;Inherit;False;Property;_RoughnessMin;RoughnessMin;6;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;19;-1075.146,-461.8051;Inherit;False;17;WorldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-1628.156,1004.138;Inherit;False;RChannelLerp;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-862.4755,1276.505;Inherit;True;Property;_RoughnessMap;RoughnessMap;4;0;Create;True;0;0;False;0;False;-1;None;e51a6a89a9bd66b48aff154a21f226f6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;13;-550.7415,1252.19;Inherit;False;Property;_RoughnessMax;RoughnessMax;5;0;Create;True;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-714.0455,-228.9281;Inherit;False;Property;_PuddleDepth;PuddleDepth;13;0;Create;True;0;0;False;0;False;0;0.8;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;70;-315.8823,1402.87;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;88;-1210.481,2443.05;Inherit;False;PuddleNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;53;-923.3456,-296.5282;Inherit;False;Property;_PudlleColor;PudlleColor;12;0;Create;True;0;0;False;0;False;0,0,0,0;0.1764705,0.1385812,0.08174733,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;20;-993.6048,41.64112;Inherit;False;17;WorldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;11;-252.4541,1267.242;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;61;-144.713,1540.657;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-854.2845,-487.4647;Inherit;True;Property;_Albedo;Albedo;0;0;Create;True;0;0;False;0;False;-1;None;7d6dd1320c879384885322f7afab127d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;56;-456.851,-201.5802;Inherit;False;49;RChannelLerp;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1069.994,151.4806;Inherit;False;Property;_NormalIntensity;NormalIntensity;3;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-743.2612,449.7747;Inherit;False;51;BChannelLerp;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-782.1249,89.09;Inherit;True;Property;_NormalMap;NormalMap;2;0;Create;True;0;0;False;0;False;-1;None;8134ba8067ee4814dafa7435950e77b1;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;66;-514.2964,440.382;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;57;-227.4327,-172.0502;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;60;31.89366,1358.826;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-503.1644,2063.534;Inherit;False;17;WorldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;-693.1215,291.2471;Inherit;False;88;PuddleNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;52;-456.6928,-355.8747;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;4;-249.1444,2077.599;Inherit;True;Property;_AOMap;AOMap;7;0;Create;True;0;0;False;0;False;-1;None;298ced51408aa0342bf1e291b210e59a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;370.9245,1276.943;Inherit;False;Roughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;65;-331.247,229.5957;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;55;-111.8299,-394.0351;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;34.22971,-517.4202;Inherit;False;BaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;83.06302,2149.811;Inherit;False;AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;650.8645,106.512;Inherit;False;24;Roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;248.6121,126.3523;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;893.1689,3.511993;Inherit;False;22;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;28;878.8049,242.1898;Inherit;False;23;AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;945.3107,75.55496;Inherit;False;Constant;_Float0;Float 0;9;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;917.1689,-81.48801;Inherit;False;21;BaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;6;909.6701,155.3289;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1160.459,-20.55583;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Ground;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;109;0;108;3
WireConnection;8;0;7;0
WireConnection;9;0;8;0
WireConnection;9;1;10;0
WireConnection;96;0;95;0
WireConnection;35;0;34;0
WireConnection;35;1;36;0
WireConnection;110;0;38;0
WireConnection;110;1;109;0
WireConnection;32;0;9;0
WireConnection;32;1;33;0
WireConnection;32;2;35;0
WireConnection;32;3;37;0
WireConnection;32;4;110;0
WireConnection;79;0;78;0
WireConnection;79;1;80;0
WireConnection;79;2;81;0
WireConnection;75;0;96;0
WireConnection;75;1;76;0
WireConnection;17;0;32;0
WireConnection;85;0;79;0
WireConnection;85;1;86;0
WireConnection;102;0;101;0
WireConnection;82;0;75;0
WireConnection;82;1;83;0
WireConnection;84;0;82;0
WireConnection;84;1;85;0
WireConnection;77;0;75;0
WireConnection;77;1;79;0
WireConnection;103;0;102;0
WireConnection;103;1;104;0
WireConnection;105;0;103;0
WireConnection;47;0;33;0
WireConnection;47;1;45;0
WireConnection;72;1;77;0
WireConnection;73;1;84;0
WireConnection;98;0;105;0
WireConnection;98;1;106;0
WireConnection;98;2;106;0
WireConnection;98;3;107;0
WireConnection;43;1;47;1
WireConnection;43;5;39;2
WireConnection;43;10;42;0
WireConnection;87;0;72;0
WireConnection;87;1;73;0
WireConnection;44;1;47;1
WireConnection;44;5;39;3
WireConnection;44;10;42;0
WireConnection;97;1;98;0
WireConnection;97;5;99;0
WireConnection;50;0;43;0
WireConnection;41;1;47;1
WireConnection;41;5;39;1
WireConnection;41;10;42;0
WireConnection;90;0;91;0
WireConnection;90;1;87;0
WireConnection;90;2;92;0
WireConnection;51;0;44;0
WireConnection;100;0;90;0
WireConnection;100;1;97;0
WireConnection;49;0;41;0
WireConnection;3;1;30;0
WireConnection;70;0;71;0
WireConnection;70;2;69;0
WireConnection;88;0;100;0
WireConnection;11;0;12;0
WireConnection;11;1;13;0
WireConnection;11;2;3;1
WireConnection;61;0;59;0
WireConnection;1;1;19;0
WireConnection;2;1;20;0
WireConnection;2;5;14;0
WireConnection;66;0;64;0
WireConnection;57;0;56;0
WireConnection;60;0;11;0
WireConnection;60;1;70;0
WireConnection;60;2;61;0
WireConnection;52;0;1;0
WireConnection;52;1;53;0
WireConnection;52;2;54;0
WireConnection;4;1;31;0
WireConnection;24;0;60;0
WireConnection;65;0;2;0
WireConnection;65;1;94;0
WireConnection;65;2;66;0
WireConnection;55;0;1;0
WireConnection;55;1;52;0
WireConnection;55;2;57;0
WireConnection;21;0;55;0
WireConnection;23;0;4;1
WireConnection;22;0;65;0
WireConnection;6;0;27;0
WireConnection;0;0;25;0
WireConnection;0;1;26;0
WireConnection;0;3;29;0
WireConnection;0;4;6;0
WireConnection;0;5;28;0
ASEEND*/
//CHKSM=06D1348F3808771099209B7F67AB39D7FD883789