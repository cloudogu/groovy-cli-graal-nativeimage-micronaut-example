FROM ghcr.io/graalvm/graalvm-ce:22.0.0.2 AS graal

FROM graal as maven-cache
ENV MAVEN_OPTS=-Dmaven.repo.local=/mvn
WORKDIR /app
COPY .mvn/ /app/.mvn/
COPY mvnw /app/ 
COPY pom.xml /app/
RUN ./mvnw dependency:go-offline

FROM graal as native-image
ENV MAVEN_OPTS=-Dmaven.repo.local=/mvn
RUN gu install native-image

COPY --from=maven-cache /mvn/ /mvn/
COPY --from=maven-cache /app/ /app
WORKDIR /app
COPY . /app

# Build native image micronaut
#  ./mvnw package -Dpackaging=native-image

# Build native image without micronaut
RUN ./mvnw package -DskipTests

# Create Graal native image config for largest jar file 
RUN java -agentlib:native-image-agent=config-output-dir=conf/ -jar $(ls -S target/*.jar | head -n 1)

# Set up musl, in order to produce a static image compatible to alpine
# See 
# https://github.com/oracle/graal/issues/2824 and 
# https://github.com/oracle/graal/blob/vm-ce-22.0.0.2/docs/reference-manual/native-image/StaticImages.md
ARG RESULT_LIB="/musl"
RUN mkdir ${RESULT_LIB} && \
    curl -L -o musl.tar.gz https://more.musl.cc/10.2.1/x86_64-linux-musl/x86_64-linux-musl-native.tgz && \
    tar -xvzf musl.tar.gz -C ${RESULT_LIB} --strip-components 1 && \
    cp /usr/lib/gcc/x86_64-redhat-linux/8/libstdc++.a ${RESULT_LIB}/lib/
ENV CC=/musl/bin/gcc
RUN curl -L -o zlib.tar.gz https://zlib.net/zlib-1.2.11.tar.gz && \
    mkdir zlib && tar -xvzf zlib.tar.gz -C zlib --strip-components 1 && \
    cd zlib && ./configure --static --prefix=/musl && \
    make && make install && \
    cd / && rm -rf /zlib && rm -f /zlib.tar.gz
ENV PATH="$PATH:/musl/bin"

RUN native-image -Dgroovy.grape.enable=false \
    -H:+ReportExceptionStackTraces \
    -H:ConfigurationFileDirectories=conf/ \
    --static \
    --allow-incomplete-classpath   \
    --report-unsupported-elements-at-runtime \
    --initialize-at-run-time=org.codehaus.groovy.control.XStreamUtils,groovy.grape.GrapeIvy,org.codehaus.groovy.vmplugin.v8.Java8\$LookupHolder \
    --initialize-at-build-time=com.sun.beans,groovy.lang,groovyjarjarantlr4.v4,java.beans,org.apache.groovy,org.codehaus.groovy \
    --no-fallback \
    --no-server \
    --libc=musl \
    -jar $(ls -S target/*.jar | head -n 1) \
    app

FROM scratch

COPY --from=native-image /app/app /app
ENTRYPOINT ["/app"]
