# Properties of Good Software

Esta es una referencia para evaluar si un diseño tiene calidad. Cada propiedad nos ayuda a判断 si el software es mantenible, robusto y escalable.

---

## 1. Inmutabilidad (Immutability)

El principio de inmutabilidad en programación se refiere a la creación de objetos cuyo estado no puede ser modificado una vez que han sido creados.

### PROS

**Menor complejidad cognitiva** al saber que no cambia (obligatorio si usas concurrencia).

**Simplicidad y Previsibilidad**: Los objetos inmutables son más fáciles de razonar, ya que su estado no cambia a lo largo del tiempo. Esto simplifica la comprensión y el seguimiento del flujo de datos y la lógica del programa.

**Seguridad en la Concurrencia**: En entornos concurrentes, los objetos inmutables son intrínsecamente seguros para usar en múltiples hilos, ya que no se pueden modificar. Esto elimina la necesidad de mecanismos de sincronización complejos, como los bloqueos (locks).

**Eficiencia en Caché**: Los objetos inmutables pueden ser fácilmente cacheados sin temer a que su estado cambie inesperadamente. Esto mejora la eficiencia y el rendimiento del sistema.

**Evita Errores Comunes**: La inmutabilidad ayuda a evitar errores comunes relacionados con cambios inesperados en el estado de los objetos, como efectos colateralos no deseados.

### CONS

**Cuidado con generar muchos objetos inmutables ya que se comerá la RAM**, ojo con las listas.

### HOW

Para conseguir esto, como he dicho, con **Builder**, **record**, **fluent API**, y también utilizando constantes:

- En JS: `const` en vez de `let`
- En Java: añadiendo `final` a casi todo

**Evitar el uso de setters** como dice Tell Don't Ask. Si un objeto cambia de estado al ejecutar un caso de uso, es algo importante, por lo tanto, se generará un nuevo objeto.

**Cuando necesitamos cambiar el valor de un objeto, simplemente creamos uno nuevo.**

### In Depth

> *"All race conditions, deadlock conditions, and concurrent update problems are due to mutable variables. You cannot have a race condition or a concurrent update problem if no variable is ever updated. You cannot have deadlocks without mutable locks."*

En otras palabras, todos los problemas que enfrentamos en aplicaciones concurrentes —todos los problemas que enfrentamos en aplicaciones que requieren múltiples hilos y múltiples procesadores— no pueden ocurrir si no hay variables mutables.

Como arquitecto, debes estar muy interesado en temas de concurrencia. quieres asegurarte de que los sistemas que diseñas serán robustos en presencia de múltiples hilos y procesadores. La pregunta que debes hacerte es si la inmutabilidad es practicable. La respuesta a esa pregunta es afirmativa, si tienes almacenamiento infinito y velocidad de procesador infineta. Careciendo de esos recursos infinitos, la respuesta es un poco más matizada. Sí, la inmutabilidad puede ser practicable, si se hacen ciertos compromisos.

**Otra desventaja de la mutabilidad es el acoplamiento temporal**: si cambio un set de lugar en una función, puedo generar un error. **Pitest** se dedica a hacer estas mutaciones para encontrar tests flojos.

---

## 2. Explicit (Ser Explícito)

Prioriza ser explícito y la cohesión funcional. Es aplicar **SRP a todos los niveles**, para ello prioriza el comportamiento.

> *No reutilices código para hacer funcionar distintos use cases.*

**Ser explícito es la mejor forma de aplicar YAGNI y KISS, pero bien aplicado también DRY (true behavior separation)**

Además, siempre puedes pasar de específico a genérico. Viceversa no.

### Dont Blot, Create His Own Space, Make It a New Citizen of Your System

- **A nivel de arquitectura**: Cada caso de uso tiene su propia clase.
- **A nivel de clase**: La clase hará sólo una cosa.
- **A nivel de tabla**: Se separa en n tablas representando lo mismo pero desde diferentes contextos.
- **A nivel de clase/método**: Mira TDD, haces lo justo y necesario, código ESPECÍFICO a ese problema, no genérico.
- **A nivel de returns**: En vez de esperar un objeto nullable, haz explícito que puede no devolverlo, con un Optional.
- **A nivel de método**: Si puede devolver un error, añadele en el nombre `OrElseThrow`

### Value Objects

Los **VOs** son inmutables porque si cambian su valor es por un caso de uso, por lo tanto tiene sentido que se tenga que crear uno nuevo.

### Eventos Explícitos

Usar eventos es una gran forma de hacer código explícito, porque dices lo que ha ocurrido (si los haces bien).

#### Ejemplo: Evento Explícito vs Implícito

```
Explicit Event, focused on domain:
→ OrderCanceled{orderId, reason, canceledBy}

Implicit Event, focused on CRUD, changed for what reason?
→ OrderUpdated{...all fields...}
```

### La mejor forma de aplicar esto es con DDD

No obstante, en un CRUD también se puede hacer a menor escala.

Para poder hacer esto, el **front también tiene que hacerse de cierta forma**: no tener un formulario gigante, sino **Task-based UI**.

