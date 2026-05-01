# Concurrency

> **First Principle**: Sometimes the best concurrency solution is to not need concurrency.
> Redesign the workflow first before adding async processing.

## The Best Concurrency is No Concurrency

Before reaching for CompletableFuture, Virtual Threads, or parallel streams, consider if you can redesign the workflow to avoid the concurrency problem entirely.

### Example: Course Enrollment with X Slots

**The naive approach (requires concurrency):**
```java
// Try to assign all students to slots at second 0
// Race conditions everywhere!
public void enrollAll(List<Student> students, int capacity) {
    for (Student student : students) {
        if (assignSlot(student) == null) {
            // Handle failure - race condition!
        }
    }
}
```

**The better approach (no concurrency needed):**
```java
// Accept all enrollments, assign slots later (when needed)
public EnrollmentResult enroll(List<Student> students, int capacity) {
    // Just store the requests - no race condition
    repository.saveAll(students.stream()
        .map(s -> EnrollmentRequest.builder()
            .student(s)
            .status(Status.PENDING)
            .build())
        .toList());
    
    // Later, when you need to allocate:
    allocateSlots(capacity);
}

// Only runs when actually needed - no concurrency race
private void allocateSlots(int capacity) {
    List<EnrollmentRequest> pending = repository
        .findByStatusOrderByTimestamp(Status.PENDING);
    
    for (int i = 0; i < Math.min(capacity, pending.size()); i++) {
        pending.get(i).setStatus(Status.CONFIRMED);
    }
}
```

### Why This Is Better

| Aspect | Immediate Assignment | Deferred Assignment |
|--------|----------------------|---------------------|
| Race conditions | Many | None |
| Complexity | High (locks, CAS) | Low |
| Flexibility | Fixed at T=0 | Dynamic (can add more) |
| Dropouts | Must handle reallocation | Natural - just allocate next |
| Scalability | Harder | Easier |

### When Deferred Processing Works

- ✅ Batch operations that don't need immediate result
- ✅ Slot-based systems (enrollment, reservations)
- ✅ Eventual consistency is acceptable
- ✅ Work can be scheduled (cron, queue)

### When You DO Need Concurrency

- ✅ Real-time response required
- ✅ User is waiting for result
- ✅ External system needs immediate confirmation
- ✅ Rate limiting at API boundary

## CompletableFuture (Java 8+)

Use when: Async programming, composition, chaining operations

### Basic Async
```java
public CompletableFuture<User> findByIdAsync(Long id) {
    return CompletableFuture.supplyAsync(() -> repository.find(id));
}
```

### Chaining (thenApply, thenCompose, thenCombine)
```java
public CompletableFuture<String> getUserDisplayName(Long id) {
    return CompletableFuture.supplyAsync(() -> repository.find(id))
        .thenApply(user -> user.getName())
        .thenApply(name -> name.toUpperCase());
}

// thenCompose for flat mapping (returning another CompletableFuture)
public CompletableFuture<String> getUserCity(Long id) {
    return CompletableFuture.supplyAsync(() -> repository.find(id))
        .thenCompose(user -> CompletableFuture.supplyAsync(() -> user.getAddress().getCity()));
}

// thenCombine for parallel operations
public CompletableFuture<UserWithStats> getUserWithStats(Long id) {
    CompletableFuture<User> userFuture = CompletableFuture.supplyAsync(() -> repository.find(id));
    CompletableFuture<UserStats> statsFuture = CompletableFuture.supplyAsync(() -> statsService.getStats(id));
    
    return userFuture.thenCombine(statsFuture, UserWithStats::new);
}
```

### Error Handling
```java
public CompletableFuture<User> getUserSafely(Long id) {
    return CompletableFuture.supplyAsync(() -> repository.find(id))
        .exceptionally(ex -> {
            log.error("Error fetching user", ex);
            return User.DEFAULT;
        })
        .orElseThrow(() -> new UserNotFoundException(id));
}
```

## Parallel Streams (Java 8+)

Use when: CPU-bound parallel processing

### Basic Parallel
```java
List<User> users = getUsers();
List<String> names = users.parallelStream()
    .map(User::getName)
    .toList();
```

### With Reduction
```java
double averageAge = users.parallelStream()
    .mapToInt(User::getAge)
    .average()
    .orElse(0);
```

> **Warning**: Be careful with side effects in parallel streams. Use forEach only for terminal operations.

## Virtual Threads (Java 21+)

Use when: High-throughput IO-bound workloads, NOT CPU-bound

### Basic Usage
```java
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    List<CompletableFuture<String>> futures = ids.stream()
        .map(id -> CompletableFuture.supplyAsync(() -> doNetworkCall(id), executor))
        .toList();
    
    futures.forEach(CompletableFuture::join);
}
```

### With RestTemplate/HttpClient
```java
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    List<URI> urls = getUrls();
    
    executor.submit(() -> {
        for (URI url : urls) {
            HttpResponse<String> response = HttpClient.newHttpClient()
                .send(HttpRequest.newBuilder(url).GET().build(), 
                      HttpResponse.BodyHandlers.ofString());
            processResponse(response);
        }
    });
}
```

