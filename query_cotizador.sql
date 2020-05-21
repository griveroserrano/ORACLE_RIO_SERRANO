--Query que consulta los rate_codes que pueden reservas las Agencias
SELECT NV.DISPLAY_NAME,
       RNV.RATE_CODE,
       rsv.ROOM_TYPES,
       rsv.BEGIN_DATE,
       rsv.END_DATE,
       rsv.AMOUNT_1,
       rsv.AMOUNT_2,
       rsv.AMOUNT_3,
       rsv.AMOUNT_4,
       rhv.currency_code,
       rsv.ADULT_CHARGE,
       rsv.CHILDREN_CHARGE
  FROM RATE_HEADER_NEGOTIAT_BASE_VIEW RNV,
       NAME_VIEW                      NV,
       RATE_SET_VIEW                  rsv,
       rate_header_view               rhv
 WHERE RNV.NAME_ID = NV.NAME_ID
   AND rnv.RESORT = 'HRS'
   AND rhv.RESORT = 'HRS'
   AND rnv.RATE_CODE = rsv.RATE_CODE
   and rhv.RATE_CODE = rsv.RATE_CODE
   and rhv.rate_code = rnv.RATE_CODE
 ORDER BY 1, 2, 3, 4
