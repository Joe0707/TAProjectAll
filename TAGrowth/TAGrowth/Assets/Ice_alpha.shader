// Shader created with Shader Forge v1.40 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.40;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,cpap:True,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:4013,x:33960,y:32762,varname:node_4013,prsc:2|spec-3637-OUT,gloss-3202-OUT,emission-5276-OUT,alpha-2081-OUT,refract-5801-OUT;n:type:ShaderForge.SFN_Tex2d,id:3239,x:32267,y:32593,ptovrint:False,ptlb:tex1,ptin:_tex1,varname:node_3239,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:222,x:32483,y:32728,varname:node_222,prsc:2|A-3239-RGB,B-423-RGB;n:type:ShaderForge.SFN_Color,id:423,x:32267,y:32793,ptovrint:False,ptlb:tex1_color,ptin:_tex1_color,varname:node_423,prsc:2,glob:False,taghide:False,taghdr:True,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_ValueProperty,id:3637,x:33050,y:32668,ptovrint:False,ptlb:specular,ptin:_specular,varname:node_3637,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:3202,x:33050,y:32742,ptovrint:False,ptlb:gloss,ptin:_gloss,varname:node_3202,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Fresnel,id:2279,x:32267,y:32978,varname:node_2279,prsc:2|EXP-2127-OUT;n:type:ShaderForge.SFN_Multiply,id:543,x:32463,y:33027,varname:node_543,prsc:2|A-2279-OUT,B-6543-RGB;n:type:ShaderForge.SFN_ValueProperty,id:2127,x:32043,y:33043,ptovrint:False,ptlb:fresnel_v,ptin:_fresnel_v,varname:node_2127,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Color,id:6543,x:32267,y:33164,ptovrint:False,ptlb:fresnel_color,ptin:_fresnel_color,varname:node_6543,prsc:2,glob:False,taghide:False,taghdr:True,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Add,id:5276,x:32681,y:32895,varname:node_5276,prsc:2|A-222-OUT,B-543-OUT,C-9852-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2081,x:33287,y:32997,ptovrint:False,ptlb:opacity,ptin:_opacity,varname:node_2081,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Tex2d,id:8289,x:32687,y:33202,ptovrint:False,ptlb:zheshe_tex,ptin:_zheshe_tex,varname:node_8289,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Append,id:3615,x:32924,y:33219,varname:node_3615,prsc:2|A-8289-R,B-8289-G;n:type:ShaderForge.SFN_Multiply,id:5801,x:33123,y:33242,varname:node_5801,prsc:2|A-3615-OUT,B-1388-OUT;n:type:ShaderForge.SFN_ValueProperty,id:1388,x:32924,y:33400,ptovrint:False,ptlb:zheshe_v,ptin:_zheshe_v,varname:node_1388,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Cubemap,id:6271,x:32267,y:33365,ptovrint:False,ptlb:node_6271,ptin:_node_6271,varname:node_6271,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,pvfc:0;n:type:ShaderForge.SFN_Multiply,id:9852,x:32472,y:33412,varname:node_9852,prsc:2|A-6271-RGB,B-6783-OUT;n:type:ShaderForge.SFN_ValueProperty,id:6783,x:32267,y:33544,ptovrint:False,ptlb:cubemap_v,ptin:_cubemap_v,varname:node_6783,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;proporder:3239-423-3637-3202-2127-6543-6271-6783-2081-8289-1388;pass:END;sub:END;*/

