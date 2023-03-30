// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/RadiaBlur" {
    Properties {
        _MainTex("纹理",2D)="while"{}
        _Level("强度",Range(1,100))=10
        _CenterX("中心X坐标",Range(0,1))=0.5
        _CenterY("中心Y坐标",Range(0,1))=0.5
        _BufferRadius("缓冲半径",Range(0,1))=0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        
        Pass{
            Cull Off
            ZWrite Off
            ZTest Always
            CGPROGRAM
            #pragma vertex vert  
            #pragma fragment frag  
            
            #include "UnityCG.cginc"  
            
            sampler2D _MainTex; 
            float _Level;
            float _CenterX;
            float _CenterY;
            float _BufferRadius;

            struct v2f{
                fixed4 vertex:POSITION;
                fixed2 uv:TEXCOORD;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex=UnityObjectToClipPos(v.vertex);
                o.uv=v.texcoord;
                return o;
            } 

            fixed4 frag(v2f i):COLOR
            {
                
                fixed4 finalColor;
                fixed2 center=fixed2(_CenterX,_CenterY);
                fixed2 uv=i.uv-center;
                fixed3 tempColor=fixed3(0,0,0);
                fixed blurParams=distance(i.uv,center);

                for(fixed j=0;j<_Level;j++){
                    tempColor+=tex2D(_MainTex,uv*(1-0.01*j*saturate( blurParams/_BufferRadius))+center).rgb;
                }

                finalColor.rgb=tempColor/_Level;
                finalColor.a=1;
                return finalColor;
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}

