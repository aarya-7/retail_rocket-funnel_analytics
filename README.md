## RetailRocket Full-Funnel Conversion Analytics (Sessionized Clickstream)

Stack: PostgreSQL (local) + Tableau

Dataset: RetailRocket eCommerce events (views, add-to-cart, transactions) (https://www.kaggle.com/datasets/retailrocket/ecommerce-dataset)

Goal: turn raw clickstream into a decision-ready funnel with sessionization, drop-offs, time-to-convert, and segment priorities.

Tableau Public Story: https://public.tableau.com/app/profile/aarya.bhivsanee/viz/RetailRocketFull-FunnelConversionAnalytics/Story1#2

Why this project:  Most “funnel dashboards” stop at reporting conversion rates. This project goes further:
	•	defines a consistent session unit (30-min inactivity)
	•	converts millions of raw events into session-level outcomes
	•	surfaces where conversion breaks, when users buy, and which segments are highest ROI

  
  How I modeled the data:
  1) Event time normalization

Raw timestamps are milliseconds. I converted them into a proper timestamp (event_ts) so all sequencing, time deltas, and session boundaries work correctly.

2) Sessionization (30-min inactivity rule)

For each visitor:
	•	sort events by time
	•	start a new session when the gap from the previous event is > 30 minutes
	•	generate a stable session_id (visitorid-session_seq)

This matters because “conversion rate per event” can be misleading; “conversion rate per session” maps better to real user journeys.

3) Session-level funnel table

For each session I created:
	•	funnel flags: has_view, has_addtocart, has_transaction
	•	first timestamps for each stage (for time-to-convert)

This single table powers every dashboard and keeps the definition consistent.


Summary (baseline funnel)
Across 1,761,675 sessions:
	•	View -> Cart: 2.21%
	•	Cart -> Transaction: 27.17%
	•	View -> Transaction: 0.73%
What this really means?
This is not primarily a “checkout is broken” story.
If checkout were the bottleneck, Cart→Txn would be weak. Instead, it’s relatively strong.
The main bottleneck is upstream: getting users to commit (Add-to-Cart).



## Findings that weren’t obvious at first glance:

1) The funnel has two modes: “browse” vs “buy”

The rate split is extreme:
	•	very low View -> Cart
	•	comparatively high Cart -> Txn

Classic sign of intent separation:
	•	most sessions are lightweight browsing (low commitment)
	•	a smaller subset becomes “buy mode” and then follows through

Implication: broad site-wide checkout tweaks won’t move the needle as much as improving the moments that create intent (product page clarity, trust, relevance, pricing transparency).

Actions:
	•	move shipping, returns, and delivery expectations to the top of the page.
	•	strengthen product page “reasons to believe” (reviews, guarantees, sizing/spec clarity)
	•	reduce friction for micro commitments (save/wishlist, compare, recently viewed)
  
2) Purchases occur without key upstream events (instrumentation + session-boundary risk)

Two non-trivial patterns appear in the session metrics:
	•	Sessions with transaction > Sessions with view AND transaction
→ purchasing sessions exist without a recorded view in the same session
	•	Sessions with transaction > Sessions with addtocart AND transaction
→ purchasing sessions exist without a cart event in the same session

This can happen due to:
	•	tracking gaps (events not captured)
	•	alternate flows (“buy now”, fast checkout)
	•	session boundaries (cart or view happened in a previous session)

Why this matters: If you ignore this, you will underestimate pre-purchase touchpoints and misattribute drop-off.

Actions:
	•	add a data QA check: % of txns missing view/cart (monitoring weekly)
	•	consider cross-session attribution for carting behavior (visitor-level journey windows)
	•	audit event instrumentation consistency


3) Conversion is time dependent (intent clusters by hour)

Hourly trend + heatmap show clear differences between:
	•	new vs returning
	•	different hours of day

Returning users convert higher across most hours, and conversion rises later in the day.

Interpretation:
This appears to be intent clustering, where individuals return when they’re ready to make a decision. It implies that the time of day isn’t merely just a time; it serves as a proxy for purchase readiness.

Actions:
	•	time remarketing or retention pushes to peak hours (emails, ads aligned with intent window)
	•	for new users earlier in the day: prioritize capture (save items, signup, browse reminders)


4) Category performance is not a little different — it’s structurally different

Top categories convert around ~2–2.6% View -> Txn, while worst categories fall near ~0.01–0.08% (with volume thresholds applied).

That’s a huge spread big enough that overall conversion can shift materially based on traffic mix alone.

Interpretation:
Some categories are “high intent shopping”, others are effectively “window shopping”. Treating them the same hides the actual drivers.

Actions:
	•	isolate high traffic low conversion categories as primary optimization targets
	•	audit category specific friction: pricing competitiveness, availability, PDP content quality, shipping constraints
	•	category specific merchandising: bundles, promos, trust messaging tuned to that category


5) Time-to-convert reveals two buyer populations

The time to convert histogram is front loaded (many purchases happen quickly) with a long tail.

This suggests two populations:
	•	fast deciders (convert in minutes)
	•	slow deciders (research, leave, and come back)

Actions:
	•	fast deciders: reduce checkout friction and distractions; emphasize speed
	•	slow deciders: support decision-making (comparisons, reviews, reminders, price-drop alerts)


## What I would prioritize first:

If I’m in the analytics team choosing one lever, I’d target:

1) High-volume, low-conversion categories (opportunity map)

These are the biggest ROI segments because a small lift impacts the largest traffic base.

2) View -> Cart improvements (because it’s the dominant leak)

Since Cart -> Txn is already relatively strong, lifting carting rate is the fastest path to improving overall conversion.

3) Returning user peak windows (because intent is already high)

Timing interventions can be cheaper than rebuilding UX.


Deliverables
	•	Sessionized events in PostgreSQL
	•	Tableau Story with 4 dashboards:
	1.	Funnel overview (baseline + leakage framing)
	2.	Segment performance (hour × new/returning + top/worst categories)
	3.	Drop-offs + time-to-convert distribution
	4.	Trend + Opportunity map (prioritization)


##  Experiments I’d run next (testable hypotheses)
		
1.   PDP Trust & Clarity Test
Hypothesis: clearer shipping/returns + stronger trust signals increases View→Cart.
Metric: View -> Cart uplift + downstream View -> Txn.

2.	 New-user Activation Flow
Hypothesis: capturing new users (save/wishlist + email capture) improves return rate and conversion.
Metric: returning share + View -> Txn for new cohort over 7-15 days.

3.	Category Specific Intervention
Hypothesis: high-volume low-conversion categories have fixable friction (price transparency, stock, content).
Metric: category View -> Cart + category View -> Txn.



  
  
