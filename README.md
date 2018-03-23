Packaging F# Services for Kubernetes
====================================

Helm is a package manager for Kubernetes for deploying, upgrading, and removing application workloads to a Kubernetes cluster.

Basic usage
-----------

Install helm from http://helm.sh

It's a self contained binary, and installs it's settings in the .helm subdirectory under your user's home directory.

Run `helm init --client-only` to setup helm locally with a client repo for developing helm charts.

Create a empty helm chart:
`helm create nginx-suave`

This creates a directory `nginx-suave` with the basic helm chart files.

You can build the empty helm chart:
`helm package nginx-suave`

This creates a file `nginx-suave-0.1.0.tgz` that can be stored in a helm repository for deployment to a Kubernetes cluster.

Customizing the helm chart
--------------------------

* Chart.yaml - package metadata - name, description, version
* values.yaml - the settings specific to the deployment
* templates - these are templates that process the data in `values.yaml` to produce the files you'll typically need for deploying to a Kubernetes cluster
  - deployment.yaml - template for the deployment - container images, number to launch, affinity, etc.
  - service.yaml - template for the service abstraction over the pod's containers
  - ingress.yaml - template for the ingress address, ports, and load balancers for externally reaching the service

The LittleSuave Docker Image
----------------------------
Just making a tiny "hello world" in Suave, in a Docker image to include in a Kubernetes deployment.

**Image is available as `dcurylo/littlesuave` - steps to build it are below for completeness**

littlesuave.sh
```
#!/bin/bash

dotnet new console -n littleSuaveApp -lang F#;
cd littleSuaveApp;
dotnet add package suave;
awk '/open System/{print "open Suave"}; /0/{print "    startWebServer { defaultConfig with bindings = [ HttpBinding.createSimple HTTP \"0.0.0.0\" 8080 ] } (Successful.OK \"Hello World!\")"}1' Program.fs > tmp.fs;
mv tmp.fs Program.fs;
dotnet publish -c Release;
```

Run the above in the .NET Core SDK image:
```
docker run --rm -v `pwd`:/src microsoft/dotnet:2-sdk bash -c 'cd /src && chmod u+x littlesuave.sh && ./littlesuave.sh'
```

Now build the littlesuave image with this Dockerfile
```
FROM microsoft/dotnet:2-runtime
ADD littleSuaveApp/bin/Release/netcoreapp2.0/publish /app
ENTRYPOINT ["dotnet", "app/littleSuaveApp.dll"]
```
and this command:
```
docker build -t littlesuave .
```