Shader "Custom/eff/Ice_alpha02" {
    Properties {
        _tex1 ("tex1", 2D) = "white" {}
        [HDR]_tex1_color ("tex1_color", Color) = (0.5,0.5,0.5,1)
        _specular ("specular", Float ) = 0
        _gloss ("gloss", Float ) = 0
        _fresnel_v ("fresnel_v", Float ) = 1
        [HDR]_fresnel_color ("fresnel_color", Color) = (0.5,0.5,0.5,1)
        _node_6271 ("node_6271", Cube) = "_Skybox" {}
        _cubemap_v ("cubemap_v", Float ) = 0
        _opacity ("opacity", Float ) = 0
        _zheshe_tex ("zheshe_tex", 2D) = "white" {}
        _zheshe_v ("zheshe_v", Float ) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
        _DissolveTex("Dissolve Tex (R)",2D) = "white" {}
        _DissolveIntensity("Dissolve Intensity",float) = 1
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        GrabPass{ }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform sampler2D _GrabTexture;
            uniform sampler2D _tex1; uniform float4 _tex1_ST;
            uniform sampler2D _zheshe_tex; uniform float4 _zheshe_tex_ST;
            uniform samplerCUBE _node_6271;
            uniform sampler2D _DissolveTex;
            float _DissolveIntensity;
            UNITY_INSTANCING_BUFFER_START( Props )
            UNITY_DEFINE_INSTANCED_PROP( float4, _tex1_color)
            UNITY_DEFINE_INSTANCED_PROP( float, _specular)
            UNITY_DEFINE_INSTANCED_PROP( float, _gloss)
            UNITY_DEFINE_INSTANCED_PROP( float, _fresnel_v)
            UNITY_DEFINE_INSTANCED_PROP( float4, _fresnel_color)
            UNITY_DEFINE_INSTANCED_PROP( float, _opacity)
            UNITY_DEFINE_INSTANCED_PROP( float, _zheshe_v)
            UNITY_DEFINE_INSTANCED_PROP( float, _cubemap_v)
            UNITY_INSTANCING_BUFFER_END( Props )
            struct VertexInput {
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float4 projPos : TEXCOORD3;
                UNITY_FOG_COORDS(4)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID( v );
                UNITY_TRANSFER_INSTANCE_ID( v, o );
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                UNITY_SETUP_INSTANCE_ID( i );
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
                float4 _zheshe_tex_var = tex2D(_zheshe_tex,TRANSFORM_TEX(i.uv0, _zheshe_tex));
                float _zheshe_v_var = UNITY_ACCESS_INSTANCED_PROP( Props, _zheshe_v );
                float2 sceneUVs = (i.projPos.xy / i.projPos.w) + (float2(_zheshe_tex_var.r,_zheshe_tex_var.g)*_zheshe_v_var);
                float4 sceneColor = tex2D(_GrabTexture, sceneUVs);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
                ////// Lighting:
                float attenuation = 1;
                float3 attenColor = attenuation * _LightColor0.xyz;
                ///////// Gloss:
                float _gloss_var = UNITY_ACCESS_INSTANCED_PROP( Props, _gloss );
                float gloss = _gloss_var;
                float specPow = exp2( gloss * 10.0 + 1.0 );
                ////// Specular:
                float NdotL = saturate(dot( normalDirection, lightDirection ));
                float _specular_var = UNITY_ACCESS_INSTANCED_PROP( Props, _specular );
                float3 specularColor = float3(_specular_var,_specular_var,_specular_var);
                float3 directSpecular = attenColor * pow(max(0,dot(halfDirection,normalDirection)),specPow)*specularColor;
                float3 specular = directSpecular;
                ////// Emissive:
                float4 _tex1_var = tex2D(_tex1,TRANSFORM_TEX(i.uv0, _tex1));
                float4 _tex1_color_var = UNITY_ACCESS_INSTANCED_PROP( Props, _tex1_color );
                float _fresnel_v_var = UNITY_ACCESS_INSTANCED_PROP( Props, _fresnel_v );
                float4 _fresnel_color_var = UNITY_ACCESS_INSTANCED_PROP( Props, _fresnel_color );
                float _cubemap_v_var = UNITY_ACCESS_INSTANCED_PROP( Props, _cubemap_v );
                float3 emissive = ((_tex1_var.rgb*_tex1_color_var.rgb)+(pow(1.0-max(0,dot(normalDirection, viewDirection)),_fresnel_v_var)*_fresnel_color_var.rgb)+(texCUBE(_node_6271,viewReflectDirection).rgb*_cubemap_v_var));
                /// Final Color:
                float3 finalColor = specular + emissive;
                float _opacity_var = UNITY_ACCESS_INSTANCED_PROP( Props, _opacity );
                fixed4 finalRGBA = fixed4(lerp(sceneColor.rgb, finalColor,_opacity_var),1);
                fixed4 dissolveTex = tex2D(_DissolveTex, i.uv0);
                // clip(dissolveTex.r-_Time.y*_DissolveIntensity);
                clip(tex2D( _DissolveTex, i.uv0 )  - _DissolveIntensity);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdadd
            #pragma multi_compile_fog
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform sampler2D _GrabTexture;
            uniform sampler2D _tex1; uniform float4 _tex1_ST;
            uniform sampler2D _zheshe_tex; uniform float4 _zheshe_tex_ST;
            uniform samplerCUBE _node_6271;
            uniform sampler2D _DissolveTex;
            float _DissolveIntensity;
            UNITY_INSTANCING_BUFFER_START( Props )
            UNITY_DEFINE_INSTANCED_PROP( float4, _tex1_color)
            UNITY_DEFINE_INSTANCED_PROP( float, _specular)
            UNITY_DEFINE_INSTANCED_PROP( float, _gloss)
            UNITY_DEFINE_INSTANCED_PROP( float, _fresnel_v)
            UNITY_DEFINE_INSTANCED_PROP( float4, _fresnel_color)
            UNITY_DEFINE_INSTANCED_PROP( float, _opacity)
            UNITY_DEFINE_INSTANCED_PROP( float, _zheshe_v)
            UNITY_DEFINE_INSTANCED_PROP( float, _cubemap_v)
            UNITY_INSTANCING_BUFFER_END( Props )
            struct VertexInput {
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float4 projPos : TEXCOORD3;
                LIGHTING_COORDS(4,5)
                UNITY_FOG_COORDS(6)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID( v );
                UNITY_TRANSFER_INSTANCE_ID( v, o );
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                UNITY_SETUP_INSTANCE_ID( i );
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
                float4 _zheshe_tex_var = tex2D(_zheshe_tex,TRANSFORM_TEX(i.uv0, _zheshe_tex));
                float _zheshe_v_var = UNITY_ACCESS_INSTANCED_PROP( Props, _zheshe_v );
                float2 sceneUVs = (i.projPos.xy / i.projPos.w) + (float2(_zheshe_tex_var.r,_zheshe_tex_var.g)*_zheshe_v_var);
                float4 sceneColor = tex2D(_GrabTexture, sceneUVs);
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
                ////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
                ///////// Gloss:
                float _gloss_var = UNITY_ACCESS_INSTANCED_PROP( Props, _gloss );
                float gloss = _gloss_var;
                float specPow = exp2( gloss * 10.0 + 1.0 );
                ////// Specular:
                float NdotL = saturate(dot( normalDirection, lightDirection ));
                float _specular_var = UNITY_ACCESS_INSTANCED_PROP( Props, _specular );
                float3 specularColor = float3(_specular_var,_specular_var,_specular_var);
                float3 directSpecular = attenColor * pow(max(0,dot(halfDirection,normalDirection)),specPow)*specularColor;
                float3 specular = directSpecular;
                /// Final Color:
                float3 finalColor = specular;
                float _opacity_var = UNITY_ACCESS_INSTANCED_PROP( Props, _opacity );
                fixed4 finalRGBA = fixed4(finalColor * _opacity_var,0);
                clip(tex2D( _DissolveTex, i.uv0 )  - _DissolveIntensity);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_fog
            #pragma target 3.0
            struct VertexInput {
                float4 vertex : POSITION;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
