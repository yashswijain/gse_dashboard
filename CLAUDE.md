# ADMI Dashboard — Claude Context

## What this is
An interactive financial dashboard for ADMI (a Kenyan creative-arts education business).
Visualises per-semester course economics across 14 programs (6 Diplomas, 8 Certificates)
for two delivery scenarios: In-Person and Hybrid.

## File structure
```
model.xlsx              ← CONFIDENTIAL. Real Excel financial model. Never read, never commit.
data.json               ← CONFIDENTIAL. Extracted numbers. Never read, never commit.
extract_data.py         ← Reads model.xlsx → writes data.json (uses openpyxl + Excel/AppleScript)
build_dashboard.py      ← Merges data.json into dashboard_template.html → dashboard.html
dashboard_template.html ← The editable source. All HTML/CSS/JS lives here.
dashboard.html          ← The built output. Open in browser.
refresh.sh              ← Runs extract + build in one step (Mac/Linux)
refresh.bat             ← Same for Windows
README.txt              ← Full usage docs
CLAUDE.md               ← This file
```

## Workflow
1. Edit `dashboard_template.html` (or `extract_data.py` / `build_dashboard.py`)
2. Run `bash refresh.sh` to rebuild
3. Open `dashboard.html` in browser to verify

**Do not run `./refresh.sh` directly** — it lacks execute permission. Always use `bash refresh.sh`.

## Git
- Remote: https://github.com/yashswijain/gse_dashboard.git
- `model.xlsx` and `data.json` are gitignored (confidential)
- Commit all other changes after iterating

## Dashboard sections
| # | Section | What it does |
|---|---------|-------------|
| 01 | P&L Overview | 6 KPI tiles: Revenue, GP, Op Profit, Enrollment, Rev/Student, GP/Student |
| 02 | Course Scorecard | Sortable table, all 14 programs, health score + breakeven + safety margin |
| 03 | Enrollment Sensitivity | Profit vs. enrollment curve per program, with breakeven marker |
| 04 | In-Person vs. Hybrid | Side-by-side comparison, independent hybrid cost sliders |
| 05 | Cost Structure | Stacked bar, COGS % of revenue by program, sorted by margin |
| 06 | P&L Waterfall | Revenue → COGS breakdown → GP → OpEx → Operating Profit |

## Tech stack
- Pure HTML/CSS/JS — no framework, no build tools
- Chart.js 4.4.1 (CDN)
- Fonts: IBM Plex Mono, Fraunces, Inter (Google Fonts CDN)
- Python 3 + openpyxl for extraction
- AppleScript (`osascript`) to drive Excel for formula recalculation on Mac

## Key design decisions made
- **AppleScript instead of LibreOffice** for recalc — user is on Mac with Excel installed
- `data.json` excluded from git — contains real financial numbers
- Health score = 40% GP margin + 40% safety margin vs. breakeven + 20% GP contribution
- Breakeven uses contribution-margin method (fixed costs ÷ contribution per student)
- Global cost sliders (-100% to +100%) apply to both COGS and the elastic OpEx lines
- Hybrid sliders are additive on top of global sliders

## Data structure (data.json shape — do not read the file itself)
```json
{
  "In-Person": {
    "scenario": "In-Person",
    "programs": [
      {
        "name": "...",
        "revenue_lines": { "Course Price": 0, "Internship Fee": 0, ... },
        "cogs_lines": { "Direct staff costs": 0, "Rent and repairs": 0, ... },
        "enrollment": 0,
        "total_revenue_sheet": 0,
        "total_cogs_sheet": 0,
        "type": "Diploma" | "Certificate"
      }
    ],
    "opex": { "Administrative Personnel Costs": 0, ... }
  },
  "Hybrid": { ... }
}
```

## Excel model structure (do not read model.xlsx)
- Sheet `Summary`: scenario toggle at cell `C5` (values: `"In-Person"` or `"Hybrid"`)
- Sheet `Diplomas`: 6 programs in column blocks
- Sheet `Certificates`: 8 programs in column blocks
- OpEx pulled from `Summary` cells C28:C40

## Environment
- macOS, zsh
- Python 3.14 via Homebrew
- openpyxl installed (--break-system-packages)
- No LibreOffice — uses Excel via osascript for recalc
