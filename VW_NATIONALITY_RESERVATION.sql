
  CREATE OR REPLACE FORCE VIEW "OPERA"."VW_NATIONALITY_RESERVATION" ("GUEST_FIRST_NAME", "GUEST_LAST_NAME", "ROOM", "ADULTS", "CHILDREN", "ARRIVAL", "DEPARTURE", "NATIONALITY", "CONFIRMATION_NO", "ROOM_CATEGORY_LABEL", "COMPANY", "TRAVEL_AGENT_NAME", "RATE_CODE") AS 
  SELECT guest_first_name,
       guest_last_name,
       room,
       dn.adults,
       dn.children,
       rn.begin_date arrival,
       rn.end_date departure,
       NVL(nationality,'SIN_NAC') nationality,
       confirmation_no,
       reservation_ref.get_room_category_label(e.room_category,e.resort) room_category_label,
       company,
       reservation_ref.get_name(dn.travel_agent_id) travel_agent_name,
       rate_code
  FROM reservation_name rn,
       name n,
       reservation_daily_elements e,
       reservation_daily_element_name dn
 WHERE n.name_id = rn.name_id
   AND dn.resort = rn.resort
   AND dn.resv_name_id = rn.resv_name_id
   AND (e.resort = dn.resort
   AND  e.reservation_date = dn.reservation_date
   AND  e.resv_daily_el_seq = dn.resv_daily_el_seq)
   AND  rn.resv_status = 'CHECKED OUT'
   AND  rn.begin_date BETWEEN ('01-SEP-18') AND ('31-JAN-20')
