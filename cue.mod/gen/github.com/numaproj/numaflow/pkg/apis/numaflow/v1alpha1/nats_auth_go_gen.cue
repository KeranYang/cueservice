// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/numaproj/numaflow/pkg/apis/numaflow/v1alpha1

package v1alpha1

import corev1 "k8s.io/api/core/v1"

// NatsAuth defines how to authenticate the nats access
#NatsAuth: {
	// Basic auth which contains a user name and a password
	// +optional
	basic?: null | #BasicAuth @go(Basic,*BasicAuth) @protobuf(1,bytes,opt)

	// Token auth
	// +optional
	token?: null | corev1.#SecretKeySelector @go(Token,*corev1.SecretKeySelector) @protobuf(2,bytes,opt)

	// NKey auth
	// +optional
	nkey?: null | corev1.#SecretKeySelector @go(NKey,*corev1.SecretKeySelector) @protobuf(3,bytes,opt)
}
