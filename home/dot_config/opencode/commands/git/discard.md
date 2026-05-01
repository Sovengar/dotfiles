---
description: >
  Descarta cambios locales (git checkout) y registra la decisión 
  en engram como "mala solución" para no repetir el mismo error.
agent: general
model: opencode/minimax-m2.5-free
---

Recibe un parámetro $reason que es el motivo por el cual se descartan los cambios.

## ⚠️ Aviso IMPORTANTE

**Únicamente se van a eliminar los cambios NO commiteados.**
Los commits existentes NO se ven afectados.

## Flujo de Ejecución

### Paso 1: Mostrar estado actual

```bash
git status --porcelain
git diff --stat
```

Mostrar cuántos archivos tienen cambios y serán eliminados.

### Paso 2: Ejecutar git checkout

```bash
git checkout .
```

### Paso 3: Registrar en engram

Guardar como observación de aprendizaje:

```markdown
**What**: Descarté cambios locales - razón: {reason}
**Why**: Esta no era la solución correcta / El usuario no entendió bien el enfoque
**Where**: Repo actual
**Learned**: No repetir este approach - buscar mejor solución
```

**Tipo**: `learning`
**Título**: `Descarté cambios locales - {reason}`

---

## Notas

- El parámetro `$reason` se usa para documentar el aprendizaje
- Se guarda en engram para que el sistema no vuelva a sugerir discard como solución
- Útil para sesiones de debugging donde se prueba un approach que no funciona