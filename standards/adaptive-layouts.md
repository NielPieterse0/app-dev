# Adaptive Layout Standard

Design one product experience that adapts across desktop, tablet, Android, and iOS.

## Layout Primitives

Every app should define these reusable layout modules before feature work expands:

- `AppShell`: top-level app frame, theme, providers, route outlet
- `NavigationShell`: sidebar on desktop, bottom tabs or drawer on mobile
- `PageHeader`: title, primary actions, breadcrumbs/status where needed
- `ListDetailLayout`: list/table plus detail panel; collapses to stacked navigation on mobile
- `FormLayout`: predictable label, validation, actions, and responsive field grouping
- `DataTableLayout`: toolbar, filters, table, pagination, empty/loading/error states
- `SettingsLayout`: section navigation and forms

## Breakpoints

Use component-driven layout where possible. Prefer container queries for reusable modules and viewport breakpoints for app shell decisions.

Minimum required checks:

- Desktop: 1440px wide
- Laptop: 1280px wide
- Tablet: 768px wide
- Mobile: 390px wide

## Rules

- No overlapping text or controls.
- No horizontal overflow on mobile.
- Primary actions remain reachable on mobile.
- Tables provide a mobile strategy: priority columns, stacked rows, or detail drill-in.
- Sidebars collapse into drawer/bottom navigation.
- Modal-heavy flows use sheets/drawers on mobile when appropriate.
