# Docs Changelog

Esta skill unifica la generación y mantenimiento de changelogs. Transforma commits técnicos en changelogs profesionales siguiendo el formato Keep a Changelog, con workflow ejecutable para actualizaciones continuas y guías de migración para breaking changes.

## When to Use This Skill

- Preparar release notes para una nueva versión
- Crear resúmenes semanales o mensuales de actualizaciones
- Documentar cambios para clientes
- Escribir entradas para app stores
- Mantener un CHANGELOG.md actualizado continuamente
- Documentar breaking changes antes de un release
- Crear guías de migración para usuarios

## What This Skill Does

1. **Escanea historial Git**: Analiza commits de un período o entre versiones
2. **Categoriza cambios**: Agrupa en lógica (features, improvements, bug fixes, breaking changes, security)
3. **Traduce técnico → usuario**: Convierte commits de开发eros en lenguaje amigable
4. **Aplica formato profesional**: Crea entradas limpias y estructuradas
5. **Filtra ruido**: Excluye commits internos (refactoring, tests, etc.)
6. **Mantiene formato estándar**: Sigue Keep a Changelog + Semantic Versioning

## How to Use

### Basic Usage

```
Create a changelog from commits since last release
```

```
Generate changelog for all commits from the past week
```

```
Create release notes for version 2.5.0
```

### With Specific Date Range

```
Create a changelog for all commits between March 1 and March 15
```

### With Custom Guidelines

```
Create a changelog for commits since v2.4.0, using my changelog 
guidelines from CHANGELOG_STYLE.md
```

## Workflow: Actualizar Changelog

### Antes de hacer commit

1. **Leer CHANGELOG.md**. Si no existe, crearlo siguiendo el formato Keep a Changelog (sección siguiente).
2. **Obtener los commits de la feature** con:
   ```
   git log --oneline <primer_commit_de_la_feature>..HEAD
   ```
3. **Clasificar los commits por tipo**:
   - `feat:` → sección `Added`
   - `fix:` → sección `Fixed`
   - `refactor:` → no incluir en changelog (son internos)
   - `test:` → no incluir en changelog
   - `docs:` → sección `Changed` (documentation only)
   - `perf:` → sección `Changed` (performance improvements)
   - `security:` → sección `Security`
4. **Escribir la entrada bajo `## [Unreleased]`**. Si ya existe esa sección, añadir al principio de la subsección correspondiente. No eliminar entradas existentes.
5. **Formato de cada línea**: `- <descripción en imperativo, sin el scope entre paréntesis>.`

### Ejemplo de entrada generada

```markdown
## [Unreleased]

### Added
- Calculate total price including tax for taxable items.
- Support for multiple tax rates by product category.
```

## Keep a Changelog Format

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New user profile customization options
- Dark mode support

### Changed
- Improved performance of search feature

### Fixed
- Bug in password reset email

## [1.2.0] - 2025-01-15

### Added
- Two-factor authentication (2FA)
- Export user data feature (GDPR compliance)
- API rate limiting
- Webhook support for order events

### Changed
- Updated UI design for dashboard
- Improved email templates
- Database query optimization (40% faster)

### Deprecated
- `GET /api/v1/users/list` (use `GET /api/v2/users` instead)

### Removed
- Legacy authentication method (Basic Auth)

### Fixed
- Memory leak in background job processor
- CORS issue with Safari browser
- Timezone bug in date picker

### Security
- Updated dependencies (fixes CVE-2024-12345)
- Implemented CSRF protection
- Added helmet.js security headers

## [1.1.2] - 2025-01-08

### Fixed
- Critical bug in payment processing
- Session timeout issue

## [1.1.0] - 2024-12-20

### Added
- User profile pictures
- Email notifications
- Search functionality

### Changed
- Redesigned login page
- Improved mobile responsiveness

## [1.0.0] - 2024-12-01

Initial release

### Added
- User registration and authentication
- Basic profile management
- Product catalog
- Shopping cart
- Order management

[Unreleased]: https://github.com/username/repo/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/username/repo/compare/v1.1.2...v1.2.0
[1.1.2]: https://github.com/username/repo/compare/v1.1.0...v1.1.2
[1.1.0]: https://github.com/username/repo/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/username/repo/releases/tag/v1.0.0
```

## Semantic Versioning

**Version number**: `MAJOR.MINOR.PATCH`

```
Given a version number MAJOR.MINOR.PATCH, increment:

MAJOR (1.0.0 → 2.0.0): Breaking changes
  - API changes break existing code
  - Example: adding required parameters, changing response structure

MINOR (1.1.0 → 1.2.0): Backward-compatible features
  - Add new features
  - Existing functionality continues to work
  - Example: new API endpoints, optional parameters

PATCH (1.1.1 → 1.1.2): Backward-compatible bug fixes
  - Bug fixes
  - Security patches
  - Example: fixing memory leaks, fixing typos
