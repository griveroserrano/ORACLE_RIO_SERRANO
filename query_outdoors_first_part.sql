   SELECT block_id,
       block_descripcion block_name,
       nr.resv_name_id RSV_Number,
       nr.first Nombre,
    --   nr.name_usage_type,  
       DECODE (nr.NAME_USAGE_TYPE,'AG',0,1) as Pax,
       DECODE (nr.NAME_USAGE_TYPE,'DG',0,1) as Pax_acompñante_1,
       0 as Pax_acompñante_2,
       reservation_ref.get_name(nr.travel_agent_id) Agencia, 
       nr.nationality,
       CASE
         WHEN  (EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM nr.birth_date)) > 18 
       THEN 1
       ELSE 0
       END ADULTS,
              CASE
         WHEN  (EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM nr.birth_date)) < 18 
       THEN 1
       ELSE 0
       END CHILDS,
       nr.room room_number,
       oud.servicio_id trace_id,
       oud.servicio_obs trace_name,
       oud.servicio_depto movimiento,
       (SELECT usr.nombre
          FROM aabb_platform.G_TB_USUARIOS usr
          WHERE usr.id = oud.chofer_id) chofer,         
       (SELECT usr.nombre
          FROM aabb_platform.G_TB_USUARIOS usr
          WHERE usr.id = oud.guia_id) guia, 
       oud.servicio_fecha trace_date,
       hora_salida hora_inicio,
       hora_termino hora_fin,
       (SELECT DISTINCT(l.trace_text) 
             FROM aabb_platform.box_lunch l
            WHERE l.trace_id = oud.servicio_id) box_lunch,
       (SELECT movil 
          FROM aabb_platform.G_TB_OUTDOORS_MOVILES m
         WHERE m.id = oud.movil_id)vehiculo,
       oud.servicio_ratecode,        
       nr.actual_check_in_date check_in,
       nr.actual_check_out_date check_out,  
       EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM nr.birth_date)edad,
       nr.gender sexo,
       confirmation_ref.get_room_type_label (nr.room_category_label,nr.booked_room_category,rn.spg_upgrade_confirmed_roomtype,rn.spg_disclose_room_type_yn) room_type       
FROM name_reservation nr,
     reservation_name rn,
     aabb_platform.G_TB_OUTDOORS oud
 WHERE nr.resv_name_id =  rn.resv_name_id
   AND rn.resv_name_id = oud.reserva_id


UNION ALL
SELECT outd.block_id,
       outd.block_descripcion,
       outd.reserva_id,
       rn.GUEST_FIRST_NAME || ' ' || rn.GUEST_LAST_NAME acomp,
    --   rn.name_usage_type,
   --    outd.servicio_obs,
       DECODE (rn.NAME_USAGE_TYPE,'DG',1,0) as PAX,
      CASE
        WHEN rn.NAME_USAGE_TYPE = 'AG' AND (REGEXP_INSTR (outd.accompany_names, ',|/', 1, 2, 0, 'i')) = 0 
          THEN 1 
            ELSE 0 
      END as PAX2,
       
      CASE
        WHEN (REGEXP_INSTR (outd.accompany_names, ',|/', 1, 2, 0, 'i')) > 0 
          THEN 1 
            ELSE 0 
      END as PAX3,
       reservation_ref.get_name(outd.travel_agent_id) Agencia,
      outd.nationality nacionalidad,
       CASE
         WHEN (EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM inv.Date_of_birth)) > 18 
            THEN 1
         ELSE 0
       END ADULTS,
       CASE
         WHEN (EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM inv.Date_of_birth )) < 18 
            THEN 1
         ELSE 0
       END CHILDS, 
       outd.room as room_number,  
       outd.servicio_id trace_id,
       outd.servicio_obs trace_name,
       outd.servicio_depto movimiento,
       (SELECT usr.nombre
          FROM aabb_platform.G_TB_USUARIOS usr
         WHERE usr.id = outd.chofer_id) chofer,
       (SELECT usr.nombre
          FROM aabb_platform.G_TB_USUARIOS usr
          WHERE usr.id = outd.guia_id) guia,
          outd.servicio_fecha trace_date,
          outd.hora_salida hora_inicio,
          outd.hora_termino hora_fin,  
          (SELECT DISTINCT(l.trace_text) 
             FROM aabb_platform.box_lunch l
            WHERE l.trace_id = outd.servicio_id) box_lunch,
        (SELECT movil 
          FROM aabb_platform.G_TB_OUTDOORS_MOVILES m
          WHERE m.id = outd.movil_id)vehiculo,
          outd.servicio_ratecode rate_code,
          
       rn.actual_check_in_date check_in,
       rn.actual_check_out_date check_out,     
       EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM inv.Date_of_birth) edad,
       inv.gender sexo,
      confirmation_ref.get_room_type_label (outd.room_category_label,outd.booked_room_category,rn.spg_upgrade_confirmed_roomtype,rn.spg_disclose_room_type_yn) room_type  
  from reservation_name rn, IND_NAME_VIEW inv,
        (SELECT oud.reserva_id,
                   oud.guia_id,
                 oud.chofer_id,
                 oud.movil_id,
                 oud.servicio_fecha,
              oud.hora_salida,
             oud.hora_termino,
             oud.excursion_id,
             oud.servicio_depto,
             oud.servicio_obs,
             oud.block_id,
             oud.servicio_id,
             oud.servicio_ratecode,
             oud.block_descripcion,
             oud.accompany_names,
             nr.room ,
             nr.nationality,
             nr.travel_agent_id,
             nr.room_category_label,
             nr.booked_room_category      
         FROM aabb_platform.G_TB_OUTDOORS oud,
                       name_reservation nr
                WHERE oud.reserva_id = nr.resv_name_id
                AND oud.reserva_id IN (select parent_resv_name_id 
                                           FROM reservation_name)) outd

   WHERE  rn.NAME_USAGE_TYPE = 'AG' 
   and inv.name_id = rn.name_id
   and outd.reserva_id = rn.parent_resv_name_id
    order by 3,4
