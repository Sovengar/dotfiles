---
name: frontend-performance-profiling
description: >
  Frontend performance profiling - Core Web Vitals, bundle analysis, runtime profiling.
  Measure, analyze, optimize - in that order.
tags: [frontend, performance, profiling, web-vitals, bundle]
triggers: [frontend-performance, performance, profiling, lighthouse, bundle-size, slow-load, web-performance]
---

# Frontend Performance Profiling

> Measure, analyze, optimize - in that order.

---

## 1. Core Web Vitals

### Targets

| Metric | Good | Poor | Measures |
|--------|------|------|----------|
| **LCP** | < 2.5s | > 4.0s | Loading performance |
| **INP** | < 200ms | > 500ms | Interactivity |
| **CLS** | < 0.1 | > 0.25 | Visual stability |

### When to Measure

| Stage | Tool |
|-------|------|
| Development | Local Lighthouse, DevTools |
| CI/CD | Lighthouse CI |
| Production | RUM (Real User Monitoring) |

---

## 2. Profiling Workflow

### The 4-Step Process

```
1. BASELINE → Measure current state
2. IDENTIFY → Find the bottleneck
3. FIX → Make targeted change
4. VALIDATE → Confirm improvement
```

### Tool Selection by Problem

| Problem | Tool |
|---------|------|
| Page load | Lighthouse |
| Bundle size | Bundle analyzer (webpack, vite, rollup) |
| Runtime | DevTools Performance |
| Memory | DevTools Memory |
| Network | DevTools Network |

---

## 3. Bundle Analysis

### What to Look For

| Issue | Indicator |
|-------|-----------|
| Large dependencies | Top of bundle |
| Duplicate code | Multiple chunks |
| Unused code | Low tree-shaking coverage |
| Missing splits | Single large chunk |

### Optimization Actions

| Finding | Action |
|---------|--------|
| Big library | Import specific modules only |
| Duplicate deps | Dedupe, update versions |
| Route in main | Code split per route |
| Unused exports | Enable tree shaking |
| Large images | Optimize/compress |

---

## 4. Runtime Profiling

### Performance Tab Analysis

| Pattern | Meaning | Action |
|---------|---------|--------|
| Long tasks (>50ms) | UI blocking | Break up task |
| Many small tasks | Possible batching | Batch updates |
| Layout thrashing | Forced reflows | Batch DOM reads/writes |
| Script execution | JS heavy | Optimize or defer |

### Memory Tab Analysis

| Pattern | Meaning | Action |
|---------|---------|--------|
| Growing heap | Memory leak | Find retained refs |
| Large retained | Memory retention | Check closures |
| Detached DOM | Not cleaned | Proper cleanup |

---

## 5. Common Bottlenecks

### By Symptom

| Symptom | Likely Cause | Solution |
|---------|--------------|-----------|
| Slow initial load | Large JS, render blocking | Code split, defer |
| Slow interactions | Heavy event handlers | Debounce, optimize |
| Jank during scroll | Layout thrashing | Batch reads/writes |
| Growing memory | Leaks, retained refs | Clean up |

---

## 6. Quick Win Priorities

| Priority | Action | Impact |
|----------|--------|--------|
| 1 | Enable compression (gzip/brotli) | High |
| 2 | Lazy load images | High |
| 3 | Code split routes | High |
| 4 | Cache static assets | Medium |
| 5 | Optimize images (WebP/AVIF) | Medium |

---

## 7. Anti-Patterns

| ❌ Don't | ✅ Do |
|----------|-------|
| Guess at problems | Profile first |
| Micro-optimize | Fix biggest issue |
| Optimize early | Optimize when needed |
| Ignore real users | Use RUM data |
| Block rendering | Defer non-critical JS |

---

## 8. Lighthouse Integration

### Running Lighthouse

```bash
# CLI
lighthouse https://example.com --output=json --output-path=report.json

# Chrome DevTools
F12 → Lighthouse → Analyze page load
```

### Key Metrics to Watch

| Metric | Threshold Good | Threshold Poor |
|--------|----------------|----------------|
| Performance | 90+ | < 50 |
| Accessibility | 90+ | < 50 |
| Best Practices | 90+ | < 50 |
| SEO | 90+ | < 50 |

---

> **Remember:** The fastest code is code that doesn't run. Remove unused code before optimizing.
