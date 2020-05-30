This is a sample [CDK8s](https://cdk8s.io/) program. This (TypeScript) program generates a YAML file that includes all Kubernetes objects that are needed to run Yelb on a Kubernetes cluster.

In order to use CDK8s make sure you have it properly [installed on your system](https://github.com/awslabs/cdk8s/blob/master/docs/getting-started/typescript.md) or use [eksutils](https://github.com/mreferre/eksutils).

Once you have the pre-requisite above, just launch:

```
npm install 
npm run compile
```

This generates a Kubernetes yaml file in the `dist` folder. You can apply this file with:

```
kubectl apply -f dist/yelbcdk8sv2.k8s.yaml 
```



