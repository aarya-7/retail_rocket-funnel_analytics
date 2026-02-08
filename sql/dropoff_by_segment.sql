-- View: events_rawdata.dropoff_by_segment

-- DROP VIEW events_rawdata.dropoff_by_segment;

CREATE OR REPLACE VIEW events_rawdata.dropoff_by_segment
 AS
 SELECT visitor_type,
    session_hour,
    categoryid,
    count(*) AS sessions,
    sum(
        CASE
            WHEN has_view = 1 AND has_addtocart = 0 THEN 1
            ELSE 0
        END) AS drop_view_no_cart,
    sum(
        CASE
            WHEN has_addtocart = 1 AND has_transaction = 0 THEN 1
            ELSE 0
        END) AS drop_cart_no_txn,
    sum(
        CASE
            WHEN has_view = 1 AND has_addtocart = 0 THEN 1
            ELSE 0
        END)::numeric / NULLIF(sum(has_view), 0)::numeric AS drop_rate_after_view,
    sum(
        CASE
            WHEN has_addtocart = 1 AND has_transaction = 0 THEN 1
            ELSE 0
        END)::numeric / NULLIF(sum(has_addtocart), 0)::numeric AS drop_rate_after_cart
   FROM events_rawdata.session_dim
  GROUP BY visitor_type, session_hour, categoryid;

ALTER TABLE events_rawdata.dropoff_by_segment
    OWNER TO reflex;

