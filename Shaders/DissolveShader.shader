Shader "Custom/DissolveShader"
{
   Properties
	{
		_Colour("Colour Tint", Color) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "white" {}

		[NoScaleOffset]_NormalMap("Normal Map", 2D) = "bump" {}
		_NormalStrength("Normal Strength", Float) = 1

		[NoScaleOffset]_OcclusionMap("Occlusion Map", 2D) = "white" {}

		[NoScaleOffset]_MetallicMap("Metallic Map", 2D) = "white" {}
		_MetallicStrength("Metallic Strength", Range(0,1)) = 0
		_SmoothnessStrength("Smoothness Strength", Range(0,1)) = 0

		[NoScaleOffset]_EmissiveMap("Emissive Map", 2D) = "white" {}
		_EmissiveStrength("Emissive Strength", Range(0,15)) = 0
		_EmissiveColour("Emissive Colour", Color) = (1,1,1,1)

		_DissolveEdgeRamp("Dissolve Edge Ramp", 2D) = "white" {}
		_DissolveEdgeSize("Dissolve Edge Size", float) = 0.1

		_DissolveTex("Dissolve Texture", 2D) = "white" {}
		_DissolveAmount("Dissolve Amount", Range(0,1)) = 0

	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
		}

		CGPROGRAM

		#pragma surface surf Standard addshadow

		sampler2D _MainTex;
		sampler2D _NormalMap;
		sampler2D _OcclusionMap;
		sampler2D _MetallicMap;
		sampler2D _EmissiveMap;
		sampler2D _DissolveTex;
		sampler2D _DissolveEdgeRamp;

		fixed4 _Colour;
		float _NormalStrength;
		float _MetallicStrength;
		float _SmoothnessStrength;
		float _EmissiveStrength;
		fixed4 _EmissiveColour;
		float _DissolveAmount;
		float _DissolveEdgeSize;

		struct Input
		{
			float2 uv_MainTex : TEXCOORD0;
			float2 uv_DissolveTex : TEXCOORD1;
		};

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			float dissolveCol = tex2D(_DissolveTex, IN.uv_DissolveTex).r; 

			clip(dissolveCol - _DissolveAmount);

			float uRamp = smoothstep(_DissolveAmount, _DissolveAmount + _DissolveEdgeSize, dissolveCol);
			float3 rampCol = tex2D(_DissolveEdgeRamp, float2(uRamp, 0));
			float3 rampContribution = rampCol * (1 - uRamp);

			o.Albedo = tex2D(_MainTex, IN.uv_MainTex) * _Colour;
			o.Albedo += rampContribution;

			fixed4 norm = tex2D(_NormalMap, IN.uv_MainTex);
			fixed3 unpacked = UnpackNormal(norm);
			unpacked.xy *= _NormalStrength;
			o.Normal = normalize(unpacked);

			o.Occlusion = tex2D(_OcclusionMap, IN.uv_MainTex);

			o.Metallic = _MetallicStrength * tex2D(_MetallicMap, IN.uv_MainTex);
			o.Smoothness = _SmoothnessStrength;

			o.Emission = tex2D(_EmissiveMap, IN.uv_MainTex) * _EmissiveStrength * _EmissiveColour;
			o.Emission += rampContribution * _EmissiveStrength;
		}

		ENDCG
	}

	CustomEditor "CustomEmissionShaderGUI"

	Fallback "Diffuse"
}