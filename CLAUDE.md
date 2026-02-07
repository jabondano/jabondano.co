# CLAUDE.md - jabondano.co Maintenance Rules

## Site Structure

- **Static HTML site** hosted on GitHub Pages
- No build system - edit HTML directly
- Dark theme with IBM Plex fonts

## Content Locations

| Content | File |
|---------|------|
| Homepage | `index.html` |
| Notes listing | `notes.html` |
| Individual posts | `notes/*.html` |

## Maintenance Rules

### 🔄 Homepage ↔ Notes Sync (IMPORTANT)

When adding a new post to `/notes/`:

1. **Create the post** in `notes/[slug].html`
2. **Update `notes.html`** - add entry at TOP of `.posts-list`
3. **Update `index.html`** - update "recent thoughts" section to show **3 most recent posts**

The homepage `#thoughts` section should always display the 3 most recent notes, matching the order in `notes.html`.

### Post Template

Copy an existing post from `notes/` and modify:
- `<title>` and `<meta>` tags
- `.article-date` 
- `<h1>` title
- `.article-content` body
- `.post-tags` at bottom

### Date Format

- Notes listing: `February 7, 2026`
- Homepage: `Feb 7, 2026`
- Post pages: `February 7, 2026`

## Security

Do NOT include in public posts:
- Server IPs or hostnames
- Port numbers
- API keys or tokens
- Internal system names that could aid attackers

Keep concepts and architecture, remove fingerprinting details.
