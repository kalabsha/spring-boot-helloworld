# Assignment

1. Install Docker.io on your local PC. DONE
1. Fork above repo to your own GitHub (Create a GitHub account if you don't have yet). DONE
1. Create a Dockerfile with two stages, the first stage compiles code and output a jar file, the second stage run the jar and expose the service with 8080 port. DONE
1. Test Docker build and run locally. DONE
1. Push the Dockerfile to your forked repo with a proper commit message.
1. Choose a CI/CD tool you are familiar with and automate above build process.

# Installations

## Docker Installation
https://docs.docker.com/engine/install/
https://docs.docker.com/engine/install/linux-postinstall/

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


## GitLab Installation
https://docs.gitlab.com/ee/install/docker.html

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

## Gitlab Runner Installation

```bash
docker run -d --name gitlab-runner --restart always \
  -v $HOME/gitlab-runner/config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:alpine-v15.5.0
```

## Minikube Installation
https://minikube.sigs.k8s.io/docs/start/

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

# Fork/Clone/Import the spring-boot-helloworld Project to GitHub
There are a few methods to do the job.

1. [Import the repository](https://github.com/new/import), fill in the url with the [bitbucket repo link](https://bitbucket.org/joelyen/spring-boot-helloworld/src/master/)

1. Clone to local from bitbucket.org, then push to GitHub.
    1. Create a project on GitHub
    1. Clone the repo to local, add GitHub as another remote, then push it
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

    git remote -v
    github  git@github.com:kalabsha/spring-boot-helloworld.git (fetch)
    github  git@github.com:kalabsha/spring-boot-helloworld.git (push)
    origin  git@bitbucket.org:joelyen/spring-boot-helloworld.git (fetch)
    origin  git@bitbucket.org:joelyen/spring-boot-helloworld.git (push)
    ```
    
# Dockerlize the Spring-boot Project

First of all, I replace the repo mirrors to speed up the download, this could save us some time while building the docker image.

By following the [Official Tutorials](https://spring.io/guides/topicals/spring-boot-docker/), we get a basic Dockerfile with multi-stage build.

Here in this example, taking the advice from [This Blog Post](https://blogs.oracle.com/javamagazine/post/its-time-to-move-your-applications-to-java-17-heres-why-and-heres-how), I upgrade the JDK version from 1.8 to 17, therefore, we need append more dependencies to the pom.xml file. And by using the `jre` docker base image in the second stage, we get a smaller image as a result.

Then we use a non-root user, `demo` in this case, to precaution limits their capabilities by following the principle of least privilege.

Finally, we will get a docker image with the following commands:

    ```bash
    # Make sure we are at ~/Code/spring-boot-helloworld
    $ DOCKER_BUILDKIT=1 docker build -t spring-boot/hello:v0.0.1 .

    $ docker images
    REPOSITORY             TAG                IMAGE ID       CREATED         SIZE
    spring-boot/hello      v0.0.1             9ff41bc2b816   3 hours ago     207MB
    ......
    ```

# CI/CD

[GitLab CI/CD Workflow](https://docs.gitlab.com/ee/user/clusters/agent/ci_cd_workflow.html)

[GitLab Blog](https://about.gitlab.com/blog/2016/12/14/continuous-delivery-of-a-spring-boot-application-with-gitlab-ci-and-kubernetes/)

