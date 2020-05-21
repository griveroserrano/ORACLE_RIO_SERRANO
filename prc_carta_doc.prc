create or replace procedure prc_carta_doc(pin_resv_name_id IN NUMBER,
                                         pout_name_complete OUT VARCHAR,
                                         pout_confirmation_no OUT NUMBER,
                                         pout_arrival_date OUT DATE,
                                         pout_departure_date OUT DATE,
                                         pout_travel_agent_name OUT VARCHAR2,
                                         pout_reservation_clerk OUT VARCHAR2,
                                         pout_cancel_date OUT DATE,
                                         pout_deposit_due_date OUT VARCHAR2,
                                         pout_resort OUT VARCHAR2,
                                         pout_xreservation_contact OUT VARCHAR2,
                                         pout_rate_code_description OUT VARCHAR2,
                                         pout_moneda OUT VARCHAR,
                                         pout_no_of_guests OUT NUMBER,
                                         pout_no_of_nights OUT NUMBER,
                                         pout_language OUT VARCHAR2,
                                         pout_udfc20 OUT VARCHAR2,
                                         pout_room_type_desc OUT VARCHAR2,
                                         pout_estadia_char OUT VARCHAR2,
                                         pout_average_rate OUT VARCHAR2,
                                         pout_error OUT VARCHAR2)
                                       IS

v_currency_code VARCHAR2(100);
v_room_type VARCHAR2(100);
v_estadia_num NUMBER;
v_resort VARCHAR2(100);
v_departure_date DATE;
v_average NUMBER;

--Buscar los valores y realizar los joins de las tablas, ademas agregando las condiciones necesarias
BEGIN

  SELECT nr.first|| ' '||nr.guest_name name_complete,
         nr.confirmation_no,
         nr.arrival_date_time arrival_date,
         nr.departure_date_time departure_date,
         reservation_ref.get_name(nr.travel_agent_id) travel_agent_name,
         confirmation_ref.reservation_clerk(nr.insert_user)reservation_clerk,
         (nr.cancellation_date) cancel_date,
         SUBSTR(confirmation_ref.get_mul_deposit_due_date(nr.resort,nr.resv_name_id),4,2)||'-'||
         SUBSTR(confirmation_ref.get_mul_deposit_due_date(nr.resort,nr.resv_name_id),1,2)||'-'||
         SUBSTR(confirmation_ref.get_mul_deposit_due_date(nr.resort,nr.resv_name_id),7,2) as deposit_due_date,
         nr.resort,
         reservation_ref.get_name(nr.resv_contact_id,'F, ','Y') XReservation_Contact,
         confirmation_ref.rate_code_description(nr.resort,nr.rate_code,nr.language)  RATE_CODE_DESCRIPTION,
         DECODE(nr.currency_code,'USD','US$','CLP','$',nr.currency_code) moneda,
         nr.adults + NVL(nr.children,0)no_of_guests,
         nr.nights no_of_nights,
         nr.language idioma,
         nr.currency_code,
         nr.resort,
         confirmation_ref.get_room_type_label (nr.room_category_label,nr.booked_room_category,rn.spg_upgrade_confirmed_roomtype,rn.spg_disclose_room_type_yn) room_type,
         rn.udfc20 udfc20
     INTO
         pout_name_complete,
         pout_confirmation_no,
         pout_arrival_date,
         pout_departure_date,
         pout_travel_agent_name,
         pout_reservation_clerk,
         pout_cancel_date,
         pout_deposit_due_date,
         pout_resort,
         pout_xreservation_contact,
         pout_rate_code_description,
         pout_moneda,
         pout_no_of_guests,
         pout_no_of_nights,
         pout_language,
         v_currency_code,
         v_resort,
         v_room_type,
         pout_udfc20
  FROM name_reservation nr,
       reservation_name rn
    WHERE nr.RESORT = 'HRS'
    AND pin_resv_name_id = rn.resv_name_id
    AND pin_resv_name_id = nr.resv_name_id
    AND TO_DATE(nr.arrival, 'dd-mm-yy') >= TO_DATE('01-01-2019', 'dd-mm-yy')
    AND nr.resv_status NOT IN ('CANCELLED',
                               'CHECKED OUT')
    AND nr.group_name IS NULL
    AND nr.room_category > 0;


v_departure_date := pout_departure_date;

--Buscar otros valores y asignar mascaras
BEGIN
  SELECT AVG(rden.share_amount)
    INTO v_average
    FROM reservation_daily_element_name rden
   WHERE rden.resv_name_id = pin_resv_name_id
     AND to_char(rden.reservation_date,'DD-MM-YY') != to_char(v_departure_date,'DD-MM-YYYY');

  IF v_currency_code LIKE 'CLP' THEN
      v_average:=v_average*1.19;
  END IF;

  IF v_currency_code LIKE 'CLP' THEN
      v_estadia_num := ROUND(v_average * pout_no_of_nights);
      pout_estadia_char := to_char(ROUND(v_average) * pout_no_of_nights, 'FM9G999G999');
      pout_average_rate :=(to_char(v_average, 'FM9G999G999'));
  END IF;

  IF v_currency_code like 'USD' THEN
      v_estadia_num :=  v_average * pout_no_of_nights;
      pout_estadia_char := to_char(v_average * pout_no_of_nights, 'FM9G999G999D00');
      pout_average_rate := to_char(v_average, 'FM9G999G999D00');
  END IF;

  IF pout_deposit_due_date = '--' THEN
     pout_deposit_due_date := ' ';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;

BEGIN
    SELECT DISTINCT(initcap(short_description))
      INTO pout_room_type_desc
      FROM resort_room_category
     WHERE resort = v_resort
       AND label = v_room_type;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
END;
  EXCEPTION
    WHEN OTHERS THEN
      pout_error := 'Error: '||SQLERRM;
END prc_carta_doc;
/
