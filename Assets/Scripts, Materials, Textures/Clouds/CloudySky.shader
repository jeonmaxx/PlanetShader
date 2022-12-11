Shader "Unlit/CloudySky"
{
    Properties
    {
       [HDR] _Color("Color", Color) = (1,1,1,1)
        _MainTex("Noise Texture", 2D) = "white" {}

        _CloudScale("CloudScale", Range(-2, 5)) = 1
        _CloudsPower("CloudsPower", Float) = 1

        _ScrollXSpeed("Speed X", Range(-5,5)) = 2
        _ScrollYSpeed("Speed Y", Range(-5,5)) = 3

        _DistortScale("DistortScale", Range(-2, 5)) = 1
        _DistortXSpeed("DistortSpeed X", Range(-5,5)) = 2
        _DistortYSpeed("DistortSpeed Y", Range(-5,5)) = 3
    }
    SubShader
    {
        Tags { "QUEUE" = "Transparent" "RenderType" = "Transparent" "ForceNoShadowCasting" = "True" }
        LOD 100
        ZWrite Off
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag            

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _Color;

            float _CloudScale;
            fixed _ScrollXSpeed;
            fixed _ScrollYSpeed;

            float _DistortScale;
            fixed _DistortXSpeed;
            fixed _DistortYSpeed;

            float _CloudsPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);   
                o.color.rgb = _Color.rgb;
                o.color.a = _Color.a;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                fixed2 scrolledUV = (i.uv * _CloudScale);
                fixed2 distortedUV = (i.uv * _DistortScale);

                fixed xScrollValue = _ScrollXSpeed * _Time;
                fixed yScrollValue = _ScrollYSpeed * _Time;
                scrolledUV += fixed2(xScrollValue, yScrollValue);

                fixed xDistortValue = _DistortXSpeed * _Time;
                fixed yDistortValue = _DistortYSpeed * _Time;
                distortedUV += fixed2(xDistortValue, yDistortValue);

                
                half4 col = tex2D(_MainTex, scrolledUV)* tex2D(_MainTex, distortedUV);
                //col *= tex2D(_MainTex, distortedUV) ;
                col.a = _Color.a;
                col = pow(_CloudsPower, col) * (_Color);
               
                return col;
            }
            ENDCG
        }
    }
}