### Ejemplos

```java
// ❌ Implícito - un método para muchos casos
saveCustomer(customer)

// ✅ Explícito - cada caso de uso es su propio método
createNormalCustomer(customer)
createAdminCustomer(customer)

// ❌ Implícito - genérico y ambiguo
updateOrder(order)

// ✅ Explícito - un método por caso de uso
cancelOrder(orderCanceledObj)
shipOrder(shipmentInfo)
```

```java
// ❌ Implícito - save genérico
saveDinner(dinner)

// ✅ Explícito - comportamiento claro
hostADinner(guestList, menu, date)
```

---

## 3. Indirección Justa y Necesaria (Just and Necessary Indirection)

**Indirección es todo aquello que añada un paso más entre la solución y el código.**

No todas las indirecciones tienen los mismos beneficios ni los mismos efectos negativos, o al menos, el mismo grado de ellos.

### Por regla general

> *Cuanta más indirección:*
> *Más confuso se vuelve el código, aumenta la complejidad cognitiva/mental.*

### Cuándo son útiles

**Para mejorar la testabilidad y centralizar el acoplamiento** (invierte efferent a afferent):

```
Facade → Service → Bus/Queue/Topic → Service
```

**Para encapsular complejidad o detalle técnico** detrás de una abstracción bien definida:

```
Service → Data access layer → DB
```

Esto es **horizontal layering**:
> *Una función que llama a una función que llama a una función.*

**Para hacer behavior patterns**, como pipelines o decoradores:

```
Controller → Filtro → Filtro → Mediator → Bus → Layer → Código
```

**Para añadir traducción** (Anti-Corruption Layer) y evitar acoplamiento con implementaciones externas.

### Más ejemplos

- Una **herencia o interfaz** es añadir un nivel de indirección.
- **Client → Load balancer → Instances**

### Key Insight

La indirección debe ser **justa y necesaria**. Antes de añadir una capa, pregúntate:

- ¿Realmente necesito este nivel de abstracción?
- ¿Estoy resolviendo un problema que tengo, o uno que imagino tener?
- ¿El beneficio supera la complejidad añadida?

> *Usa YAGNI como guía: no añadas indirecciones "por si acaso".*

---

## 4. Flexible (Mantener el Valor de Opción)

> *Mejor diseñar para que sea flexible que ser predecible, porque no se puede predecir el futuro.*

### Keep Your Option Value High

**Queremos Option value**, es decir, poder estar abierto a opciones, no atados a una cosa.

Por ejemplo, con el código de dominio separado del de infraestructura, tenemos más **option value** porque podemos cambiar el infrastructure a placer según nos convenga más.

### Fórmula del Option Value

```
n*k / T*p
```

| Variable | Significado |
|----------|-------------|
| **N** | Number of modules |
| **K** | Number of parallel experiments you can make in a module |
| **T** | Amount of time it takes to perform an experiment |
| **P** | The grade of uncertainty |

### Ejemplo: Amazon Monolith vs Microservices

| | Monolith | Microservices |
|--|----------|---------------|
| **N** | 1 | 100 |
| **K** | 1 | 10 |
| **T** | 365 días | 1 día |
| **P** | 100 | 10 |

**Monolith**: Un módulo, un experimento a la vez, un cambio afectaba a todo → 1 año para una feature.

**Microservices**: 100 módulos, 10 experimentos en paralelo, cambios aislados → 1 día para una feature.

> *Cuanto más option value tengamos, más experimentos podemos hacer y menor carga cognitiva.*

### Cuándo brilla más la modularidad

Si **P** es baja (todo claro), no necesitamos tanto option value. Pero cuando hay **incertidumbre** ahí es donde brilla la modularidad.

> *Flexibility depends critically on the shape of the system, the arrangement of its components, and the way those components are interconnected.*

> *The way you keep software soft is to leave as many options open as possible, for as long as possible.*

**¿Cuáles son las opciones que necesitamos dejar abiertas?** Son los detalles que no importan.

### TIPS para mantener la flexibilidad

**Identificar y dividir en bounded contexts**: Así cada uno es independiente.

**Programar orientado a comportamientos**: Exponer comportamiento, no datos.

**Separar el domain de los detalles** o cualquier cosa que sea volátil:

> *El grado de separación dependerá del acoplamiento que tengamos.*

**Técnicas concretas**:

- **Aplicar CQRS** al menos en su nivel base
- **Anti-corruption layers**
- **Inyección de dependencias**

### Resumen

| Acción | Beneficio |
|--------|-----------|
| Separar domain de infra | Cambiar implementación sin afectar dominio |
| Bounded Contexts | Aislar cambios, menor blast radius |
| CQRS | Separar lectura de escritura |
| DI | Invertir dependencias, facilitar testing |
| ACL | Traducir sin acoplarte a externa |

---

## 5. Alta Cohesión Funcional (High Functional Cohesion)

> *Las propiedades más importantes son: high functional cohesion, loosely coupled, good separation of concerns, modular and the right level of abstraction.*