> **When NOT to use Virtual Threads:**
> - CPU-bound parallel work → Use parallel streams
> - Need ThreadLocal → Use ThreadLocal with caution
> - Blocking in tight loop → Consider ThreadPoolExecutor

## Concurrent Utilities

### StampedLock (Java 8+)
```java
private final StampedLock lock = new StampedLock();

public double read() {
    long stamp = lock.tryReadLock();
    try {
        return value;
    } finally {
        lock.unlock(stamp);
    }
}

public void write(double newValue) {
    long stamp = lock.writeLock();
    try {
        value = newValue;
    } finally {
        lock.unlock(stamp);
    }
}
```

### LongAdder (Java 8+)
```java
private final LongAdder counter = new LongAdder();

// Instead of AtomicLong
public void increment() {
    counter.increment();
}

public long getCount() {
    return counter.sum();
}
```

### ConcurrentHashMap compute methods
```java
ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();

// computeIfAbsent - atomic get-or-compute
map.computeIfAbsent("key", k -> expensiveComputation(k));

// compute - atomic update
map.compute("key", (k, v) -> (v == null) ? 1 : v + 1);

// merge - atomic combine
map.merge("key", 1, (old, newVal) -> old + newVal);
```

## Decision Matrix

| Situation | Recommended |
|-----------|-------------|
| Async IO (HTTP, DB) | Virtual Threads |
| CPU-bound processing | Parallel streams |
| Chaining async ops | CompletableFuture |
| High-contention counters | LongAdder |
| Optimistic locking | StampedLock |
| Thread-safe map operations | ConcurrentHashMap compute methods |

## Performance Tips

```java
// DON'T: Blocking inside parallel stream
users.parallelStream()
    .forEach(user -> doNetworkCall(user.getId())); // Bad!

// DO: Use Virtual Threads for IO
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    users.stream()
        .forEach(user -> executor.submit(() -> doNetworkCall(user.getId())));
}
```

## Common Mistakes

### ❌ DON'T: Using old Thread API
```java
// BAD - old API
new Thread(() -> doWork()).start();

// GOOD - modern API
Thread.ofPlatform().start(() -> doWork());
Thread.ofVirtual().start(() -> doWork());
```

### ❌ DON'T: Creating threads in a loop
```java
// BAD - creates thousands of threads
for (int i = 0; i < 10000; i++) {
    new Thread(() -> doWork(i)).start();
}

// GOOD - use executor
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    for (int i = 0; i < 10000; i++) {
        executor.submit(() -> doWork(i));
    }
}
```

### ❌ DON'T: Virtual Threads for CPU-bound work
```java
// BAD - Virtual Threads are for IO, not CPU
Thread.ofVirtual().start(() -> {
    // CPU-intensive work - not suitable!
    for (int i = 0; i < 1_000_000; i++) {
        Math.sqrt(i);
    }
});

// GOOD - use parallel streams for CPU-bound
list.parallelStream()
    .map(this::cpuIntensiveOperation)
    .toList();
```

### ❌ DON'T: Blocking inside Virtual Threads
```java
// BAD - blocks the carrier thread, reduces throughput
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    executor.submit(() -> {
        Thread.sleep(1000);  // BAD - blocks carrier
        doWork();
    });
}

// GOOD - use non-blocking IO or proper async
HttpClient client = HttpClient.newHttpClient();
HttpRequest request = HttpRequest.newBuilder(url).GET().build();
// HttpClient with virtual threads handles blocking efficiently
```

### ❌ DON'T: Using ThreadLocal with Virtual Threads
```java
// CAUTION - ThreadLocal works but be careful
ThreadLocal<String> context = new ThreadLocal<>();
Thread.ofVirtual().start(() -> {
    context.set("value");
    // ...
}); // Each VT has its own ThreadLocal

// For high throughput, consider ThreadLocalRandom instead of ThreadLocal
```

## Antipatterns

| Antipattern | Why Bad | Better Alternative |
|-------------|---------|-------------------|
| new Thread() | High overhead, limited scalability | ExecutorService |
| Thread pool with max size unlimited | OOM | Bounded pool or Virtual Threads |
| Virtual Threads for CPU-bound | Wrong tool | Parallel streams |
| Blocking in Virtual Threads | Defeats purpose | Use proper async or platform threads |
| Synchronous HTTP in parallel stream | Bad performance | Virtual Threads or async HTTP |

## Decision Matrix

| Situation | Recommended |
|-----------|-------------|
| IO-bound (HTTP, DB) | Virtual Threads |
| CPU-bound parallel processing | Parallel streams |
| One-off async task | CompletableFuture.supplyAsync() |
| Many short-lived IO tasks | Virtual Threads |
| Need ThreadLocal | Platform threads or careful with VTs |
| Blocking in tight loop | Don't use Virtual Threads |
