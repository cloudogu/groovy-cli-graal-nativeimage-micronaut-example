# Groovy CLI Graal Native Image Micronaut Example
[![Push to GitHub Container Registry](https://github.com/cloudogu/groovy-cli-graal-nativeimage-micronaut-example/actions/workflows/push-ghcr.yaml/badge.svg?branch=main)](https://github.com/cloudogu/groovy-cli-graal-nativeimage-micronaut-example/actions/workflows/push-ghcr.yaml)

An example CLI app written in Groovy, using micronaut, compiling into a static binary via Graal native image.

> Use of GraalVM’s native-image tool is only supported in Java or Kotlin projects. Groovy relies heavily on reflection which is only partially supported by GraalVM.  
https://docs.micronaut.io/2.5.1/guide/index.html#graal

This project is for those who'd like to try anyway.

## Create and run image

The result can also be found at [ghcr.io/cloudogu/groovy-cli-graal-nativeimage-micronaut-example](https://ghcr.io/cloudogu/groovy-cli-graal-nativeimage-micronaut-example)

```shell
# First build takes a couple of minutes!
$ docker build -t groovy .

# Run image built locally
$ docker run --rm groovy -v
# Or pull and run remote image
$ docker run --rm ghcr.io/cloudogu/groovy-cli-graal-nativeimage-micronaut-example

# Interesting: Size of static Binary without additional JRE (uncompressed! on the registry it's about 1/4 the size)
$ docker images groovy
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
groovy          latest    c5f9ff7e61c6   50 minutes ago   76.9MB
```

The build should also work without `Dockerfile` using `./mvnw package -Dpackaging=docker-native` but this fails.
Passing the same arguments as in `Dockerfile` also fails: 

```shell
# java.lang.NoClassDefFoundError: org/apache/ivy/core/module/descriptor/ModuleDescriptor
./mvnw package -Dpackaging=docker-native \
  -Dmicronaut.native-image.args='-Dgroovy.grape.enable=false -H:+ReportExceptionStackTraces -H:ConfigurationFileDirectories=conf/ --static --allow-incomplete-classpath --report-unsupported-elements-at-runtime --initialize-at-run-time=org.codehaus.groovy.control.XStreamUtils,groovy.grape.GrapeIvy --initialize-at-build-time --no-server'
```
So somehow some dependencies seem to be missing?!

## How this example was created

```
mn create-cli-app -b maven -l groovy -t junit groovy 
```

Manually added

* `pom.xml`: 
  * for `<artifactId>gmavenplus-plugin</artifactId>`
    ```xml
    <configuration>
      <configScript>compiler.groovy</configScript>
    </configuration>
    ```
    * Add `maven.compiler.source` and `.target` to use JDK 11 
* `Dockerfile` and `.dockerignore`
* `compiler.groovy`
* for development it would also be helpful to set the `compiler.groovy` as the config script for your IDE's groovy compiler.

## Resources

* When running into exceptions such as the following:
  java.lang.ClassNotFoundException: org.codehaus.groovy.runtime.dgm$...
  groovy.lang.MissingMethodException: No signature of method: ...is applicable for argument types: ...
  See 
  * [here](https://github.com/croz-ltd/klokwrk-project/blob/57202c58b792aff5f47e4c9033f91e5a31f100cc/support/documentation/article/groovy-graalvm-native-image/groovy-graalvm-native-image.md#default-groovy-methods) for a general overview and
  * [this commit](https://github.com/cloudogu/gitops-playground/commit/2a169f661a9743938e1333fc3564a5e6f88cc4e4) for a working example
* [More recent example: Groovy script as graal native image](https://dev.to/wololock/groovy-script-startup-time-from-2-1s-to-0-013s-with-graalvm-1p34), with [example project](https://github.com/wololock/gttp).
  This example shows how to build a groovy script. Our example here shows how to use classes and micronaut and a build tool.
* [Older Example on how Graal could work with Groovy](https://e.printstacktrace.blog/graalvm-and-groovy-how-to-start/), with [example project](https://github.com/wololock/graalvm-groovy-examples). 
  It also contains [Groovy Compiler Config](https://github.com/wololock/graalvm-groovy-examples/blob/master/hello-world/conf/compiler.groovy) for static compiling. Other articles also mention to add `ast(groovy.transform.TypeChecked)` to the config.