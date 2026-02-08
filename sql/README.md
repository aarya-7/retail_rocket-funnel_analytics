## SQL layer (what this does)

These SQL scripts build the analytics foundation for the project in PostgreSQL.

### What I built
- **Timestamp normalization**: converted event timestamps into usable `event_ts`.
- **Sessionization**: created session IDs using a **30-minute inactivity rule** per visitor.
- **Session-level funnel table**: aggregated events into one row per session with funnel flags:
  - `has_view`, `has_addtocart`, `has_transaction`
  - first timestamps per stage for latency analysis
- **Funnel metrics**: calculated:
  - stage reach, conversion rates, and drop-offs
- **Time-to-convert**: computed time deltas:
  - view→cart, cart→txn, view→txn
- **Segmentation support**: mapped items → categories and created category-level rollups for Tableau.

### Why it matters
This SQL layer turns raw clickstream events (millions of rows) into **clean, Tableau-ready tables** that support:
- consistent funnel definitions
- correct session-based conversion metrics
- fast dashboard performance
- segment analysis (new vs returning, hour-of-day, category)
