Shader "mattatz/PackingArea" {

	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (0, 0, 0, 1)
	}

	SubShader {
		Cull Off ZWrite Off ZTest Always

		CGINCLUDE

		#pragma target 5.0
		
		#include "UnityCG.cginc"

		struct appdata {
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f {
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
		};

		sampler2D _MainTex;
		float4 _MainTex_TexelSize;

		fixed4 _Color;

		struct PackingArea {
			float2 from;
			float2 to;
			float2 size;
		};

		StructuredBuffer<PackingArea> _Data;
		int _DataCount;

		v2f vert (appdata v) {
			v2f o;
			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv = v.uv;
			return o;
		}

		bool clipArea (float2 uv, PackingArea area) {
			return (area.to.x <= uv.x && uv.x <= area.to.x + area.size.x) 
				&& (area.to.y <= uv.y && uv.y <= area.to.y + area.size.y);
		}

		bool include(float2 uv, float2 position, float2 size) {
			return (position.x <= uv.x && uv.x <= position.x + size.x) 
				&& (position.y <= uv.y && uv.y <= position.y + size.y);
		}

		float4 packing(sampler2D tex, float2 uv) {
			float4 color = _Color;
			for(uint i = 0; i < _DataCount; i++) {
				PackingArea area = _Data[i];
				if(include(uv, area.to, area.size)) {
					float2 d = uv - area.to;
					float2 to = area.from + d;
					color = tex2D(tex, to);
				}
			}
			return color;
		}

		float4 clip(sampler2D tex, float2 uv) {
			float4 color = _Color;
			for(uint i = 0; i < _DataCount; i++) {
				PackingArea area = _Data[i];
				if(include(uv, area.from, area.size)) {
					color = tex2D(tex, uv);
				}
			}
			return color;
		}

		ENDCG

		Pass { // 0 : clip only

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			fixed4 frag(v2f i) : SV_Target{
				return clip(_MainTex, i.uv);
				return packing(_MainTex, i.uv);
			}

			ENDCG
		}

		Pass { // 1 : packing clip area

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			fixed4 frag(v2f i) : SV_Target{
				return packing(_MainTex, i.uv);
			}

			ENDCG
		}

	}

}
