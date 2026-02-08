{\rtf1\ansi\ansicpg1252\cocoartf2867
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww38200\viewh19540\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 CREATE VIEW events_rawdata.funnel_by_segment AS\
SELECT\
  visitor_type,\
  session_hour,\
  categoryid,\
\
  COUNT(*) AS sessions,\
  SUM(has_view) AS view_sessions,\
  SUM(has_addtocart) AS cart_sessions,\
  SUM(has_transaction) AS txn_sessions,\
\
  SUM(CASE WHEN has_view = 1 AND has_addtocart = 1 THEN 1 ELSE 0 END) AS sessions_view_to_cart,\
  SUM(CASE WHEN has_addtocart = 1 AND has_transaction = 1 THEN 1 ELSE 0 END) AS sessions_cart_to_txn,\
  SUM(CASE WHEN has_view = 1 AND has_transaction = 1 THEN 1 ELSE 0 END) AS sessions_view_to_txn,\
\
  (SUM(CASE WHEN has_view = 1 AND has_addtocart = 1 THEN 1 ELSE 0 END)::numeric\
    / NULLIF(SUM(has_view), 0)) AS rate_view_to_cart,\
\
  (SUM(CASE WHEN has_addtocart = 1 AND has_transaction = 1 THEN 1 ELSE 0 END)::numeric\
    / NULLIF(SUM(has_addtocart), 0)) AS rate_cart_to_txn,\
\
  (SUM(CASE WHEN has_view = 1 AND has_transaction = 1 THEN 1 ELSE 0 END)::numeric\
    / NULLIF(SUM(has_view), 0)) AS rate_view_to_txn\
\
FROM events_rawdata.session_dim\
GROUP BY visitor_type, session_hour, categoryid;}