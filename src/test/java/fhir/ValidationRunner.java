package fhir;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertTrue;

class ValidationRunner {

    private static final String[] ALL_PATHS = {
        "classpath:capability",
        "classpath:patient",
        "classpath:observation",
        "classpath:allergy",
        "classpath:medication",
        "classpath:diagnostic",
        "classpath:audit",
        "classpath:bundle",
        "classpath:practitioner",
        "classpath:common"
    };

    @Test
    void testAll() {
        String karateOptions = System.getProperty("karate.options");

        Runner.Builder<?> builder;
        if (karateOptions != null && karateOptions.startsWith("classpath:")) {
            // e.g. -Dkarate.options="classpath:oq" — run only that path
            builder = Runner.path(karateOptions.trim());
        } else {
            builder = Runner.path(ALL_PATHS);
        }

        Results results = builder.outputCucumberJson(true).parallel(5);
        assertTrue(results.getFailCount() == 0, results.getErrorMessages());
    }
}
