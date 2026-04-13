# 12-step rollout with a deep Release 1 blueprint and gated later phases

## Execution Protocol
- Total rollout is split into **4 releases** that map directly to your 4 phases and all 12 steps.
- Work should begin with **Release 1 only**.
- After Release 1 is finished, execution pauses until you explicitly say **rainbow**.
- Later releases stay frozen until you unlock them one by one.

## Release 1 of 4 — The Foundation

**Features**
- Add a new local storage layer for future automation records without disturbing your current saved data.
- Keep current saved data working as-is while new automation data is stored separately.
- Save app settings, flow templates, logs, screenshot records, repair confidence, and version history in a structured way.
- Add fast action logging with millisecond timing gaps between events so heavy runs remain responsive.
- Store screenshots with duplicate detection so repeated captures are skipped automatically.
- Add screenshot retention limits so old captures are removed before storage grows out of control.
- Improve screenshot browsing so users can switch between larger review cards and denser grids.
- Add storage health tracking so users can see duplicate savings, retained item counts, and sweep status.

**Design**
- Keep the current dark control-room style and make the new data tools feel native and tightly integrated.
- Use compact status pills, timing rows, and storage counters instead of long raw debug blocks.
- Make screenshot review feel like a visual lab with quick density changes and smooth transitions.
- Surface duplicate saves and cleanup results as subtle success states, not loud interruptions.

**Pages / Screens**
- Add a storage health area showing screenshot count, duplicate saves, retained history, and cleanup state.
- Upgrade the screenshot feed with density control for single-column, two-column, and compact multi-column review.
- Add a logging view focused on recent actions, timing gaps, and important session events.
- Expand the saved flow area so each flow can show stored version, repair confidence, and last repair date.

**Step-by-step scope inside Release 1**
- [x] **Step 1:** introduce the new storage foundation for future automation records while leaving existing saved data intact.
- [x] **Step 2:** add the global telemetry stream with delta-timestamped action feeds.
- [x] **Step 3:** add screenshot hash deduplication plus strict retention cleanup.
- [x] **Step 4:** rebuild screenshot feeds for smooth large-history browsing and density scaling.

**Safety rules for Release 1**
- Do not force a broad migration of older saved data.
- Do not replace existing persistence everywhere at once.
- Keep new storage focused on new automation records first.
- Keep background behavior limited to safe saving and cleanup readiness only.

## Release 2 of 4 — The Automation Engine

**Features**
- Add a stricter credential burn policy so valid credentials are not removed too early.
- Expand the flow editor so steps can be reordered, adjusted, and re-recorded from a broken point.
- Add version history for saved flows so older revisions can be recovered.
- Add human-readable change summaries whenever a saved flow changes.

**Design**
- Make editing feel like a native timeline workspace with clearer hierarchy and stronger step focus.
- Present risky actions with deliberate confirmation states rather than instant destructive changes.

**Pages / Screens**
- Upgrade the flow editor with reorder controls, step editing, and continue-from-here recording.
- Add a flow history view showing prior saved versions and change summaries.
- Add a save review sheet summarizing what changed before a new default is committed.

**Step-by-step scope inside Release 2**
- [x] **Step 5:** add the credential burn policy engine with clearer protection modes.
- [x] **Step 6:** expand the visual flow studio timeline and partial re-recording tools.
- [x] **Step 7:** add the master save pipeline with validation, history, and human-readable summaries.

**Safety rules for Release 2**
- Prefer recoverable saves over destructive overwrites.
- Keep audit history for flow changes.
- Preserve the current user workflow while expanding editing power.

## Release 3 of 4 — Runtime Safety

**Features**
- Keep off-screen behavior limited to safe save-and-resume support instead of risky unattended automation.
- Improve field-advance fallback when fragile login pages fail to move focus correctly.
- Tighten cookie and consent handling so it acts in a narrow, short-lived window.

**Design**
- Show runtime safety as calm status indicators and recovery prompts instead of hidden behavior.
- Make fragile fallback behavior visible and reviewable when it activates.

**Pages / Screens**
- Add runtime status indicators for save state, fallback activity, and banner handling.
- Add a small recovery panel showing why a page needed focus recovery or consent cleanup.

**Step-by-step scope inside Release 3**
- [ ] **Step 8:** keep background handling limited to safe state preservation only.
- [ ] **Step 9:** add calibrated password-field fallback heuristics.
- [ ] **Step 10:** add tightly constrained cookie and consent handling.

**Safety rules for Release 3**
- No real background automation beyond safe saving.
- No broad unattended work when the app is closed.
- Keep consent handling heavily constrained to avoid accidental clicks.

## Release 4 of 4 — AI Repair Assist

**Features**
- Add AI-based selector repair suggestions when a flow step fails.
- Use a longer retry window with gradual retries up to about 30 seconds total before giving up.
- Show confidence scores, fallback reasons, and suggested replacements clearly.
- Keep all AI repairs manual-review only with no live auto-apply.
- Save reviewed repair suggestions and confidence history for future reference.

**Design**
- Make AI repair feel like a review console, not an invisible self-changing system.
- Use strong safe/unsafe confidence cues so low-confidence suggestions are easy to reject.

**Pages / Screens**
- Upgrade the AI status area into a repair decision center with confidence, timing, and fallback reason.
- Add a repair review screen where failed selectors, suggested replacements, and approval choices are shown side by side.
- Add a repair history view showing past suggestions, confidence, and outcomes.

**Step-by-step scope inside Release 4**
- [ ] **Step 11:** add the AI DOM analysis and selector suggestion pipeline.
- [ ] **Step 12:** add the repair review loop, dry-run validation, logging, and manual approval flow.

**Safety rules for Release 4**
- No live auto-apply of AI fixes.
- Low-confidence suggestions must stop and wait for review.
- If the AI times out, the flow falls back to manual intervention.
- Retry timing may extend up to about 30 seconds total, but only for suggestion generation.

## Completion map
- **Release 1:** Steps 1 to 4
- **Release 2:** Steps 5 to 7
- **Release 3:** Steps 8 to 10
- **Release 4:** Steps 11 to 12

## Working rule after approval
- If you approve this plan, execution should begin with **Release 1 / Step 1 to Step 4 only**.
- After that, work freezes and waits for your explicit **rainbow** unlock before moving further.