# Collections

## Classic for loop

Use when: You need index, need to break early, or maximum performance

```java
// With index
for (int i = 0; i < list.size(); i++) {
    System.out.println(i + ": " + list.get(i));
}

// Need to break early
for (User user : users) {
    if (user.getName().equals("Alice")) {
        found = user;
        break;  // Can't break from forEach!
    }
}

// Modify during iteration (with caution)
for (int i = 0; i < list.size(); i++) {
    if (shouldRemove(list.get(i))) {
        list.remove(i);
        i--;  // Adjust index
    }
}
```

## forEach + lambda

Use when: Simple iteration, no early exit needed

```java
// Simple iteration
users.forEach(user -> System.out.println(user.getName()));

// Method reference
users.forEach(System.out::println);
```

## Stream API

Use when: Data transformation, filtering, aggregations

```java
// Filter + transform + collect
List<String> names = users.stream()
    .filter(u -> u.isActive())
    .map(User::getName)
    .sorted()
    .toList();

// Aggregation
int totalAge = users.stream()
    .mapToInt(User::getAge)
    .sum();

// Grouping
Map<String, List<User>> byCity = users.stream()
    .collect(groupingBy(User::getCity));
```

## Immutable Collections (Java 9+)

Use when: Collection must not change

### List.of(), Set.of(), Map.of()
```java
// Fixed-size, immutable lists
List<String> IMMUTABLE_NAMES = List.of("Alice", "Bob", "Charlie");

// Empty immutable collections
List<String> empty = List.of();

// Set of unique elements
Set<Integer> numbers = Set.of(1, 2, 3);

// Map with fixed entries
Map<String, Integer> ages = Map.of("Alice", 30, "Bob", 25);
```

> **Note**: These throw UnsupportedOperationException if modified.

### CopyOf
```java
List<String> original = new ArrayList<>();
original.add("a");

List<String> immutableCopy = List.copyOf(original);
// or
List<String> unmodifiableCopy = Collections.unmodifiableList(original);
```

## Collection.toList() (Java 16+)

Use when: Creating immutable copy of collection

```java
// Java 8-15
List<String> copy = new ArrayList<>(original);

// Java 16+
List<String> copy = original.toList();
```

## Stream.takeWhile/dropWhile (Java 9+)

Use when: Early stream termination

### takeWhile - take elements while condition is true
```java
List<Integer> numbers = List.of(1, 2, 3, 4, 5, 1, 2);

// Takes until first element fails condition
List<Integer> result = numbers.stream()
    .takeWhile(n -> n < 4)
    .toList();  // [1, 2, 3]
```

### dropWhile - skip elements while condition is true
```java
List<Integer> result = numbers.stream()
    .dropWhile(n -> n < 4)
    .toList();  // [4, 5, 1, 2]
```

## Stream.ofNullable() (Java 9+)

Use when: Avoiding null in streams

```java
// Before: null handling
users.stream()
    .map(User::getName)
    .filter(Objects::nonNull)
    .toList();

// After: handle optional null
users.stream()
    .flatMap(u -> Stream.ofNullable(u.getName()))
    .toList();
```

## Stream.iterate with Predicate (Java 9+)

```java
// Iterate with condition
Stream.iterate(1, n -> n < 10, n -> n + 1)
    .forEach(System.out::println);  // 1, 2, 3, ..., 9
```

## Sequenced Collections (Java 21+)

Use when: When order/first/last matter

### Basic Usage
```java
SequencedCollection<String> list = new ArrayList<>();
list.addFirst("first");    // [first]
list.addLast("last");      // [first, last]

String first = list.getFirst();  // "first"
String last = list.getLast();    // "last"

list.removeFirst();
list.removeLast();
```

### Reversed
```java
SequencedCollection<String> reversed = list.reversed();
```

