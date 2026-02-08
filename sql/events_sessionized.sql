-- View: events_rawdata.events_sessionized

-- DROP VIEW events_rawdata.events_sessionized;

CREATE OR REPLACE VIEW events_rawdata.events_sessionized
 AS
 WITH ordered AS (
         SELECT e.visitorid,
            e.event,
            e.itemid,
            e.transactionid,
            e.timestamp_ms,
            e.event_ts,
            lag(e.event_ts) OVER (PARTITION BY e.visitorid ORDER BY e.event_ts) AS prev_ts
           FROM events_rawdata.events_clean e
        ), marked AS (
         SELECT ordered.visitorid,
            ordered.event,
            ordered.itemid,
            ordered.transactionid,
            ordered.timestamp_ms,
            ordered.event_ts,
            ordered.prev_ts,
                CASE
                    WHEN ordered.prev_ts IS NULL THEN 1
                    WHEN (ordered.event_ts - ordered.prev_ts) > '00:30:00'::interval THEN 1
                    ELSE 0
                END AS is_new_session
           FROM ordered
        ), numbered AS (
         SELECT marked.visitorid,
            marked.event,
            marked.itemid,
            marked.transactionid,
            marked.timestamp_ms,
            marked.event_ts,
            marked.prev_ts,
            marked.is_new_session,
            sum(marked.is_new_session) OVER (PARTITION BY marked.visitorid ORDER BY marked.event_ts) AS session_seq
           FROM marked
        )
 SELECT visitorid,
    event,
    itemid,
    transactionid,
    timestamp_ms,
    event_ts,
    session_seq,
    (visitorid::text || '-'::text) || session_seq::text AS session_id
   FROM numbered;

ALTER TABLE events_rawdata.events_sessionized
    OWNER TO reflex;

