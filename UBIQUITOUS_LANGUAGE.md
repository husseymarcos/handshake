# Ubiquitous Language

> The language of the domain, shared by everyone on the team.

This document defines the core concepts of Handshake using **optimistic, professional language** that empowers job seekers while maintaining clarity.

---

## Core Identity

### Professional

**Definition:** A person using Handshake to manage their career and job applications.

**Rationale:** "User" is too generic. "Professional" acknowledges expertise and agency. You're not just using an app — you're actively managing your career.

**Usage:**
- "As a **Professional**, you maintain your Portfolio..."
- "The **Professional** uploads their Master Resume"
- "**Professional** dashboard"

**In Code:**
- Model: `User` (legacy), transitioning to `Professional`
- Table: `professionals` (planned)
- Associations: `professional.capabilities`, `professional.experiences`, `professional.opportunities`

---

## Career Assets

### Portfolio

**Definition:** A Professional's complete collection of career data — their Capabilities and Experience.

**Rationale:** "Portfolio" implies a curated, valuable collection of your professional assets. It's industry-standard yet optimistic.

**Usage:**
- "Add items to your **Portfolio**"
- "Your **Portfolio** showcases your Capabilities and Experience"
- "Build out your **Portfolio** before applying"

**In Code:**
- Conceptual — spans `capabilities` and `experiences` tables
- View: "Portfolio" section in UI

---

### Capability

**Definition:** A skill, technology, or competency a Professional possesses.

**Rationale:** "Capability" is empowering — it focuses on what you *can* do, not just what you know. It implies agency and potential.

**Usage:**
- "Add your **Capabilities**"
- "Highlight relevant **Capabilities**"
- "The AI matches your **Capabilities** to the Posting"

**In Code:**
- Model: `Capability` (transitioning from `Skill`)
- Table: `capabilities`
- Association: `professional.capabilities`

**Formerly:** `Skill`

---

### Experience

**Definition:** A project, achievement, or deliverable in a Professional's Portfolio.

**Rationale:** Clear, professional, and encompassing. "Experience" covers projects, jobs, and achievements you've accumulated throughout your career.

**Usage:**
- "Showcase your **Experience**"
- "Add **Experience** to your Portfolio"
- "Describe your **Experience** and impact"

**In Code:**
- Model: `Experience` (transitioning from `Project`, `Work`)
- Table: `experiences`
- Association: `professional.experiences`

**Formerly:** `Project`, `Work`

---

## The Adaptation Process

### Opportunity

**Definition:** A specific job opening at an Organization that a Professional is pursuing.

**Rationale:** "Opportunity" is hopeful and forward-looking. Every application is a chance, not just a transaction.

**Usage:**
- "Create a new **Opportunity**"
- "Track your **Opportunities**"
- "This **Opportunity** is at Google"

**In Code:**
- Model: `Opportunity`
- Table: `opportunities`
- Association: `professional.opportunities`

**Formerly:** `JobApplication`

---

### Organization

**Definition:** The company, firm, or entity offering a job Opportunity.

**Rationale:** Broader and more professional than "company." Includes non-profits, agencies, startups, etc.

**Usage:**
- "Which **Organization** is this for?"
- "The **Organization** name"
- "Target **Organization**"

**In Code:**
- Attribute: `organization_name` on Opportunity
- Form field: "Organization"

**Formerly:** `company_name`

---

### Posting

**Definition:** The job description, requirements, and details of an Opportunity.

**Rationale:** Industry-standard term that's clear and professional. "Posting" implies something public and available.

**Usage:**
- "Paste the **Posting** here"
- "The **Posting** describes the role"
- "AI analyzes the **Posting** to Adapt your resume"

**In Code:**
- Attribute: `posting` on Opportunity
- Form field: "Job Posting"

**Formerly:** `job_description`

---

### Adapt / Adaptation

**Definition:** The process of transforming the Professional's Master Resume into a tailored resume for a specific Opportunity.

**Rationale:** Active and empowering. You don't just "generate" a resume — you *adapt* it. "Adaptation" is the noun form for the result.

**Usage:**
- "Click to **Adapt** your resume"
- "The **Adaptation** is complete"
- "Review the **Adapted** resume"
- "AI **Adapts** your Master Resume for this Opportunity"

**In Code:**
- Method: `Opportunity#adapt!`
- Service: `ResumeAdapter` (transitioning from `ResumeTypstPdf`)
- Noun: `adaptation` (the generated typst content)

**Formerly:** `synthesize`, `generate`

---

### Resume

**Definition:** The final PDF document produced by the Adaptation process.

**Rationale:** Simple, clear, universally understood. The end goal is a resume.

**Usage:**
- "Download your **Resume**"
- "The **Resume** is ready"
- "One-page **Resume** guaranteed"

**In Code:**
- Attachment: `resume` on Opportunity (Active Storage)
- Download route: `/opportunities/:id/resume`

---

## Deprecated Terms (Do Not Use)

| Old Term | New Term | Notes |
|----------|----------|-------|
| User | Professional | More empowering identity |
| Skill | Capability | Focus on what you CAN do |
| Project | Experience | Clear, professional term |
| Work | Experience | More encompassing term |
| JobApplication | Opportunity | Hopeful, forward-looking |
| Company | Organization | Broader, more professional |
| Job Description | Posting | Industry standard |
| Generate / Synthesize | Adapt | Active, empowering process |
| Blueprint / Master Resume | *(being removed)* | Concept being deleted per roadmap |

---

## Complete User Journey (Using Ubiquitous Language)

> As a **Professional**, you maintain your **Portfolio** — a collection of your **Capabilities** and **Experience**. When you discover an **Opportunity** at an **Organization**, you create it in Handshake and paste the **Posting**. The AI then **Adapts** your background into a tailored **Resume** optimized for that specific role. Review, download, and apply with confidence.

---

## Implementation Notes

- Model renames should include database migrations
- Update all user-facing copy (views, flash messages, emails)
- Update internal method names incrementally
- Keep tests readable — use domain language in test descriptions

---

*Last updated: April 21, 2026*
