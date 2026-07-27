# Referencia: Extraer Cuando Crece

> *"The intuition asks us to extract and isolate, we must listen to it. Isolation allows us to keep flexibility (optionality) high. The secret is doing it with head."*

## When to Extract

> *"After applying YAGNI and KISS, we'll have code to solve the current problem. When needs change or complexity increases and it's time to prune, the ideal is to do it all together and extract when it grows, identifying responsibilities."*

## Apply at All Levels

| Level | Before | After |
|-------|--------|-------|
| **Function** | One large function | Several mini-functions |
| **Class** | One class with multiple responsibilities | Subclasses following SRP |
| **Domain Model** | One model for everything | Multiple models (OrdersInvoice, OrdersShipping) |
| **Module** | One large module | Submodules |
| **Service** | One monolithic service | Microservices |

## Vertical Extractions

> *"Instead of coupling OrderService and DeliveryService, extract an AlertService with better SRP. The same with CompositeOrderService - it's a more specific class with better SRP."*

**Example:**

```java
// ❌ BEFORE - OrderService has too many responsibilities
public class OrderService {
    public void createOrder(Order order) { ... }
    public void sendEmail(Order order) { ... }          // Alert logic
    public void notifyDelivery(Order order) { ... }     // Alert logic
    public void updateInventory(Order order) { ... }     // Delivery logic
}
// ✅ AFTER - Vertical extraction, each with SRP
public class OrderService {
    public void createOrder(Order order) { ... }
    public void updateInventory(Order order) { ... }
}
public class AlertService {  // Extracted - better SRP
    public void sendEmail(Order order) { ... }
    public void notifyDelivery(Order order) { ... }
}
public class CompositeOrderService {  // Orchestrates, doesn't do the work
    private final OrderService orderService;
    private final AlertService alertService;
    private final InventoryService inventoryService;
    
    public void processOrder(Order order) {
        orderService.createOrder(order);
        inventoryService.updateInventory(order);
        alertService.sendEmail(order);
    }
}
```

> *"Generally, this happens when 2 use cases need certain concrete functionality. In this case, AlertService would go in the domain layer."*

## Horizontal Extractions

> *"Consists of dividing a class into 2, with the same level of abstraction. Ctrl x Ctrl v. The domain model the same - I make the enums inside the class that uses them. At the moment it's shared, extract the enum."*

### Enums

```java
// ❌ BAD - Extracted too early
// File: common/enums/ProductStatus.java
public enum ProductStatus { DRAFT, ACTIVE, INACTIVE }
// ✅ GOOD - Keep inside until shared
@Entity
public class Product {
    public enum Status {
        DRAFT,
        ACTIVE,
        INACTIVE
    }
}
// ✅ EXTRACT WHEN SHARED
// File: _shared/domain/catalogs/ProductStatus.java
public enum ProductStatus { DRAFT, ACTIVE, INACTIVE }
```

### Database Catalogs

> *"The catalogs in DB the same - if only one table is going to use it, it can stay inside the table. As soon as it needs to be used by several tables, extract to its own table so it can be shared with the n tables."*

```sql
-- ❌ BEFORE - Embedded in table
CREATE TABLE orders (
    id UUID PRIMARY KEY,
    status VARCHAR(20) NOT NULL,  -- Only used by orders
    ...
);
-- ✅ AFTER - Extracted when shared
CREATE TABLE order_statuses (  -- Shared catalog
    code VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
CREATE TABLE orders (
    id UUID PRIMARY KEY,
    status_code VARCHAR(20) REFERENCES order_statuses(code),
    ...
);
```

## The Secret: Do It With Head

| Don't Extract | Do Extract |
|---------------|------------|
| Preemptively "for future" | When you actually need it |
| Abstract for abstraction's sake | When there's a clear boundary |
| Create interfaces early | When you have multiple implementations |
| Split just to split | When responsibilities are clear |

> **Key**: Apply YAGNI and KISS first → get code that solves the problem → extract when it grows and complexity increases → identify clear responsibilities
