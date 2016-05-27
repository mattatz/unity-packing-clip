using UnityEngine;

using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;

namespace mattatz.PackingClip {

    [RequireComponent (typeof(Camera))]
    public class PackingClip : MonoBehaviour {

        enum PackingClipMode {
            ClipOnly,
            PackingClipArea
        };

        [System.Serializable]
        struct PackingArea {
            public Vector2 from;
            public Vector2 to;
            public Vector2 size;
        }

        [SerializeField] PackingClipMode mode = PackingClipMode.PackingClipArea;
        [SerializeField] Vector2 offset;
        [SerializeField] PackingArea[] data;
        [SerializeField] Color emptyColor = Color.black;

        ComputeBuffer buffer;

        [SerializeField] Shader shader;

        Material material;

        void Start() {
            material = new Material(shader);
        }

        void OnRenderImage(RenderTexture src, RenderTexture dst) {
            if (buffer == null) {
                buffer = new ComputeBuffer(data.Length, Marshal.SizeOf(typeof(PackingArea)));
                buffer.SetData(data);
            }

            material.SetVector("_Offset", offset);
            material.SetBuffer("_Data", buffer);
            material.SetInt("_DataCount", data.Length);
            material.SetColor("_Color", emptyColor);

            Graphics.Blit(src, dst, material, (int)mode);
        }

        void OnDisable() {
            if (buffer != null) {
                buffer.Release();
                buffer = null;
            }
        }

    }

}


