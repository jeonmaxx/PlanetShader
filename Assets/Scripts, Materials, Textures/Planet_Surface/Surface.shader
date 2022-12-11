Shader "Custom/Surface"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _Snow("Snow Color", Color) = (1,1,1,1)
        _Mountain("Mountain Color", Color) = (1,1,1,1)
        _Land("Land Color", Color) = (1,1,1,1)
        _Sand("Sand Color", Color) = (1,1,1,1)
        _LightWater("Light Water Color", Color) = (1,1,1,1)

        _WaterNormal("Water Normal", 2D) = "bump" {}
        _SandNormal("Land Normal", 2D) = "bump" {}

        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _Glossiness("Smoothness", Range(0,1)) = 0.5
        _Metallic("Metallic", Range(0,1)) = 0.0
        _Clip("Alpha Clip", Range(0,1)) = 0.5
        _NoiseScale("NoiseScale", float) = 0

        _MountainWidth("Mountain Width", Range(0,1)) = 0.3
        _LandWidth("Land Width", Range(0,1)) = 0.03
        _SandWidth("Sand Width", Range(0,1)) = 0.03
        _LightWaterWidth("Light Water Width", Range(0,1)) = 0.03

        _Blending("Blending", Range(0,0.05)) = 0.01
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 200
            Cull Off

            CGPROGRAM

            #pragma surface surf Standard fullforwardshadows    
            #pragma target 3.0

            #include "noiseSimplex.cginc"

            sampler2D _MainTex;
            sampler2D _WaterNormal;
            sampler2D _SandNormal;


        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
            float2 uv_WaterNormal;
            float2 uv_SandNormal;
        };

        half _Glossiness;
        half _Metallic;

        fixed4 _Color;
        fixed4 _Snow;
        fixed4 _Mountain;
        fixed4 _Land;
        fixed4 _Sand;
        fixed4 _LightWater;

        float _Clip;
        float _NoiseScale;
        float _MountainWidth;
        float _LandWidth;
        float _SandWidth;
        float _LightWaterWidth;

        float _Blending;


        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            fixed noise = snoise(IN.worldPos * _NoiseScale) * 0.625 + 0.8;
            fixed mountain = _Clip + _MountainWidth;
            fixed land = _Clip + _LandWidth;
            fixed sand = _Clip + _SandWidth;
            fixed water = _Clip + _LightWaterWidth;

            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;

            o.Normal = UnpackNormal(tex2D(_WaterNormal, IN.uv_WaterNormal));


            if (noise < _Clip)
            {
                o.Albedo = _Snow;
                o.Alpha = _Snow;
                o.Normal = UnpackNormal(tex2D(_SandNormal, IN.uv_SandNormal));
            }

            if (noise > _Clip && noise < water + _Blending)
            {
                o.Albedo = _Color + _LightWater;
            }

            if (noise > _Clip && noise < water)
            {
                o.Albedo = _LightWater;
                o.Alpha = _LightWater;
            }

            if (noise > _Clip && noise < sand)
            {
                o.Albedo = _Sand;
                o.Alpha = _Sand;
                o.Normal = UnpackNormal(tex2D(_SandNormal, IN.uv_SandNormal));
            }

            if (noise > _Clip && noise < land + _Blending)
            {
                o.Albedo = _Sand + _Land;
            }

            if (noise > _Clip && noise < land)
            {
                o.Albedo = _Land;
                o.Alpha = _Land;
            }

            if (noise > _Clip && noise < mountain + _Blending * 5)
            {
                o.Albedo = _Mountain + _Land;

            }

            if (noise > _Clip && noise < mountain)
            {
                o.Albedo = _Mountain;
                o.Alpha = _Mountain;
            }

        }
        ENDCG
        }
        FallBack "Diffuse"
}
