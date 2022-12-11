Shader "Custom/Atmosphere"
{
	Properties
	{
		[HDR] _Color("Color", Color) = (1,0,0,1)
		_EdgeEnhancement("Edge Enhancement", float) = 1.0

	}

		SubShader
	{
		Tags {"Queue" = "Transparent"
			  "RenderType" = "Transparent"}

		Pass 
		{
			ZWrite Off 
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float4 _Color;
			float _EdgeEnhancement;

			struct vertexInput
			{
				float4 vertexPos : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertexPos : SV_POSITION;
				float3 normal : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
			}; 

			v2f vert(vertexInput input)
			{
				v2f output;
				output.vertexPos = UnityObjectToClipPos(input.vertexPos);
				output.normal = normalize(mul(float4(input.normal, 0.0), unity_WorldToObject)).xyz;
				output.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, input.vertexPos)).xyz;
				return output;
			}

			float4 frag(v2f input) : COLOR
			{
				float newAlpha = min(1.0, _Color.a / abs(dot(input.viewDir, input.normal)));
				return float4(_Color.rgb, newAlpha);
			}

			ENDCG
		}
	}
}
