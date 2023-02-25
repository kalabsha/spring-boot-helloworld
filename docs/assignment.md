# Assignment

1. Install Docker.io on your local PC.
1. Fork above repo to your own GitHub (Create a GitHub account if you don't have yet).
1. Create a Dockerfile with two stages, the first stage compiles code and output a jar file, the second stage run the jar and expose the service with 8080 port.
1. Test Docker build and run locally.
1. Push the Dockerfile to your forked repo with a proper commit message.
1. Choose a CI/CD tool you are familiar with and automate above build process.

## Docker Installation

With the friendly [official instructions](https://docs.docker.com/engine/install/), we can install Docker Engine on a modern Linux distribution easily. It is good to know that the [post configuration](https://docs.docker.com/engine/install/linux-postinstall/) could be of help sometimes. For example, we use `registry-mirrors` to speed up the `docker pull` progress.

```json
# /etc/docker/daemon.json

{
    "experimental": true,
    "registry-mirrors": ["https://registry.docker-cn.com", "https://docker.mirrors.ustc.edu.cn/"],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "1g",
        "max-file": "3"
    }
}

```


## Fork/Clone/Import the spring-boot-helloworld Project to GitHub

There are a few methods to do the job.

### Method 1. Using GitHub Import the repository

Click the GitHub [Import the repository](https://github.com/new/import), fill in the text box with the given [bitbucket repo link](https://bitbucket.org/joelyen/spring-boot-helloworld), then follow the instructions.


### Method 2. Clone to local from bitbucket.org, then push to GitHub

1. Create a project on GitHub
1. Clone the repo to local, add GitHub as another remote, then push it to the new remote
    ```bash
    # Clone the sample repo to local dirctory
    cd ~/Code
    git clone git@bitbucket.org:joelyen/spring-boot-helloworld

    # Check the remote settings
    cd spring-boot-helloworld
    git remote -v
      origin  git@bitbucket.org:joelyen/spring-boot-helloworld.git (fetch)
      origin  git@bitbucket.org:joelyen/spring-boot-helloworld.git (push)

    git remote add github git@github.com:kalabsha/spring-boot-helloworld.git

    # Finally, the remote settings should be like this
    git remote -v
      github  git@github.com:kalabsha/spring-boot-helloworld.git (fetch)
      github  git@github.com:kalabsha/spring-boot-helloworld.git (push)
      origin  git@bitbucket.org:joelyen/spring-boot-helloworld.git (fetch)
      origin  git@bitbucket.org:joelyen/spring-boot-helloworld.git (push)
    ```
    
## Dockerize the Spring-boot Project

First of all, I replace the repo mirrors to speed up the download, this could save us some time while building the docker image.

By following the [Official Tutorials](https://spring.io/guides/topicals/spring-boot-docker/), we get a basic Dockerfile with multi-stage build.

~~Here in this example, taking the advice from [This Blog Post](https://blogs.oracle.com/javamagazine/post/its-time-to-move-your-applications-to-java-17-heres-why-and-heres-how), I upgrade the JDK version from 1.8 to 17, therefore, we need append more dependencies to the pom.xml file.~~ With the reference to this [GitLab Blog](https://about.gitlab.com/blog/2016/12/14/continuous-delivery-of-a-spring-boot-application-with-gitlab-ci-and-kubernetes/)
, we use the latest JDK 8 with the base image `maven:3.9.0-eclipse-temurin-8-alpine` at last. And by using the `eclipse-temurin:8-jre-alpine` docker base image in the second stage, we get a smaller image as a result.

Then we use a non-root user, `demo` in this case, to precaution limits the capabilities by following the principle of least privilege.

Finally, we will get a docker image with the following commands:

```bash
# Make sure we are at ~/Code/spring-boot-helloworld
$ DOCKER_BUILDKIT=1 docker build -t spring-boot/helloworld:v0.0.1 .

$ docker images
REPOSITORY                  TAG                IMAGE ID       CREATED         SIZE
spring-boot/helloworld      v0.0.1             9ff41bc2b816   3 hours ago     175MB
......
```

## Test Docker build and run locally

1. Run up the built docker image, by publish the port 8080 to the HOST

    ```
    $ docker run --rm -p 8080:8080 spring-boot/helloworld:v0.0.1                                                                               
                                                                                                                                          
      .   ____          _            __ _ _                                                                                               
    /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \                                                                                              
    ( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \                                                                                             
    \\/  ___)| |_)| | | | | || (_| |  ) ) ) )                                                                                            
      '  |____| .__|_| |_|_| |_\__, | / / / /                                                                                             
    =========|_|==============|___/=/_/_/_/                                                                                              
    :: Spring Boot ::        (v2.1.2.RELEASE)                                                                                            
                                                                                                                                          
    2023-02-24 13:56:24.099  INFO 1 --- [           main] de.ykoer.examples.hello.Application      : Starting Application v0.0.1-SNAPSHOT 
    on 45034c0a6e6b with PID 1 (/workspace/app/helloworld.jar started by demo in /workspace/app)                                          

    ...

    2023-02-24 13:56:26.710  INFO 1 --- [           main] de.ykoer.examples.hello.Application      : Started Application in 2.961 seconds 
    (JVM running for 3.293)

    ```

1. Access the service by using `curl`：

    ```bash
    $ curl localhost:8080/ping
    Hello World! It is wonderful!
    ```

    >The output here is _Hello World! It is wonderful!_ while we build the docker image with `mvn install -DskipTests`. 


## Push the Dockerfile to your forked repo with a proper commit message

In fact, I checkout to the `dev` branch from the begining of the development, so now we can push the Dockerfile to the remote GitHub repository, and then use **Pull Request** to merge it to the `master` branch. see the [PR](https://github.com/kalabsha/spring-boot-helloworld/pull/1).


# CI/CD

I am more familiar with GitLab as the CI tool. So I use GitLab and Kubernetes for this task. All the work is done locally. Here are the main steps:

1. Set up a Registry for hosting built docker images
1. Set up a Kubernetes Cluster
1. Set up a hosted GitLab Server and store the Registry username and password as variables
1. Create a GitLab account for the CI user, store user token as variables in CI/CD settings
1. Set up a GitLab Runner, and make sure it is registered to the GitLab server with a proper tag name, `spring-boot` for example in this case, and has the proper permissions to access the Kubernetes cluster
1. Create a `.gitlab-ci.yml` and `deployment.yml` for CI/CD in the root directory of the project

## Preparations

### [GitLab Installation](https://docs.gitlab.com/ee/install/docker.html)

```bash
export GITLAB_HOME=$HOME/gitlab
docker run --detach \
  --hostname gitlab.example.com \
  --publish 8443:443 --publish 8082:80 --publish 2222:22 \
  --name gitlab \
  --restart always \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/logs:/var/log/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  --shm-size 256m \
  gitlab/gitlab-ce:15.5.0-ce.0

echo "127.0.0.1 gitlab.example.com" | sudo tee -a /etc/hosts
```

### [Gitlab Runner Installation](https://docs.gitlab.com/runner/install/)

```bash
docker run -d --name gitlab-runner --restart always \
  -v $HOME/gitlab-runner/config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:alpine-v15.5.0
```

### [Minikube Installation](https://minikube.sigs.k8s.io/docs/start/)

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

## [Create Kubernetes Deployment](https://spring.io/guides/gs/spring-boot-kubernetes/)

```bash
$ kubectl create deployment helloworld --image=spring-boot/hello --dry-run -o=yaml > deployment.yaml
$ echo --- >> deployment.yaml
$ kubectl create service clusterip helloworld --tcp=8080:8080 --dry-run -o=yaml >> deployment.yaml
```

## Continues Integration and Deployment with GitLab

```bash
# .gitlab-ci.yml
image: docker:$DOCKER_VERSION
services:
  - docker:$DOCKER_VERSION

variables:
  REGISTRY_URL: registry.demo.com
  DOCKER_IMAGE: spring-boot/helloworld
  SERVICE_URL: http://localhost:8080/ping
  TEST_RESULT: 'Hello World!'
  # CI_BUILD_TOKEN: THIS TOKEN STORES IN GITLAB SETTINGS

stages:
  - build
  - test
  - deploy

docker-image-build:
  stage: build
  only:
  - dev
  - master
  tags:
  - spring-boot
  script:
  # - echo "Docker image Building..."
  - docker build -t $REGISTRY_URL/$DOCKER_IMAGE .
  - docker login -u gitlab-ci-token -p $CI_BUILD_TOKEN $REGISTRY_URL
  - docker push $REGISTRY_URL/$DOCKER_IMAGE

spring-boot-test:
  stage: test
  only:
  - dev
  - master
  tags:
  - spring-boot
  script:
  # - echo "Docker image Building..."
  # - curl $SERVICE_URL && echo yes || echo no
  - if [[ $(curl $SERVICE_URL) = $TEST_RESULT ]]; then echo PASS else echo FAIL && exit 1;fi

k8s-deploy:
  stage: deploy
  only:
  - dev
  - master
  tags:
  - spring-boot
  image: $DOCKER_IMAGE
  script:
  # - echo "Deploying..."
  - kubectl delete secret $REGISTRY_URL
  - kubectl create secret docker-registry $REGISTRY_URL --docker-server=$REGISTRY_URL --docker-username=$REGISTRY_USER --docker-password=$REGISTRY_PASSWD
  - kubectl apply -f deployment.yml
```

---

## References:

- [Docker Official Documents](https://docs.docker.com/engine/install/)
- [Spring Boot Tutorials: Docker](https://spring.io/guides/topicals/spring-boot-docker/)
- [GitLab Installation Instructions](https://docs.gitlab.com/ee/install/docker.html)
- [GitLab CI/CD Workflow](https://docs.gitlab.com/ee/user/clusters/agent/ci_cd_workflow.html)
- [GitLab Blog: Spring Boot Application CI/CD](https://about.gitlab.com/blog/2016/12/14/continuous-delivery-of-a-spring-boot-application-with-gitlab-ci-and-kubernetes/)
- [Spring Boot Tutorials: Kubernetes](https://spring.io/guides/gs/spring-boot-kubernetes/)