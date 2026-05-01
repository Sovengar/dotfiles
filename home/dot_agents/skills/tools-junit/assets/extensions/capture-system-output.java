@Target({TYPE, METHOD})
@Retention(RUNTIME)
@Documented
@ExtendWith(CaptureSystemOutput.Extension.class)
public @interface CaptureSystemOutput {

    class Extension implements BeforeEachCallback, AfterEachCallback, ParameterResolver {
        @Override
        public void beforeEach(ExtensionContext context) throws Exception {
            getOutputCapture(context).captureOutput();
        }

        @Override
        public void afterEach(ExtensionContext context) throws Exception {
            OutputCapture outputCapture = getOutputCapture(context);
            outputCapture.releaseOutput();
        }

        @Override
        public boolean supportsParameter(ParameterContext parameterContext, ExtensionContext extensionContext) {
            boolean isTestMethodLevel = extensionContext.getTestMethod().isPresent();
            boolean isOutputCapture = parameterContext.getParameter().getType() == OutputCapture.class;
            return isTestMethodLevel && isOutputCapture;
        }

        @Override
        public Object resolveParameter(ParameterContext parameterContext, ExtensionContext extensionContext) {
            return getOutputCapture(extensionContext);
        }

        private OutputCapture getOutputCapture(ExtensionContext context) {
            ExtensionContext.Namespace namespace = ExtensionContext.Namespace.create(getClass(), context.getRequiredTestMethod());
            ExtensionContext.Store store = context.getStore(namespace);
            return store.getOrComputeIfAbsent(OutputCapture.class);
        }
    }

    class OutputCapture {
        private CaptureOutputStream captureOut;
        private CaptureOutputStream captureErr;
        private ByteArrayOutputStream copy;

        void captureOutput() {
            this.copy = new ByteArrayOutputStream();
            this.captureOut = new CaptureOutputStream(System.out, this.copy);
            this.captureErr = new CaptureOutputStream(System.err, this.copy);
            System.setOut(new PrintStream(this.captureOut));
            System.setErr(new PrintStream(this.captureErr));
        }

        void releaseOutput() {
            System.setOut(this.captureOut.getOriginal());
            System.setErr(this.captureErr.getOriginal());
            this.copy = null;
        }

        private void flush() {
            try {
                this.captureOut.flush();
                this.captureErr.flush();
            } catch (IOException ex) {
                // ignore
            }
        }

        /**
         * Return all captured output to {@code System.out} and {@code System.err}
         * as a single string.
         */
        @Override
        public String toString() {
            flush();
            return this.copy.toString();
        }

        private static class CaptureOutputStream extends OutputStream {
            private final PrintStream original;
            private final OutputStream copy;

            CaptureOutputStream(PrintStream original, OutputStream copy) {
                this.original = original;
                this.copy = copy;
            }

            PrintStream getOriginal() {
                return this.original;
            }

            @Override
            public void write(int b) throws IOException {
                this.copy.write(b);
                this.original.write(b);
                this.original.flush();
            }

            @Override
            public void write(byte[] b) throws IOException {
                write(b, 0, b.length);
            }

            @Override
            public void write(byte[] b, int off, int len) throws IOException {
                this.copy.write(b, off, len);
                this.original.write(b, off, len);
            }

            @Override
            public void flush() throws IOException {
                this.copy.flush();
                this.original.flush();
            }
        }
    }
}
