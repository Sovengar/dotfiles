@Target({ TYPE, METHOD })
@Retention(RUNTIME)
@Documented
@TimeTravel(instant = "2026-01-01T00:00:00Z")
public @interface FrozenAtStartOfYear2026 {
}

@Target({ TYPE, METHOD })
@Retention(RUNTIME)
@Documented
@TimeTravel(instant = "2030-01-01T12:00:00Z")
public @interface FrozenAtNoonUTC {
}

@Target({ TYPE, METHOD })
@Retention(RUNTIME)
@Documented
@TimeTravel(instant = "1970-01-01T00:00:00Z")
public @interface FrozenAtEpoch {
}

@Target({ ElementType.TYPE, ElementType.METHOD })
@Retention(RetentionPolicy.RUNTIME)
@Documented
@ExtendWith(DisableTimeTravel.Extension.class)
public @interface DisableTimeTravel {

    final class Extension implements InvocationInterceptor {

        @Override
        public void interceptTestMethod(
                Invocation<Void> invocation,
                ReflectiveInvocationContext<Method> ctx,
                org.junit.jupiter.api.extension.ExtensionContext ext
        ) throws Throwable {
            invocation.proceed();
        }
    }
}
