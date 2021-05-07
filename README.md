# Micronaut Groovy CLI Graal Native Image Example

> Use of GraalVM’s native-image tool is only supported in Java or Kotlin projects. Groovy relies heavily on reflection which is only partially supported by GraalVM.
https://docs.micronaut.io/2.5.1/guide/index.html#graal

This project is for those who'd like to try anyway.

## Create and run image

```shell
# First build takes a couple of minutes!
$ docker build -t groovy .

# Run
$ docker run --rm groovy -v
# Interesting: Size of static Binary without additional JRE
$ docker images groovy
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
groovy          latest    c5f9ff7e61c6   50 minutes ago   76.9MB
```

This should also work without `Dockerfile` using `./mvnw package -Dpackaging=docker-native` but this fails.
Passing the same arguments as in `Dockerfile` also fails: 

```shell
# java.lang.NoClassDefFoundError: org/apache/ivy/core/module/descriptor/ModuleDescriptor
./mvnw package -Dpackaging=docker-native -Dmicronaut.native-image.args='-Dgroovy.grape.enable=false -H:+ReportExceptionStackTraces -H:ConfigurationFileDirectories=conf/ --static --allow-incomplete-classpath --report-unsupported-elements-at-runtime --initialize-at-run-time=org.codehaus.groovy.control.XStreamUtils,groovy.grape.GrapeIvy --initialize-at-build-time --no-server'
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

* [More recent example: Groovy script as graal native image](https://dev.to/wololock/groovy-script-startup-time-from-2-1s-to-0-013s-with-graalvm-1p34), with [example project](https://github.com/wololock/gttp).
  This example shows how to build a groovy script. Our example here shows how to use classes and micronaut and a build tool.
* [Older Example how Graal could work with Groovy](https://e.printstacktrace.blog/graalvm-and-groovy-how-to-start/), with [example project](https://github.com/wololock/graalvm-groovy-examples). 
  It also contains [Groovy Compiler Config](https://github.com/wololock/graalvm-groovy-examples/blob/master/hello-world/conf/compiler.groovy) for static compiling. Other articles also mention to add `ast(groovy.transform.TypeChecked)` to the config.