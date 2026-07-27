@Target({ ElementType.METHOD, ElementType.TYPE })
@Retention(RetentionPolicy.RUNTIME)
@ExtendWith(TimeTravel.Extension.class)
@NonConcurrentTest
public @interface TimeTravel {
    String instant(); // ISO-8601 timestamp, ej: "2026-01-11T00:00:00Z"
    boolean strict() default false;

    class Extension implements InvocationInterceptor {

        @Override
        public void interceptTestMethod(
                Invocation<Void> invocation,
                ReflectiveInvocationContext<Method> invocationContext,
                ExtensionContext extensionContext
        ) throws Throwable {
            Method method = invocationContext.getExecutable();
            Class<?> testClass = extensionContext.getTestClass().orElseThrow();

            TimeTravel timeTravel = resolveTimeTravel(method, testClass);

            if (timeTravel == null) {
                invocation.proceed();
                return;
            }

            logActivation(timeTravel, method, testClass);

            failIfConcurrent(method, testClass);
            failIfParallelGloballyEnabled(extensionContext);
            failIfMultipleTimeAnnotations(method, testClass);

            enforceStrictMode(timeTravel, method, testClass);

            LocalDateTime fixedDateTime = LocalDateTime.ofInstant(parseInstant(timeTravel.instant()), ZoneOffset.UTC);
            LocalDate fixedDate = fixedDateTime.toLocalDate();
            LocalTime fixedTime = fixedDateTime.toLocalTime();

            try (
                    var mockDate = Mockito.mockStatic(LocalDate.class, Mockito.CALLS_REAL_METHODS);
                    var mockTime = Mockito.mockStatic(LocalTime.class, Mockito.CALLS_REAL_METHODS);
                    var mockDateTime = Mockito.mockStatic(LocalDateTime.class, Mockito.CALLS_REAL_METHODS)
            ) {
                mockDate.when(LocalDate::now).thenReturn(fixedDate);
                mockTime.when(LocalTime::now).thenReturn(fixedTime);
                mockDateTime.when(LocalDateTime::now).thenReturn(fixedDateTime);

                invocation.proceed();
            } finally {
                logDeactivation(method, testClass);
            }
        }

        private static TimeTravel resolveTimeTravel(Method method, Class<?> testClass) {
            if (method.isAnnotationPresent(DisableTimeTravel.class) ||
                    testClass.isAnnotationPresent(DisableTimeTravel.class)) {
                return null;
            }

            TimeTravel direct = method.getAnnotation(TimeTravel.class);
            if (direct != null) return direct;

            for (Annotation ann : method.getAnnotations()) {
                TimeTravel meta = ann.annotationType().getAnnotation(TimeTravel.class);
                if (meta != null) return meta;
            }

            direct = testClass.getAnnotation(TimeTravel.class);
            if (direct != null) return direct;

            for (Annotation ann : testClass.getAnnotations()) {
                TimeTravel meta = ann.annotationType().getAnnotation(TimeTravel.class);
                if (meta != null) return meta;
            }

            return null;
        }

        private static Instant parseInstant(String value) {
            try {
                return Instant.parse(value);
            } catch (Exception ex) {
                throw new ExtensionConfigurationException(
                        "@TimeTravel instant inválido: '" + value +
                                "'. Debe ser ISO-8601 con zona (ej: 2026-01-11T12:00:00Z)",
                        ex
                );
            }
        }

        private static void failIfConcurrent(Method method, Class<?> testClass) {
            Execution exec = method.getAnnotation(Execution.class);
            if (exec == null) {
                exec = testClass.getAnnotation(Execution.class);
            }

            if (exec != null && exec.value() == ExecutionMode.CONCURRENT) {
                var reason = "@TimeTravel no es compatible con ejecución paralela. Use @Execution(SAME_THREAD).";
                TimeTravelLogger.LOG.error("⛔ TimeTravel VIOLATION | {}", reason);
                throw new ExtensionConfigurationException(reason);
            }
        }

        private static void failIfParallelGloballyEnabled(ExtensionContext ctx) {
            boolean parallelEnabled =
                    ctx.getConfigurationParameter("junit.jupiter.execution.parallel.enabled")
                            .map(Boolean::parseBoolean)
                            .orElse(false);

            if (parallelEnabled) {
                var reason = "@TimeTravel no es compatible con paralelismo global. Desactívelo o use tests separados.";
                TimeTravelLogger.LOG.error("⛔ TimeTravel VIOLATION | {}", reason);
                throw new ExtensionConfigurationException(reason);
            }
        }

        private static void failIfMultipleTimeAnnotations(Method method, Class<?> testClass) {
            long methodCount = Arrays.stream(method.getAnnotations())
                    .map(Annotation::annotationType)
                    .filter(ann -> ann == TimeTravel.class || ann.isAnnotationPresent(TimeTravel.class))
                    .count();

            if (methodCount > 1) {
                throw new ExtensionConfigurationException(
                        "Se han detectado múltiples anotaciones de tiempo en el método '" +
                                method.getName() + "'. Use solo una (@TimeTravel o meta-anotación)."
                );
            }

            long classCount = Arrays.stream(testClass.getAnnotations())
                    .map(Annotation::annotationType)
                    .filter(ann -> ann == TimeTravel.class || ann.isAnnotationPresent(TimeTravel.class))
                    .count();

            if (classCount > 1) {
                throw new ExtensionConfigurationException(
                        "Se han detectado múltiples anotaciones de tiempo en la clase '" +
                                testClass.getSimpleName() + "'. Use solo una (@TimeTravel o meta-anotación)."
                );
            }
        }

        private static void enforceStrictMode(TimeTravel tt, Method method, Class<?> testClass) {
            if (!tt.strict()) return;

            if (testClass.isAnnotationPresent(TimeTravel.class)) {
                throw new ExtensionConfigurationException(
                        "@TimeTravel(strict=true) no puede usarse a nivel de clase."
                );
            }

            if (tt.instant().isBlank()) {
                throw new ExtensionConfigurationException(
                        "@TimeTravel(strict=true) requiere un instant explícito."
                );
            }

            if (method.getAnnotations().length > 1 &&
                    testClass.isAnnotationPresent(TimeTravel.class)) {
                throw new ExtensionConfigurationException(
                        "@TimeTravel(strict=true) no permite overrides."
                );
            }
        }

        private static void logActivation(TimeTravel tt, Method method, Class<?> testClass) {
            TimeTravelLogger.LOG.info(
                    "⏳ TimeTravel ACTIVATED | instant={} | class={} | method={} | strict={}",
                    tt.instant(),
                    testClass.getSimpleName(),
                    method.getName(),
                    tt.strict()
            );
        }

        private static void logDeactivation(Method method, Class<?> testClass) {
            TimeTravelLogger.LOG.info(
                    "⏳ TimeTravel DEACTIVATED | class={} | method={}",
                    testClass.getSimpleName(),
                    method.getName()
            );
        }
    }

    final class TimeTravelLogger {
        static final Logger LOG = LoggerFactory.getLogger("testing.time.TimeTravel");
    }
}
