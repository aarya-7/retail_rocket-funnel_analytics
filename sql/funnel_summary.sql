-- View: events_rawdata.funnel_summary

-- DROP VIEW events_rawdata.funnel_summary;

CREATE OR REPLACE VIEW events_rawdata.funnel_summary
 AS
 SELECT count(*) AS total_sessions,
    sum(has_view) AS sessions_with_view,
    sum(has_addtocart) AS sessions_with_addtocart,
    sum(has_transaction) AS sessions_with_transaction,
    sum(
        CASE
            WHEN has_view = 1 AND has_addtocart = 1 THEN 1
            ELSE 0
        END) AS sessions_view_to_cart,
    sum(
        CASE
            WHEN has_addtocart = 1 AND has_transaction = 1 THEN 1
            ELSE 0
        END) AS sessions_cart_to_txn,
    sum(
        CASE
            WHEN has_view = 1 AND has_transaction = 1 THEN 1
            ELSE 0
        END) AS sessions_view_to_txn,
    sum(
        CASE
            WHEN has_view = 1 AND has_addtocart = 1 THEN 1
            ELSE 0
        END)::numeric / NULLIF(sum(has_view), 0)::numeric AS rate_view_to_cart,
    sum(
        CASE
            WHEN has_addtocart = 1 AND has_transaction = 1 THEN 1
            ELSE 0
        END)::numeric / NULLIF(sum(has_addtocart), 0)::numeric AS rate_cart_to_txn,
    sum(
        CASE
            WHEN has_view = 1 AND has_transaction = 1 THEN 1
            ELSE 0
        END)::numeric / NULLIF(sum(has_view), 0)::numeric AS rate_view_to_txn
   FROM events_rawdata.session_funnel;

ALTER TABLE events_rawdata.funnel_summary
    OWNER TO reflex;

