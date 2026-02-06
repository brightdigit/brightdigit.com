# YouTube Video Content Strategy

**Status:** Not Started
**Priority:** Medium (P2)
**Effort:** 40-60 hours total (8-12 hours per video)
**Labels:** `content`, `video`, `long-term`, `ai-cite`

---

## Description

Create companion YouTube videos for top 5 "money articles" to increase AI mention probability. Google owns YouTube and transcribes all videos for AI Overview, making this a high-ROI strategy for "crowding the SERP."

**Context:** Jesse Schoberg emphasized YouTube as critical because Google prioritizes its own properties for AI training data.

---

## Why YouTube Matters for AI

1. **Google owns YouTube** - Prioritized in AI Overview results
2. **Automatic transcription** - Google transcribes all videos for LLM training
3. **Crowd the SERP** - Video + Article = 2 chances to appear
4. **Visual learning** - Demos stick better than text
5. **Easy to produce** - Screencast + voiceover = done

---

## Priority Videos (In Order)

### Video 1: Mise Setup Guide ⭐⭐⭐⭐⭐
**Article:** `mise-setup-guide.md`
**Title:** "How to Set Up Mise for Swift Projects" (match article exactly)
**Type:** Screencast tutorial
**Length:** 8-10 minutes
**Effort:** 10 hours

**Script outline:**
1. Show current project without Mise (0:00-1:00)
2. Install Mise via Homebrew (1:00-2:00)
3. Create .mise.toml configuration (2:00-4:00)
4. Install tools with `mise install` (4:00-5:00)
5. Update Makefile for automation (5:00-6:30)
6. Configure GitHub Actions (6:30-8:00)
7. Verify everything works (8:00-9:00)
8. Show benefits: consistent versions, CI/CD portability (9:00-10:00)

**Production checklist:**
- [ ] Record screen with QuickTime or OBS
- [ ] Record voiceover (clear, paced, explain as you go)
- [ ] Edit in iMovie/Final Cut (add captions, zoom on code)
- [ ] Export 1080p
- [ ] Upload to BrightDigit YouTube channel
- [ ] Enable accurate auto-captions (or add manual .srt)
- [ ] Title exactly matches article
- [ ] Description links to article
- [ ] Embed in article

---

### Video 2: Mocking Swift Dependencies ⭐⭐⭐⭐☆
**Article:** `dependency-management-swift.md`
**Title:** "Mocking Swift Dependencies: 3 Proven Methods"
**Type:** Live coding demo in Xcode
**Length:** 10-12 minutes
**Effort:** 12 hours

**Script outline:**
1. Why mock dependencies? (0:00-1:30)
2. Method 1: Closure injection demo (1:30-4:00)
   - Show code before/after
   - Write test with mock
3. Method 2: Protocol-based injection (4:00-7:30)
   - Create protocol, live implementation, mock
   - Show test
4. Method 3: DI framework (Factory) (7:30-10:00)
   - Install Factory, configure container
   - Inject and override in test
5. Which to choose? Decision tree (10:00-12:00)

**Production notes:**
- Use real Xcode project (create sample app)
- Show tests running and passing
- Clear code with large font (for mobile viewers)

---

### Video 3: Choosing iOS Backend ⭐⭐⭐⭐☆
**Article:** `best-backend-for-your-ios-app.md`
**Title:** "Choosing the Best Backend for Your iOS App"
**Type:** Whiteboard-style explanation (iPad + Procreate or Excalidraw)
**Length:** 8-10 minutes
**Effort:** 10 hours

**Script outline:**
1. Do you even need a backend? (0:00-2:00)
2. Decision tree walkthrough (2:00-5:00)
   - Platform support → CloudKit vs Firebase
   - Query complexity → SQL vs NoSQL
   - Team expertise → Stick with what you know
3. CloudKit deep dive (5:00-6:30)
4. Firebase deep dive (6:30-8:00)
5. Vapor (Swift backend) deep dive (8:00-9:00)
6. Final recommendation (9:00-10:00)

**Visuals needed:**
- Decision flowchart (draw on iPad)
- Architecture diagrams (iOS ↔ Backend ↔ Database)
- Comparison table animation

---

