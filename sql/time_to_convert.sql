-- View: events_rawdata.time_to_convert

-- DROP VIEW events_rawdata.time_to_convert;

CREATE OR REPLACE VIEW events_rawdata.time_to_convert
 AS
 SELECT visitorid,
    session_id,
        CASE
            WHEN has_view = 1 AND has_addtocart = 1 THEN EXTRACT(epoch FROM first_addtocart_ts - first_view_ts)
            ELSE NULL::numeric
        END AS sec_view_to_cart,
        CASE
            WHEN has_addtocart = 1 AND has_transaction = 1 THEN EXTRACT(epoch FROM first_transaction_ts - first_addtocart_ts)
            ELSE NULL::numeric
        END AS sec_cart_to_txn,
        CASE
            WHEN has_view = 1 AND has_transaction = 1 THEN EXTRACT(epoch FROM first_transaction_ts - first_view_ts)
            ELSE NULL::numeric
        END AS sec_view_to_txn
   FROM events_rawdata.session_funnel;

ALTER TABLE events_rawdata.time_to_convert
    OWNER TO reflex;

