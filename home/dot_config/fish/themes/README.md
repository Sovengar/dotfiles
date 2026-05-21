# Fish themes and HyDE

Esta carpeta queda reservada para themes propios de Fish, pero actualmente no se usa.

En esta configuracion, el cambio visual principal de la terminal viene de HyDE hacia Kitty:

```text
HyDE theme -> Kitty palette -> Fish visible colors
```

No viene directamente desde HyDE hacia Fish:

```text
HyDE theme -> Fish theme file
```

Fish puede cambiar de apariencia de forma indirecta porque usa nombres de color como `cyan`, `brblack`, `blue` o `magenta`. Esos nombres se resuelven contra la paleta activa del emulador de terminal. Si HyDE cambia el theme de Kitty, esos colores pueden verse distintos aunque la configuracion de Fish no cambie.

Usa esta carpeta solo si queres que Fish tenga colores propios independientes de Kitty/HyDE, por ejemplo para syntax highlighting, autosuggestions, pager o colores del prompt. Si queres mantener coherencia visual con HyDE, es mejor dejar que Kitty controle la paleta y mantener esta carpeta vacia.
