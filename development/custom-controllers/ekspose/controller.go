package main

import "k8s.io/client-go/kubernetes"

type controller struct {
	clientset kubernetes.Interface
}
