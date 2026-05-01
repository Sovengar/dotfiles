# Spring Boot - Security Best Practices

## When to Use

- Implementing authentication in Spring Boot
- Setting up authorization rules
- Protecting endpoints
- JWT, OAuth, or other security mechanisms

---

## Critical Patterns

### 1. Method-Level Security with @PreAuthorize

**DO:** Use method-level security for fine-grained access control.

```java
@Service
@RequiredArgsConstructor
public class UserService {
    
    private final UserRepository userRepository;
    
    @PreAuthorize("hasRole('ADMIN')")
    public void deleteUser(Long userId) {
        userRepository.deleteById(userId);
    }
    
    @PreAuthorize("#userId == authentication.principal.id or hasRole('ADMIN')")
    public User updateUser(Long userId, UserUpdateRequest request) {
        // ...
    }
    
    @PreAuthorize("hasAnyRole('ADMIN', 'USER')")
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }
}
```

**Enable method security:**
```java
@SpringBootApplication
@EnableMethodSecurity
public class Application { }
```

### 2. Don't Expose Sensitive Data in Responses

**DO:** Use DTOs that exclude sensitive fields.

```java
// Entity with sensitive data
@Entity
public class User {
    @Id
    private Long id;
    private String email;
    private String password;  // NEVER exposed
    private String role;
    private boolean active;
}

// DTO for API response
public record UserResponse(
    Long id,
    String email,
    String role,
    boolean active
) { }
```

**DON'T:** Return entities directly.

```java
// BAD: Exposes password and internal fields
@PostMapping("/users")
public User createUser(@RequestBody User user) {
    return userRepository.save(user);  // NEVER return entity directly
}
```

### 3. Input Validation for Security

**DO:** Validate all inputs, use `@Valid`.

```java
@RestController
@RequiredArgsConstructor
public class AuthController {
    
    private final AuthService authService;
    
    @PostMapping("/auth/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }
}

public record LoginRequest(
    @NotBlank @Email
    String email,
    
    @NotBlank @Size(min = 8, max = 100)
    String password
) { }
```

### 4. Use Security Configuration Properly

```java
@Configuration
@RequiredArgsConstructor
public class SecurityConfig {
    
    private final JwtAuthenticationFilter jwtFilter;
    private final CustomUserDetailsService userDetailsService;
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/auth/**").permitAll()
                .requestMatchers("/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated())
            .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
}
```

---

## Anti-Patterns to Avoid

### ❌ Skip Authorization Checks

```java
// BAD: No authorization check
@PostMapping("/users/{id}")
public void deleteUser(@PathVariable Long id) {
    userRepository.deleteById(id);  // Anyone can delete any user!
}
```

### ❌ Return Raw Entities

```java
// BAD: Exposes sensitive data
@GetMapping("/users/{id}")
public User getUser(@PathVariable Long id) {
    return userRepository.findById(id).orElseThrow();  // Exposes password!
}
```

### ❌ Store Passwords Plain

```java
// BAD: Plain text password storage
@Bean
public UserDetailsService userDetailsService() {
    return username -> userRepository.findByEmail(username)
        .map(user -> User.builder()
            .username(user.getEmail())
            .password(user.getPassword())  // WRONG: Must be encoded
            .roles(user.getRole())
            .build());
}
```

---

## Common Patterns

### JWT Token Handling

```java
@Component
@RequiredArgsConstructor
public class JwtService {
    
    @Value("${jwt.secret}")
    private String secretKey;
    
    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }
    
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }
    
    public boolean isTokenValid(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        return username.equals(userDetails.getUsername()) && !isTokenExpired(token);
    }
}
```

---

## Commands

```bash
# Enable debug logging for security
logging.level.org.springframework.security=DEBUG
```

---

## Resources

- **Spring Security Docs**: https://docs.spring.io/spring-security/reference/
- **OAuth 2.0**: https://docs.spring.io/spring-security/reference/servlet/oauth2/index.html
