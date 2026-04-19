# ADMI Course Economics Dashboard

A self-contained HTML dashboard for executive review of ADMI's per-semester
course economics. Reads data extracted from the financial model Excel file
and renders interactive KPIs, course rankings, breakeven analysis, scenario
comparisons, and a P&L waterfall.

-------------------------------------------------------------------------------
WHAT'S IN THIS BUNDLE
-------------------------------------------------------------------------------

  dashboard.html           The finished dashboard. Open in any browser.
                           Currently built against SYNTHETIC numbers so you
                           can see how it looks. Swap in real numbers via
                           the steps below.

  extract_data.py          Reads your Excel model (In-Person AND Hybrid
                           scenarios) and writes data.json.

  build_dashboard.py       Merges data.json into dashboard_template.html
                           to produce dashboard.html.

  dashboard_template.html  The HTML/CSS/JS template (what extractor fills).

  data.json                Current dashboard data (structure + numbers).

  refresh.sh / refresh.bat Convenience scripts that do extract + build in
                           one command.

-------------------------------------------------------------------------------
HOW TO SWAP THE SANITIZED FILE FOR THE REAL FILE (the one with live data)
-------------------------------------------------------------------------------

PREREQUISITES (one-time)

  You need Python 3 and LibreOffice installed on your machine.

    * Python:       https://www.python.org/downloads/  (3.9 or newer)
    * LibreOffice:  https://www.libreoffice.org/download/  (free)

  Then install the Python dependency:

    pip install openpyxl

  LibreOffice is used headlessly to recalculate formulas after we toggle
  the In-Person / Hybrid switch in the model. You do not open it manually.

WORKFLOW

  1. Place the REAL Excel file in this folder. It must have the SAME
     structure as the sanitized one — same sheet names, same cell layout,
     same formulas. (We confirmed your model already does.) Rename it
     exactly to:

        model.xlsx

     (Or keep its original name and pass the path as an argument — see
     "advanced usage" below.)

  2. Run the refresh script:

        macOS / Linux:  ./refresh.sh
        Windows:        refresh.bat

     This does two things:
       (a) extracts numbers from model.xlsx into data.json
       (b) rebuilds dashboard.html with those numbers

  3. Open dashboard.html in your browser. Done.

  If you make further changes to the Excel model later, repeat steps 1-3.
  Nothing persists between runs — each refresh re-reads the file from
  scratch, so there's no stale data to worry about.

-------------------------------------------------------------------------------
VERIFYING THE REFRESH WORKED
-------------------------------------------------------------------------------

When you run the refresh, the terminal will print something like:

    Reading: model.xlsx
      Extracting In-Person scenario...
      Extracting Hybrid scenario...
    Wrote: data.json
      In-Person: Revenue=XXX,XXX,XXX  COGS=XXX,XXX,XXX  OpEx=X,XXX,XXX
      Hybrid:    Revenue=XXX,XXX,XXX  COGS=XXX,XXX,XXX  OpEx=X,XXX,XXX
    Built: dashboard.html  (XX,XXX bytes)

Check that the Revenue / COGS / OpEx totals match what you see in your
Summary tab (C24, and the Operating Expenses block). If they do, the
dashboard is wired to your real numbers correctly.

If any total is 0 when it shouldn't be, the most common cause is that
LibreOffice did not recalculate — run the refresh a second time.

-------------------------------------------------------------------------------
USING THE DASHBOARD
-------------------------------------------------------------------------------

TOP BAR
  - Toggle between In-Person and Hybrid scenarios (top right).
  - Global cost sliders (below): adjust any of the 7 cost categories by
    -100% to +100% of current spend. Everything on the page recalculates.

SECTION 01 - P&L OVERVIEW
  Six KPI tiles with the headline numbers for whichever scenario is
  selected, reflecting current slider positions.

SECTION 02 - COURSE SCORECARD
  All 14 programs ranked by a composite Health Score:
    40% GP margin  +  40% safety margin vs. breakeven  +  20% GP contribution
  Click any column header to re-sort. Key columns:
    - Safety: current enrollment ÷ breakeven enrollment. Below 1.0 = losing
      money. Green/amber/red dot indicates status.
    - Breakeven: minimum students needed, with contribution-margin method
      (fixed course costs ÷ per-student contribution). Infinity means
      contribution per student is negative — unprofitable at any scale.

SECTION 03 - ENROLLMENT SENSITIVITY
  Pick a program from the dropdown. The chart shows profit as a function
  of enrollment. Red dashed line = breakeven. Green dot = current enrollment.
  The side panel gives the full unit-economics breakdown and a verdict.

SECTION 04 - IN-PERSON vs HYBRID
  Side-by-side comparison. The Hybrid-specific sliders let you apply
  independent cost multipliers just to the Hybrid model — useful given
  the Hybrid model is still under planning. Global sliders apply on TOP
  of Hybrid sliders (they compose).

SECTION 05 - COST STRUCTURE
  Stacked bar of COGS composition by program, sorted by margin. Shows
  which programs are staff-heavy vs. equipment-heavy, which informs
  which cost-cut levers apply where.

SECTION 06 - P&L WATERFALL
  Full bridge from Revenue through each COGS category, to Gross Profit,
  through OpEx categories, to Operating Profit.

-------------------------------------------------------------------------------
ADVANCED USAGE
-------------------------------------------------------------------------------

Run with a custom file path:

    python extract_data.py "path/to/your/real-model.xlsx" data.json
    python build_dashboard.py dashboard_template.html data.json dashboard.html

Both scripts accept positional arguments:

    extract_data.py <input.xlsx> <output.json>
    build_dashboard.py <template.html> <data.json> <output.html>

-------------------------------------------------------------------------------
NOTES ON BREAKEVEN METHODOLOGY
-------------------------------------------------------------------------------

Breakeven is computed on a contribution-margin basis:

    fixed course costs
    ------------------   =  minimum students to cover allocated costs
    revenue/student − variable cost/student

"Fixed course costs" for each program = the portion of its COGS that does
not scale linearly with enrollment: Direct staff, Rent, Equipment,
Compute/SW, Academics-other.

"Variable costs" that scale per-student = Students' accreditation (10% of
revenue, per the model) and Marketing.

This is a simplification — in reality many costs are step-functions (a
second classroom at 60 students, etc.). But it is directionally correct
and matches what executives will use for go/no-go decisions.

-------------------------------------------------------------------------------
TROUBLESHOOTING
-------------------------------------------------------------------------------

"ModuleNotFoundError: No module named 'openpyxl'"
  Run:  pip install openpyxl

"libreoffice: command not found" or recalc doesn't produce values
  Install LibreOffice from libreoffice.org and make sure it's on your PATH.
  On macOS: `brew install --cask libreoffice` also works.

All numbers show as 0 in the dashboard
  LibreOffice didn't recalc the formulas. Try running the refresh again.
  If it still fails, open model.xlsx in Excel, press F9 to force a full
  recalc, save, and run the refresh script.

A specific program shows 0 revenue but others work
  The extractor maps programs by column position on the Diplomas and
  Certificates tabs. If a program name was moved to a different column
  in the real file, update DIPLOMA_COLS / CERT_COLS in extract_data.py.
  (Your sanitized file matched the standard layout, so this should be
  safe.)

Scorecard shows "∞" in the Breakeven column
  That program has negative contribution per student (cost per student >
  revenue per student). It cannot break even at any enrollment — it is
  losing money on every student enrolled. This is a signal, not a bug.

-------------------------------------------------------------------------------