```

**Examples**:

- `1.0.0` → `1.0.1`: bug fix
- `1.0.1` → `1.1.0`: new feature
- `1.1.0` → `2.0.0`: Breaking change

## Release Notes (User-Friendly)

```markdown
# Release Notes v1.2.0
**Released**: January 15, 2025

## 🎉 What's New

### Two-Factor Authentication
You can now enable 2FA for enhanced security. Go to Settings > Security to set it up.

![2FA Setup](https://example.com/images/2fa.png)

### Export Your Data
We've added the ability to export all your data in JSON format. Perfect for backing up or migrating your account.

## ✨ Improvements

- **Faster Search**: Search is now 40% faster thanks to database optimizations
- **Better Emails**: Redesigned email templates for a cleaner look
- **Dashboard Refresh**: Updated UI with modern design

## 🐛 Bug Fixes

- Fixed a bug where password reset emails weren't being sent
- Resolved timezone issues in the date picker
- Fixed memory leak in background jobs

## ⚠️ Breaking Changes

If you're using our API:

- **Removed**: Basic Authentication is no longer supported
  - **Migration**: Use JWT tokens instead (see [Auth Guide](docs/auth.md))

- **Deprecated**: `GET /api/v1/users/list`
  - **Migration**: Use `GET /api/v2/users` with pagination

## 🔒 Security

- Updated all dependencies to latest versions
- Added CSRF protection to all forms
- Implemented security headers with helmet.js

## 📝 Full Changelog

See [CHANGELOG.md](CHANGELOG.md) for complete details.

---

**Upgrade Instructions**: [docs/upgrade-to-v1.2.md](docs/upgrade-to-v1.2.md)
```

## Breaking Changes & Migration

```markdown
# Migration Guide: v1.x to v2.0

## Breaking Changes

### 1. Authentication Method Changed

**Before** (v1.x):
````javascript
fetch('/api/users', {
  headers: {
    'Authorization': 'Basic ' + btoa(username + ':' + password)
  }
});
````

**After** (v2.0):
````javascript
// 1. Get JWT token
const { accessToken } = await fetch('/api/auth/login', {
  method: 'POST',
  body: JSON.stringify({ email, password })
}).then(r => r.json());

// 2. Use token
fetch('/api/users', {
  headers: {
    'Authorization': 'Bearer ' + accessToken
  }
});
````

### 2. User List API Response Format

**Before** (v1.x):
````json
{
  "users": [...]
}
````

**After** (v2.0):
````json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}
````

**Migration**:
````javascript
// v1.x
const users = response.users;

// v2.0
const users = response.data;
````

## Deprecation Timeline

- v2.0 (Jan 2025): Basic Auth marked as deprecated
- v2.1 (Feb 2025): Warning logs for Basic Auth usage
- v2.2 (Mar 2025): Basic Auth removed
```

## Output Format

```text
CHANGELOG.md             # Developer-facing detailed log
RELEASES.md              # User-facing release notes
docs/migration/
  ├── v1-to-v2.md        # Migration guide
  └── v2-to-v3.md
```

## Constraints

### Required rules (MUST)

1. **Reverse chronological**: latest version at the top
2. **Include dates**: ISO 8601 format (YYYY-MM-DD)
3. **Categorize entries**: Added, Changed, Fixed, Deprecated, Removed, Security
4. **Write in imperative**: "Add feature" not "Added feature" or "Adding feature"

### Prohibited items (MUST NOT)

1. **No copying Git logs directly**: write from the user's perspective
2. **Vague wording**: "Bug fixes", "Performance improvements" (be specific)
3. **Internal commits in public changelog**: exclude refactor, test, chore, docs (build)
4. **Breaking changes undocumented**: always provide migration guide

## Tips

- Run from your git repository root
- Specify date ranges for focused changelogs
- Use your CHANGELOG_STYLE.md for consistent formatting
- Review and adjust the generated changelog before publishing
- Save output directly to CHANGELOG.md
- Update CHANGELOG.md before each commit (workflow section)
- Follow Semantic Versioning strictly for version bumps
- Provide migration guides for any breaking change

## Example

**User**: "Create a changelog for commits from the past 7 days"

**Output**:

```markdown
# Updates - Week of March 10, 2024

## ✨ New Features

- **Team Workspaces**: Create separate workspaces for different 
  projects. Invite team members and keep everything organized.

- **Keyboard Shortcuts**: Press ? to see all available shortcuts. 
  Navigate faster without touching your mouse.

## 🔧 Improvements

- **Faster Sync**: Files now sync 2x faster across devices
- **Better Search**: Search now includes file contents, not just titles

## 🐛 Fixes

- Fixed issue where large images wouldn't upload
- Resolved timezone confusion in scheduled posts
- Corrected notification badge count
```

## Related Use Cases

- Creating GitHub release notes
- Writing app store update descriptions
- Generating email updates for users
- Creating social media announcement posts

## References

- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)