**Cohesión funcional** significa que los elementos que forman parte de una misma funcionalidad están juntos, y los que son de funcionalidades diferentes están separados.

### Por qué importa

- **Fácil de entender**: Todo lo relacionado con una funcionalidad está en un solo lugar.
- **Fácil de cambiar**: Un cambio afecta solo a una funcionalidad.
- **Fácil de testar**: Puedes probar una funcionalidad de forma aislada.
- **Menor acoplamiento**: Si está bien separado, las funcionalidades no se afectan entre sí.

### Cómo lograr alta cohesión

- **Caso de uso = 1 clase**: Cada caso de uso tiene su propia clase.
- **Entidad con su comportamiento**: Los métodos que operan sobre una entidad viven con la entidad.
- **Value Objects juntos**: Los VOs que se usan juntos están en el mismo paquete.
- **Enum dentro de la clase**: Si solo se usa en una clase, el enum vive dentro de la clase.

### Señales de baja cohesión

- Clase con "and" en el nombre: `UserValidatorAndConverter`
- Métodos que no se relacionan entre sí
- Dificultad para testear un aspecto sin afectar otros

---

## 6. Acoplamiento Débil (Loosely Coupled)

El acoplamiento dice cuánto depende un componente de otro. Un sistema bien diseñado tiene **acoplamiento débil**.

### Características de acoplamiento débil

- **Cambios aislados**: Un cambio en un componente no requiere cambios en otros.
- **Fácil de testar**: Cada componente se puede testear de forma independiente.
- **Interdependencia clara**: Las dependencias son explícitas y mínimas.

### Cómo lograr acoplamiento débil

- **Depender de abstracciones**, no de concreciones.
- **Bounded Contexts claros**: Limitan el impacto de los cambios.
- **Eventos para comunicar**: En vez de llamar directamente, emite eventos.
- **Inyección de dependencias**: El cliente no crea sus dependencias.

### Cuándo el acoplamiento es aceptable

| Escenario | ¿Aceptable? |
|-----------|-------------|
| Framework code | ✅ Inevitable |
| Librería externa en un solo VO | ✅ Bajo impacto |
| Entre bounded contexts | ⚠️ Con eventos/ACL |
| Acoplamiento temporal | ⚠️ Con documentación |

> *No se trata de eliminar el acoplamiento, sino de controlarlo.*

---

## 7. Buena Separación de Responsabilidades (Good Separation of Concerns)

Cada responsabilidad debe estar en un solo lugar. Esto es **SRP aplicado a nivel de sistema**.

### Capas típicas y sus responsabilidades

| Capa | Responsabilidad |
|------|-----------------|
| **Domain** | Reglas de negocio, comportamiento |
| **Application** | Orquestación de casos de uso |
| **Infrastructure** | Detalles técnicos (DB,外部 APIs) |
| **UI** | Presentación, interacción |

### Separación vertical vs horizontal

- **Vertical**: Por funcionalidad/caso de uso. Cada caso de uso es independiente.
- **Horizontal**: Por tipo de preocupación. Todas las validaciones en un lugar, todas las consultas en otro.

> *La mejor separación es la vertical (por caso de uso), porque minimiza el impacto de los cambios.*

---

## 8. Modular

Un sistema **modular** está compuesto de piezas independientes que se pueden cambiar, reemplazar o testar por separado.

### Características de un sistema modular

- **Cada módulo tiene una responsabilidad clara**
- **Los módulos se pueden entender de forma independiente**
- **Los cambios en un módulo no afectan a otros** (si están bien aislados)
- **Los módulos se pueden recombinar** para diferentes necesidades

### Cómo lograr modularidad

- **Bounded Contexts**: Cada contexto es un módulo.
- **Paquetes claros**: La estructura de paquetes refleja la separación.
- **Interfaces explícitas**: Cada módulo expone lo que necesita.
- **Minimizar dependencias**: Solo lo necesario.

### Formula del valor de opción (para recordar)

```
Option Value = (N × K) / (T × P)
```

> *Más módulos (N) = más opciones = más flexibilidad.*

---

## 9. El Nivel Correcto de Abstracción (The Right Level of Abstraction)

> *Too little abstraction leads to duplicated code. Too much abstraction leads to lost power.*

### Señales de muy poca abstracción

- Código duplicado en múltiples lugares
- Cambios que requieren modificar muchos archivos
- Dificultad para cambiar implementaciones

### Señales de excesiva abstracción

- Interfaces que solo tienen una implementación
- Clases que solo se usan en un lugar
- Abstracciones que no añaden valor

### Cómo encontrar el nivel correcto

| Pregunta | Respuesta correcta |
|---------|-------------------|
| ¿Cuántas implementaciones hay? | Si > 1 → interfaz |
| ¿Es necesario testear de forma diferente? | Si → abstracción |
| ¿Es un detalle técnico que puede cambiar? | Si → aislar |
| ¿Se usa en un solo lugar? | Si → no abstraer |

### Regla de oro

> *Let the code force you to it. If you need it later, with the IDE it's easy to refactor a class so that the code references the new interface.*

**Empieza concreto → extrae cuando sea necesario.**