### SequencedSet and SequencedMap
```java
SequencedSet<String> set = new LinkedHashSet<>();
set.addFirst("a");

SequencedMap<String, Integer> map = new LinkedHashMap<>();
map.putFirst("one", 1);
map.putLast("three", 3);

String firstKey = map.firstKey();
String lastKey = map.lastKey();
```

## Collection Methods (Java 8+)

### removeIf
```java
list.removeIf(s -> s.isEmpty());
```

### replaceAll
```java
list.replaceAll(String::toUpperCase);
```

### sort
```java
list.sort(Comparator.naturalOrder());
```

## Decision Matrix

| Situation | Recommended | Why |
|-----------|-------------|-----|
| Need to break early | Classic for loop | forEach can't break |
| Need index access | Classic for loop | No index in forEach |
| Simple iteration | forEach | More readable |
| Data transformation | Stream | Chain operations cleanly |
| Filter + aggregate | Stream | Built-in methods |
| Max performance | Classic for loop | Least overhead |

## Performance Notes

```java
// List.of() is NOT ArrayList - it's a different implementation
// Use for small, fixed collections only

// For mutable lists with initial data:
List<String> list = new ArrayList<>(List.of("a", "b", "c"));
```

## Quick Reference

```
Iteration Type Selection:

┌─────────────────────────────────────────────┐
│ Need to break early?                        │
│   YES → for loop (classic)                 │
│   NO  ↓                                     │
├─────────────────────────────────────────────┤
│ Need index?                                 │
│   YES → for loop (classic)                 │
│   NO  ↓                                     │
├─────────────────────────────────────────────┤
│ Just iterating?                             │
│   YES → forEach                            │
│   NO  ↓                                     │
├─────────────────────────────────────────────┤
│ Transform/filter/aggregate?                 │
│   YES → Stream API                         │
│   NO  → forEach                            │
└─────────────────────────────────────────────┘
```

## Common Mistakes

### ❌ DON'T: Mutating external variables in forEach

```java
// BAD - forEach should be side-effect free
int sum = 0;
list.forEach(n -> sum += n);  // Modifies external variable!

// GOOD - use Stream with reduce/sum
int sum = list.stream().mapToInt(Integer::intValue).sum();
int sum = list.stream().reduce(0, Integer::sum);
```

### ❌ DON'T: Using forEach for everything

```java
// BAD - forEach with complex logic is hard to read
list.forEach(item -> {
    if (item.isActive()) {
        process(item);
        log.info("Processed " + item.getName());
    }
});

// GOOD - use traditional for when logic is complex
for (Item item : list) {
    if (item.isActive()) {
        process(item);
        log.info("Processed " + item.getName());
    }
}
```

### ❌ DON'T: Using streams where simple iteration is better

```java
// BAD - overkill for simple iteration
list.stream().forEach(System.out::println);

// GOOD - forEach directly on collection
list.forEach(System.out::println);
```

### ❌ DON'T: Creating streams for single operations

```java
// BAD
list.stream().filter(x -> x > 0).findFirst().orElse(null);

// GOOD - use collection methods directly
list.stream().filter(x -> x > 0).findFirst();
// or if you need Optional
list.stream().filter(x -> x > 0).findFirst().orElse(null);
```

### ❌ DON'T: Mixing for loop with streams

```java
// BAD - confusing
for (int i = 0; i < list.size(); i++) {
    final int idx = i;
    list.stream().skip(idx).findFirst().ifPresent(this::process);
}

// GOOD - pick one approach
```

## Antipatterns

| Antipattern | Why Bad | Better Alternative |
|-------------|---------|-------------------|
| forEach with mutation | Side effects, hard to debug | Stream.reduce() or collect() |
| Stream for single iteration | Overhead | forEach directly |
| Nested streams (flatMap in flatMap) | Performance hit | Traditional loops |
| Stream for side-effect only | Misuse of functional style | forEach directly on collection |
| forEach return value | Returns void, chains don't work | Use map/filter then collect |
