# Pattern Matching

## Pattern Matching for instanceof (Java 16+)

Use when: Type checking + casting in one step

### Before (Java 8-15)
```java
public void process(Object obj) {
    if (obj instanceof String) {
        String s = (String) obj;
        System.out.println(s.toUpperCase());
    }
}
```

### After (Java 16+)
```java
public void process(Object obj) {
    if (obj instanceof String s) {
        System.out.println(s.toUpperCase()); // s is already cast
    }
}
```

### With Complex Condition
```java
public void process(Object obj) {
    if (obj instanceof String s && s.length() > 5) {
        System.out.println(s.toUpperCase());
    }
}
```

## Record Patterns (Java 21+)

Use when: Nested data extraction from records

### Basic Record Pattern
```java
public record Point(int x, int y) {}

public void printPoint(Object obj) {
    if (obj instanceof Point(int x, int y)) {
        System.out.println("x=" + x + ", y=" + y);
    }
}
```

### Nested Record Patterns
```java
public record ColoredPoint(Point p, String color) {}

public void printColoredPoint(Object obj) {
    if (obj instanceof ColoredPoint(Point(int x, int y), String color)) {
        System.out.println(color + " point at (" + x + ", " + y + ")");
    }
}
```

### With var
```java
public void process(Object obj) {
    if (obj instanceof Point(var x, var y)) {
        System.out.println(x + ", " + y);
    }
}
```

## Sealed Classes (Java 17+)

Use when: Finite type hierarchy, security, exhaustive matching

### Basic Sealed Class
```java
public sealed class Shape permits Circle, Rectangle, Square {
    public abstract double area();
}

public final class Circle extends Shape {
    private final double radius;
    public Circle(double radius) { this.radius = radius; }
    @Override public double area() { return Math.PI * radius * radius; }
}

public final class Rectangle extends Shape {
    private final double width;
    private final double height;
    public Rectangle(double width, double height) {
        this.width = width;
        this.height = height;
    }
    @Override public double area() { return width * height; }
}

public final class Square extends Shape {
    private final double side;
    public Square(double side) { this.side = side; }
    @Override public double area() { return side * side; }
}
```

### Non-sealed (allow extension)
```java
public non-sealed class Rectangle extends Shape {
    // Can be extended
}
```

### Sealed Interface
```java
public sealed interface Expression permits Literal, Add, Multiply {
    double eval();
}

public final class Literal implements Expression {
    private final double value;
    public Literal(double value) { this.value = value; }
    @Override public double eval() { return value; }
}

public final class Add implements Expression {
    private final Expression left, right;
    public Add(Expression left, Expression right) {
        this.left = left;
        this.right = right;
    }
    @Override public double eval() { return left.eval() + right.eval(); }
}

// Exhaustive switch (no default needed!)
public double calculate(Expression expr) {
    return switch (expr) {
        case Literal l -> l.eval();
        case Add a -> a.eval();
        case Multiply m -> m.eval();
    };
}
```

## Decision Matrix

| Situation | Recommended |
|-----------|-------------|
| Type check + cast | Pattern matching for instanceof |
| Nested data extraction | Record patterns |
| Finite type hierarchy | Sealed classes |
| Need exhaustive matching | Sealed + switch |

## Common Mistakes

### ❌ DON'T: Using sealed without permits
```java
// BAD - compile error
public sealed class Shape { }  // Must specify permits
```

### ❌ DON'T: Forgetting all cases in sealed switch
```java
// BAD - won't compile
return switch (shape) {
    case Circle c -> c.area();
    case Rectangle r -> r.area();
    // Missing Square - compilation error
};
```

### ❌ DON'T: Pattern matching with null
```java
// BAD - NPE
if (obj instanceof String s && s.length() > 5) { }

// GOOD - handle null separately
if (obj == null) { return; }
if (obj instanceof String s && s.length() > 5) { }
```

### ❌ DON'T: Non-sealed without sealed parent
```java
// BAD - non-sealed only makes sense with sealed parent
public non-sealed class Foo { }  // Useless
```

## Antipatterns

| Antipattern | Why Bad | Better Alternative |
|-------------|---------|-------------------|
| Sealed without permits | Won't compile | Add permits clause |
| Non-sealed without sealed parent | Useless | Don't use non-sealed |
| Forgetting switch cases | Won't compile | Add all permitted cases |
| Null in pattern matching | NPE | Check null first |

## Common Patterns

### Optional + Pattern Matching
```java
public void process(Object obj) {
    if (obj instanceof String s && !s.isBlank()) {
        // Safe to use s here
    }
}
```

### Switch + Sealed (Exhaustive)
```java
public String toString(Shape shape) {
    return switch (shape) {
        case Circle c -> "Circle(r=" + c.radius() + ")";
        case Rectangle r -> "Rectangle(" + r.width() + "x" + r.height() + ")";
        case Square s -> "Square(" + s.side() + ")";
        // No default needed!
    };
}
```