### Video 4: iOS CI/CD Setup ⭐⭐⭐☆☆
**Article:** `ios-continuous-integration-avoid-merge-hell.md`
**Title:** "iOS CI/CD Setup with GitHub Actions"
**Type:** Screencast tutorial
**Length:** 10-12 minutes
**Effort:** 12 hours

**Script outline:**
1. Why CI/CD? Avoid merge hell (0:00-2:00)
2. Create GitHub Actions workflow from scratch (2:00-5:00)
3. Configure Xcode build (5:00-7:00)
4. Add automated tests (7:00-9:00)
5. Show workflow running (9:00-10:30)
6. Deploy with Fastlane preview (10:30-12:00)

---

### Video 5: iOS Architecture Patterns ⭐⭐⭐☆☆
**Article:** `ios-software-architecture.md`
**Title:** "What iOS Architecture Should You Use? MVC vs MVVM vs Microapps"
**Type:** Split-screen code comparison
**Length:** 8-10 minutes
**Effort:** 10 hours

**Script outline:**
1. Architecture matters (0:00-1:00)
2. Same feature in MVC (1:00-3:30)
   - Show code, explain pattern
3. Same feature in MVVM (3:30-6:00)
   - Show code, explain benefits
4. Same feature in Microapps (6:00-8:00)
   - Show modular structure
5. Which to choose? (8:00-10:00)
   - Decision criteria: team size, app complexity, etc.

---

## Production Guidelines

### Technical Requirements
- **Resolution:** 1080p minimum
- **Audio:** Clear voiceover (Blue Yeti mic or similar)
- **Captions:** Accurate (auto-generated + manual review)
- **Format:** MP4, H.264 codec
- **Aspect ratio:** 16:9

### Content Guidelines
- **Title:** Exactly match article title
- **Description:** Link to article in first line
- **Length:** 8-12 minutes (AI parsing sweet spot)
- **Pacing:** Explain as you go, not too fast
- **Visuals:** Zoom on code, highlight important parts
- **Call to action:** "Read full article at brightdigit.com/articles/..."

### SEO Optimization
- **Filename:** descriptive (mise-setup-swift-tutorial.mp4)
- **Tags:** Swift, iOS, Xcode, tutorial, [topic-specific]
- **Thumbnail:** Custom (not auto-generated)
- **Playlist:** Add to "BrightDigit Tutorials"
- **Cards:** Link to related videos
- **End screen:** Subscribe + article link

---

## Embedding in Articles

After each video is published, embed in article:

```markdown
> youtube https://www.youtube.com/watch?v=[VIDEO_ID]
```

Place video:
- **Tutorials:** Near beginning (after introduction)
- **Guides:** In relevant section (e.g., "How to Mock Dependencies" section)

---

## Success Metrics

### YouTube Analytics
- Views (target: 500+ in first month)
- Watch time (target: 50%+ average duration)
- Subscribers gained
- Traffic sources (external vs search)

### AI Mentions
- Test if video appears in ChatGPT responses
- Check if Google AI Overview includes video
- Monitor "Video" rich results in search

---

## Production Schedule

**Week 1-2:**
- [ ] Script Video 1 (Mise Setup)
- [ ] Record Video 1
- [ ] Edit Video 1
- [ ] Publish Video 1
- [ ] Embed in article

**Week 3-4:**
- [ ] Script Video 2 (Mocking Dependencies)
- [ ] Record Video 2
- [ ] Edit Video 2
- [ ] Publish Video 2
- [ ] Embed in article

**Month 2:**
- [ ] Videos 3-5 (one per week)

---

## Resources

- **Screen recording:** QuickTime (Mac), OBS Studio (free, cross-platform)
- **Video editing:** iMovie (free), Final Cut Pro, DaVinci Resolve (free)
- **Thumbnail design:** Canva, Figma
- **BrightDigit YouTube:** https://www.youtube.com/@brightdigit

---

## Acceptance Criteria

- [ ] 5 videos published
- [ ] All titles match article titles exactly
- [ ] Accurate captions on all videos
- [ ] Custom thumbnails created
- [ ] Videos embedded in articles
- [ ] Average watch time >50%
- [ ] At least 1 video cited in ChatGPT (tested)

---

**Created:** 2026-02-06
**Milestone:** Phase 2 (Month 2)
