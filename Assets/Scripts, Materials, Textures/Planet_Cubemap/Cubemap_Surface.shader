Shader "Custom/Cubemap_Surface"
{
    Properties
    {
      _Cube("cube map", Cube) = "" {}
    }

        SubShader
        {
            Pass 
            {
                CGPROGRAM

                #pragma vertex vert  
                #pragma fragment frag

                uniform samplerCUBE _Cube;

                struct vertexInput
                {
                    float4 vertex : POSITION;
                };

                struct vertexOutput
                {
                    float4 pos : SV_POSITION;
                    float3 texDir : TEXCOORD0;
                };

                vertexOutput vert(vertexInput input)
                {   
                    vertexOutput output;

                    output.texDir = input.vertex;
                    output.pos = UnityObjectToClipPos(input.vertex);
                    return output;
                }

                float4 frag(vertexOutput input) : COLOR
                {
                    return texCUBE(_Cube, input.texDir);
                }

                ENDCG
            }
        
        }
        FallBack "Diffuse"
}
