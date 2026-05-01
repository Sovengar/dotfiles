# Referencia: YAGNI y KISS

## YAGNI (You Aren't Gonna Need It)

Don't add functionality until it's necessary.

> *"This principle recommends not implementing features until they are absolutely necessary. Anticipating future needs can lead to excess code and unnecessary complications."*

### When to Apply

- Don't build abstraction layers "just in case"
- Don't create utility classes for one-off logic
- Don't add parameters that "might be useful"

### When to Ignore

- When the cost of change is very high later
- When designing clear interfaces that will be implemented multiple times
- When the pattern is well-established and low-cost

## KISS (Keep It Simple, Stupid)

> *"The KISS principle suggests that systems should be as simple as possible. Unnecessary complexity should be avoided, as a simple design facilitates understanding, maintenance, and error reduction."*

### Simple vs Simple-minded

| Simple | Simple-minded |
|--------|---------------|
| Solves the problem cleanly | Avoids solving the problem properly |
| Easy to understand and maintain | Hard to understand, hides problems |
| Few concepts, well-organized | Missing important logic |
| Elegant solution | Naive solution |

### How to Apply KISS

1. **Prefer composition over inheritance** - simpler, more flexible
2. **Small, focused methods** - easier to understand and test
3. **Explicit over implicit** - clear intent, no magic
4. **Solve the problem, not the abstraction** - don't over-engineer
5. **If it's complicated, simplify** - complexity is the enemy

### Example

```java
// ❌ Simple-minded - avoids logic, creates bugs
public boolean isAdult(User user) {
    return true;  // Wrong! Pretends problem doesn't exist
}
// ❌ Over-engineered - KISS violation
public class UserAgeChecker {
    private AgeValidator ageValidator;
    private DateCalculator dateCalculator;
    private UserAgeRepository userAgeRepository;
    
    public boolean isAdult(User user) {
        // 50 lines of complexity for a simple check
    }
}
// ✅ KISS - simple, clear, solves the problem
public boolean isAdult(LocalDate birthDate) {
    return Period.between(birthDate, LocalDate.now()).getYears() >= 18;
}
```
