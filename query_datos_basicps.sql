SELECT 
n.guest_name apellido,
n.GUEST_FIRST_NAME nombre,
n.address1||n.address2 direccion,
n.country_desc pais,
n.city ciudad,
n.phone_no telefono,
n.email email,
n.rg_udfc05 patente,
n.tax1_no cedula,
n.passport pasaporte,
n.group_name grupo,
n.adults+n.children guest_number,
n.room room,
actual_check_in_date check_in,
actual_check_out_date check_out
FROM name_reservation n
WHERE n.confirmation_no = &pin_numero;
