# Summary: "Your Browser Just Became an Employee" Prompt Kit

> **Source**: https://promptkit.natebjones.com/20260310_usk_promptkit_1
> **Author**: Nate B. Jones
> **Date Accessed**: 2026-03-18

---

## What This Is

A four-prompt framework by Nate B. Jones designed to help users plan and deploy AI browser automation using Anthropic's tools (Claude Chrome Extension, Claude Code, and Cowork). The kit is sequential — taking users from discovering what to automate, through designing the workflow, to validating security before going live.

The prompts are tool-agnostic for the *planning* phase (work in ChatGPT, Claude, Gemini, etc.) but the *execution* targets Anthropic's ecosystem.

---

## The Four Prompts

### 1. The Weekly Automation Audit
**Purpose**: Interview-based discovery of all repetitive browser tasks in a user's week, ranked by automation potential.
**Key Value**: Systematic identification of automation candidates with time estimates, risk flags, and a prioritized "Start Here" list. Categorizes tasks into: Data Gathering, Communication, Organization, Monitoring, Data Transfer, and Other.

### 2. The Shortcut Blueprint
**Purpose**: Turn a specific task into a step-by-step recording plan for Claude's Chrome extension.
**Key Value**: Breaks complex workflows into manageable subtasks, recommends the right tool (Chrome Extension vs. Claude Code vs. Cowork), and includes security flags. Practical enough to follow with a phone propped up next to a laptop.

### 3. The Multi-Tab Intel Operation
**Purpose**: Design multi-source intelligence gathering operations across multiple browser tabs.
**Key Value**: Structured approach to competitive analysis, market research, vendor comparison, and content monitoring. Includes scope controls (5-8 tabs max per operation), extraction frameworks, and output templates. Addresses the real limitation that Claude's quality degrades with too much data in a single pass.

### 4. The Safety & Tool Fit Check
**Purpose**: Security assessment and tool selection for any planned browser automation.
**Key Value**: Evaluates across five risk dimensions (data sensitivity, action consequences, prompt injection exposure, scope creep, authentication exposure) with a clear GO/ADJUST/STOP verdict. Practical mitigations rather than fear-based warnings.

---

## Key Insights & Frameworks

1. **Subtask Decomposition**: The kit emphasizes that the #1 mistake is trying to record one massive workflow. Breaking tasks into 2-4 focused subtasks dramatically improves reliability.

2. **Data Volume Limits**: Claude in Chrome gets less reliable when processing too much information in a single pass. Cap tab groups at 5-8, extraction targets at 3-5 per tab, and social media monitoring at 5-8 people.

3. **Tool Selection Matrix**:
   - **Chrome Extension Sidebar** → Standard browser tasks, summaries, tables in chat panel
   - **Claude Code** (terminal with `--chrome` flag) → Complex reasoning, developer workflows, customer service negotiations
   - **Cowork** → File output needed (Excel, reports, slide decks), competitive intel to share with teams

4. **Five Risk Dimensions for Browser Automation**:
   - Data Sensitivity
   - Action Consequences (reversibility)
   - Prompt Injection Exposure
   - Scope Creep Risk
   - Authentication Exposure

5. **Prompt Structure Pattern**: All four prompts use the same XML-based architecture: `<role>`, `<instructions>` (phased), `<output>`, `<guardrails>`. This is a clean, reusable template for building structured AI prompts.

---

## Relevance to Full Refit

### Direct Applications
- **Client Onboarding**: Prompt 1 (Weekly Automation Audit) could be adapted for discovery calls — systematically identifying where clients spend time on repetitive browser work and proposing automation solutions.
- **Service Offering**: The Shortcut Blueprint (Prompt 2) and Multi-Tab Intel (Prompt 3) provide frameworks that could be packaged as automation design services.
- **Internal Efficiency**: All four prompts can be used directly to audit and automate Full Refit's own repetitive workflows.

### Adaptation Opportunities
- **Customize for Agency Context**: Adapt the audit prompt to focus on marketing/agency-specific tasks (social media management, reporting, competitive monitoring, client deliverable assembly).
- **Client-Facing Tool**: White-label these prompts as part of a "browser automation readiness assessment" for clients.
- **Security Framework**: The five-dimension risk assessment from Prompt 4 is a solid template for evaluating any AI automation, not just browser-based ones.

### Prompt Engineering Takeaways
- The phased interview approach (discover → analyze → deliver) is highly effective for complex planning tasks.
- XML-structured prompts with explicit guardrails produce more reliable, consistent outputs.
- The "wait for response" pattern throughout the instructions prevents the AI from rushing ahead with assumptions.

---

## Recommended Next Steps

1. **Run Prompt 1 internally** — audit Full Refit's own weekly browser workflows for automation candidates
2. **Adapt Prompt 2** for the most common client automation requests
3. **Use Prompt 4's risk framework** as a standard checklist before deploying any browser automation for clients
4. **Study the prompt structure** (role/instructions/output/guardrails XML pattern) as a template for building future prompts
