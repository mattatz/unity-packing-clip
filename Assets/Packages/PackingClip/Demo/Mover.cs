using UnityEngine;
using System.Collections;

namespace mattatz.PackingClip.Demo
{

    public class Mover : MonoBehaviour {

        [SerializeField] float speed = 1f;

        void Start () {
        }
        
        void Update () {
        }

        void FixedUpdate () {
            transform.LookAt(Vector3.zero);

            var direction = Vector3.zero - transform.position;
            var right = Vector3.Cross(direction, transform.up);

            var p = transform.position;
            p += right * Time.fixedDeltaTime * speed;
            transform.position = p;
        }

    }

}


