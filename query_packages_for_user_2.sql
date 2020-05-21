SELECT (SELECT au.app_user 
          FROM  application_user au
         WHERE au.app_user_id = rpp.insert_user)app_user,
       rpp.consumption_date,
       nr.confirmation_no,
       nr.arrival,
       nr.departure,
       ft.reference,
       ft.product,
       ft.fiscal_bill_no,
       ft.trx_amount,
       ft.currency,
       ft.org_posted_amount
FROM reservation_product_prices rpp,
    financial_transactions ft, 
    name_reservation nr
WHERE  ft.resv_name_id = rpp.resv_name_id
AND nr.resv_name_id = rpp.resv_name_id
AND nr.resv_name_id = ft.resv_name_id
AND ft.fiscal_bill_no is not null
AND ft.trx_amount > 0
AND ft.product = rpp.product
AND TRX_CODE NOT IN (7000)
AND ft.product NOT IN ('SERVEXC+','SERVEXC-')  
AND consumption_date BETWEEN '$desde' AND '$hasta'
ORDER BY consumption_date ASC
