package groovy.cli.graal.nativeimage.micronaut.example

import io.micronaut.configuration.picocli.PicocliRunner
import io.micronaut.context.ApplicationContext

import picocli.CommandLine
import picocli.CommandLine.Command
import picocli.CommandLine.Option
import picocli.CommandLine.Parameters

@Command(name = 'groovy-cli-graal-nativeimage-micronaut-example', description = '...',
        mixinStandardHelpOptions = true)
class GroovyCliGraalNativeimageMicronautExampleCommand implements Runnable {

    @Option(names = ['-v', '--verbose'], description = '...')
    boolean verbose

    static void main(String[] args) throws Exception {
        PicocliRunner.run(GroovyCliGraalNativeimageMicronautExampleCommand.class, args)
    }

    void run() {
        // business logic here
        if (verbose) {
            println "Hi!"
        }
    }
}
