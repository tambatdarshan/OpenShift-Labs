package main

import (
	"context"
	"flag"
	"fmt"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
)

func main() {
	kubeconfig := flag.String("kubeconfig", "/Users/cchen/Code/ocp_install/4.8.46/auth/kubeconfig", "Default kubeconfig file")
	config, err := clientcmd.BuildConfigFromFlags("", *kubeconfig)
	if err != nil {
		fmt.Println("error")
	}
	ctx := context.Background()
	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		fmt.Println("error")
	}
	pods, _ := clientset.CoreV1().Pods("openshift-etcd").List(ctx, metav1.ListOptions{})
	fmt.Println("Pods from default namespace")
	for _, pod := range pods.Items {
		fmt.Printf("pod name %s\n", pod.Name)
	}
	deployments, _ := clientset.AppsV1().Deployments("openshift-etcd").List(ctx, metav1.ListOptions{})
	fmt.Println("Deployments Information")
	for _, deploy := range deployments.Items {
		fmt.Printf("%s, %s\n", deploy.Name, deploy.CreationTimestamp)
	}
}
