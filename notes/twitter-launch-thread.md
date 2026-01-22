# Twitter/X Launch Thread

**Post time:** 8-9am EST weekday

---

## THREAD: Main Launch

### Tweet 1 (Hook)
I built an AI operating system for a NASDAQ-listed company.

10 agents. 6 departments. Zero manual reports.

Here's the architecture:

---

### Tweet 2 (Problem)
The problem: I'm COO overseeing CS, Sales, Marketing, Design, Supply Chain, and App Dev.

Data lives across 5 systems:
- NetSuite (financials)
- Shopify (orders)
- Airtable (projects)
- Intercom (tickets)
- ShipStation (fulfillment)

Getting a complete picture took HOURS.

---

### Tweet 3 (Solution overview)
The solution: 10 specialized AI agents, each with one job.

They connect via MCP (Model Context Protocol) servers to enterprise systems.

Claude Code does the thinking.
Slack gets the output.

---

### Tweet 4 (Agent categories)
The agents:

DAILY (high-frequency):
• daily-ops-pulse → Morning briefing
• cs-ticket-triager → Categorize tickets
• inventory-watchdog → Stock alerts

PERIODIC:
• netsuite-shopify-reconciler → Nightly revenue check
• weekly-department-digest → Friday summary
• board-metrics-compiler → Monthly board report

---

### Tweet 5 (More agents)
REACTIVE (event-triggered):
• rx-order-tracker → Rx order lifecycle
• order-anomaly-detector → Fraud/high-value alerts
• project-status-aggregator → Cross-functional health

UTILITY:
• vendor-comm-drafter → China factory comms

---

### Tweet 6 (Architecture diagram - attach image)
The data flow:

```
NetSuite + Shopify + Airtable
        ↓
    MCP Servers
        ↓
    Claude Code
        ↓
      Slack
```

Each agent runs independently.
Each has a single SKILL.md file that defines everything.

---

### Tweet 7 (Token efficiency)
The token efficiency problem:

10 agents with full context = 55K tokens.

Solution: Context layering.
- Core context: 800 tokens (load once)
- Agent-specific: 1.5-2.5K tokens
- Progressive loading

Result: 20K tokens (63% reduction).

---

### Tweet 8 (Key insight)
The key insight:

AI agents aren't magic. They're automation with better interfaces.

The work is:
1. Define exactly what you want
2. Connect the data sources
3. Iterate on output format until useful

The tools are finally good enough.

---

### Tweet 9 (Results)
The results after 6 months:

• Monday mornings: Wake up to week's performance + priorities
• Inventory: Alerts BEFORE stockouts
• Board reporting: 8 hours → 1 hour of review
• Decision latency: Cut dramatically

---

### Tweet 10 (CTA)
I wrote a deep-dive on the full architecture:
- SKILL.md anatomy
- MCP server setup
- State management
- What actually worked

Link: jabondano.co/notes/agentic-ops-infrastructure.html

What operations problem is eating YOUR time?

---

## Follow-up threads (to queue)

### Thread 2: "The anatomy of an AI agent skill file"
- What goes in a SKILL.md
- Data collection steps
- Output format specification
- Error handling
- Real example with code

### Thread 3: "How I made Claude Code 63% more token efficient"
- Context layering pattern
- Core vs agent-specific context
- Progressive loading
- Model tiering (Haiku/Sonnet/Opus)

### Thread 4: "Building an inventory watchdog with Claude + NetSuite"
- Step-by-step implementation
- The SQL queries
- Alert thresholds
- Slack output format

### Thread 5: "MCP servers are the API of AI"
- What is MCP
- Why it matters for enterprise
- NetSuite MCP server setup
- Combining multiple MCP servers

### Thread 6: "From spreadsheets to real-time Slack briefings"
- The before (hours in Excel)
- The after (automatic at 6am)
- The transition process
- What I'd do differently

---

## Engagement strategy

**Post timing:**
- Launch thread: 8-9am EST weekday (Tue-Thu optimal)
- Reply to comments within first 2 hours

**Cross-post:**
- Architecture diagram as standalone image post
- Pin thread to profile

**Hashtags (use sparingly):**
- #AI
- #ClaudeAI
- #Automation
- #MCP

---

## Image assets needed

1. Architecture diagram (clean version of ASCII art)
2. Screenshot of Slack output (redacted)
3. SKILL.md code snippet (syntax highlighted)
4. Before/after comparison (manual vs automated)
