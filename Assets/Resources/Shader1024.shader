﻿Shader "Unlit/Shader1024"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MainTex2("Texture", 2D) = "white" {}
		_MainTex3("Texture", 2D) = "white" {}
		_MainTex4("Texture", 2D) = "white" {}
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Blend mode", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Blend mode", Float) = 1
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("ZTest", Float) = 4
		[Enum(Off, 0, On, 1)] _ZWrite ("ZWrite", Float) = 0
	}
	SubShader
	{
		Tags{ "Queue" = "Geometry" }
		// Tags{ "Queue" = "Transparent" }
		LOD 100

		Pass
		{
			Cull Back
			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]
			ZTest [_ZTest]

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#pragma enable_d3d11_debug_symbols  
			#pragma multi_compile __ EnableClip
			#pragma multi_compile __ Only1Sampler
			#pragma multi_compile __ NoTexture
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				half2 uv : TEXCOORD0;
				half2 uv2 : TEXCOORD1;
				half2 uv3 : TEXCOORD2;
				half2 uv4 : TEXCOORD3;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _MainTex2;
			float4 _MainTex2_ST;

			sampler2D _MainTex3;
			float4 _MainTex3_ST;

			sampler2D _MainTex4;
			float4 _MainTex4_ST;
			
			v2f vert (appdata v)
			{
				v2f o = (v2f)0;
				o.vertex = UnityObjectToClipPos(v.vertex);
				
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
#ifndef Only1Sampler
				o.uv2 = TRANSFORM_TEX(v.uv, _MainTex2);
				o.uv3 = TRANSFORM_TEX(v.uv, _MainTex3);
				o.uv4 = TRANSFORM_TEX(v.uv, _MainTex4);
#endif
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 ret = fixed4(0, 0, 0, 1);

#ifndef NoTexture
				fixed4 col = tex2D(_MainTex, i.uv);
	#ifdef Only1Sampler
				ret = col * 1.00001;
	#else
				fixed4 col2 = tex2D(_MainTex2, i.uv2);
				fixed4 col3 = tex2D(_MainTex3, i.uv3);
				fixed4 col4 = tex2D(_MainTex4, i.uv4);
				ret = (col + col2 + col3 + col4) * 0.25;
	#endif
#else
				half2 uv = i.uv;
				ret = fixed4(uv.x, uv.y, 0, uv.x * uv.y);
#endif
				
#ifdef EnableClip
				clip(ret.w - 0.99);
#endif
				return ret;
			}
			ENDCG
		}
	}
}
