CLASS lsc_zi_travel_roc_m DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zi_travel_roc_m IMPLEMENTATION.

  METHOD save_modified.
**********************************************************************
*Travel Additional Save
**********************************************************************
    DATA:
      lt_travel_log_tmp TYPE STANDARD TABLE OF zlg_travel_roc_m,
      lt_travel_log     TYPE STANDARD TABLE OF zlg_travel_roc_m.

    IF create-zi_travel_roc_m IS NOT INITIAL.
      lt_travel_log_tmp = CORRESPONDING #( create-zi_travel_roc_m ).

      LOOP AT lt_travel_log_tmp ASSIGNING FIELD-SYMBOL(<fs_travel_log>).
        <fs_travel_log>-changing_operation = 'CREATE'.
        GET TIME STAMP FIELD <fs_travel_log>-created_at.

        READ TABLE create-zi_travel_roc_m ASSIGNING FIELD-SYMBOL(<fs_travel_c>)
            WITH TABLE KEY entity
            COMPONENTS travelid = <fs_travel_log>-travelid.
        IF sy-subrc = 0.
          IF <fs_travel_c>-%control-bookingfee = cl_abap_behv=>flag_changed.
            <fs_travel_log>-changed_field_name = 'Booking Fee'.
            <fs_travel_log>-changed_value = <fs_travel_c>-bookingfee.
            TRY.
                <fs_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.

            APPEND <fs_travel_log> TO lt_travel_log.
          ENDIF.

          IF <fs_travel_c>-%control-overallstatus = cl_abap_behv=>flag_changed.
            <fs_travel_log>-changed_field_name = 'Overall Status'.
            <fs_travel_log>-changed_value = <fs_travel_c>-overallstatus.
            TRY.
                <fs_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.

            APPEND <fs_travel_log> TO lt_travel_log.
          ENDIF.
        ENDIF.
      ENDLOOP.

    ENDIF.

    IF update-zi_travel_roc_m IS NOT INITIAL.
      lt_travel_log_tmp = CORRESPONDING #( update-zi_travel_roc_m ).

      LOOP AT lt_travel_log_tmp ASSIGNING <fs_travel_log>.
        <fs_travel_log>-changing_operation = 'UPDATE'.
        GET TIME STAMP FIELD <fs_travel_log>-created_at.

        READ TABLE update-zi_travel_roc_m ASSIGNING FIELD-SYMBOL(<fs_travel_u>)
            WITH TABLE KEY entity
            COMPONENTS travelid = <fs_travel_log>-travelid.
        IF sy-subrc = 0.
          IF <fs_travel_u>-%control-bookingfee = cl_abap_behv=>flag_changed.
            <fs_travel_log>-changed_field_name = 'Booking Fee'.
            <fs_travel_log>-changed_value = <fs_travel_u>-bookingfee.
            TRY.
                <fs_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.

            APPEND <fs_travel_log> TO lt_travel_log.
          ENDIF.

          IF <fs_travel_u>-%control-overallstatus = cl_abap_behv=>flag_changed.
            <fs_travel_log>-changed_field_name = 'Overall Status'.
            <fs_travel_log>-changed_value = <fs_travel_u>-overallstatus.
            TRY.
                <fs_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.

            APPEND <fs_travel_log> TO lt_travel_log.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF delete-zi_travel_roc_m IS NOT INITIAL.
      lt_travel_log_tmp = CORRESPONDING #( delete-zi_travel_roc_m ).

      LOOP AT lt_travel_log_tmp ASSIGNING <fs_travel_log>.
        <fs_travel_log>-changing_operation = 'DELETE'.
        GET TIME STAMP FIELD <fs_travel_log>-created_at.

        READ TABLE delete-zi_travel_roc_m ASSIGNING FIELD-SYMBOL(<fs_travel_d>)
            WITH TABLE KEY entity
            COMPONENTS travelid = <fs_travel_log>-travelid.
        IF sy-subrc = 0.
          TRY.
              <fs_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.

          APPEND <fs_travel_log> TO lt_travel_log.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF lt_travel_log IS NOT INITIAL.
      MODIFY zlg_travel_roc_m FROM TABLE @lt_travel_log.
    ENDIF.

**********************************************************************
*Booking Supplement unmanaged Save
**********************************************************************
    DATA:
      lt_booksuppl_entity TYPE TABLE FOR CHANGE zi_booksuppl_roc_m,
      lt_booksuppl_db     TYPE STANDARD TABLE OF zbooksuppl_roc_m.

    IF create-zi_booksuppl_roc_m IS NOT INITIAL
      OR update-zi_booksuppl_roc_m IS NOT INITIAL.

      lt_booksuppl_entity = COND #( WHEN create-zi_booksuppl_roc_m IS NOT INITIAL
                                THEN  create-zi_booksuppl_roc_m
                                ELSE  update-zi_booksuppl_roc_m )  .

      LOOP AT lt_booksuppl_entity ASSIGNING FIELD-SYMBOL(<fs_booksuppl_entity>).
        APPEND VALUE #( travel_id             = <fs_booksuppl_entity>-travelid
                        booking_id            = <fs_booksuppl_entity>-bookingid
                        booking_supplement_id = <fs_booksuppl_entity>-bookingsupplementid
                        supplement_id         = <fs_booksuppl_entity>-supplementid
                        price                 = <fs_booksuppl_entity>-price
                        currency_code         = <fs_booksuppl_entity>-currencycode
                      ) TO lt_booksuppl_db.
      ENDLOOP.

      IF lt_booksuppl_db IS NOT INITIAL.
        MODIFY zbooksuppl_roc_m FROM TABLE @lt_booksuppl_db.
      ENDIF.
    ENDIF.

    IF delete-zi_booksuppl_roc_m IS NOT INITIAL.
      lt_booksuppl_db = CORRESPONDING #( delete-zi_booksuppl_roc_m MAPPING travel_id = travelid
                                         booking_id = bookingid booking_supplement_id = bookingsupplementid ).
      DELETE zbooksuppl_roc_m FROM TABLE @lt_booksuppl_db.
    ENDIF.


  ENDMETHOD.
ENDCLASS.

CLASS lhc_zi_travel_roc_m DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_travel_roc_m RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_travel_roc_m RESULT result.

    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_roc_m~accepttravel RESULT result.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_roc_m~rejecttravel RESULT result.

    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_roc_m~copytravel.

    METHODS recalctotprice FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_roc_m~recalctotprice.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_travel_roc_m RESULT result.

    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_roc_m~validatecustomer.

    METHODS validatedate FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_roc_m~validatedate.

    METHODS calcutetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_travel_roc_m~calcutetotalprice.

    METHODS earlynumbering_cba_booking FOR NUMBERING
      IMPORTING entities FOR CREATE zi_travel_roc_m\_booking.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zi_travel_roc_m.

ENDCLASS.

CLASS lhc_zi_travel_roc_m IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
    "result-%create = if_abap_behv=>auth-allowed.
  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA(lv_qty) = lines( entities ).

    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = '/DMO/TRV_M'
            quantity          = CONV #( lv_qty )
          IMPORTING
            number            = DATA(lv_number)
            returncode        = DATA(lv_returncode)
            returned_quantity = DATA(lv_return_qty)
        ).
      CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges INTO DATA(lo_error).

        LOOP AT entities INTO DATA(ls_entities).
          APPEND VALUE #( %cid = ls_entities-%cid %key = ls_entities-%key )
            TO failed-zi_travel_roc_m.
          APPEND VALUE #( %cid = ls_entities-%cid %key = ls_entities-%key %msg = lo_error )
            TO reported-zi_travel_roc_m.
        ENDLOOP.
        EXIT.

    ENDTRY.

    ASSERT lv_return_qty = lv_qty.

    "当前号码
    lv_number = lv_number - lv_qty.

    DATA: lt_mapped TYPE TABLE FOR MAPPED EARLY zi_travel_roc_m,
          ls_mapped LIKE LINE OF lt_mapped.

    LOOP AT entities INTO ls_entities.
      ls_mapped-%cid = ls_entities-%cid.
      ls_mapped-travelid = lv_number.

      lv_number += 1.

      APPEND ls_mapped TO mapped-zi_travel_roc_m.
    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_booking.

    DATA: lv_max_booking_id TYPE /dmo/booking_id.

    READ ENTITIES OF zi_travel_roc_m IN LOCAL MODE
      ENTITY zi_travel_roc_m BY \_booking
      FROM CORRESPONDING #( entities )
      RESULT DATA(lt_booking_result)
      LINK DATA(lt_booking_link).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entiies_group>)
      GROUP BY <ls_entiies_group>-travelid.

      "lt_booking_link中会存已经创建的booking id
      lv_max_booking_id = REDUCE #( INIT lv_max = CONV /dmo/booking_id( 0 )
                                    FOR ls_link IN lt_booking_link USING KEY entity
                                    WHERE ( source-travelid = <ls_entiies_group>-travelid )
                                    NEXT lv_max = COND /dmo/booking_id( WHEN lv_max < ls_link-target-bookingid
                                                                        THEN ls_link-target-bookingid
                                                                        ELSE lv_max ) ).
      "entities中的%target只存最新的无booking id的booking数据
      lv_max_booking_id = REDUCE #( INIT lv_max = lv_max_booking_id
                                    FOR ls_entity IN entities USING KEY entity
                                    WHERE ( travelid = <ls_entiies_group>-travelid )
                                      FOR ls_booking IN ls_entity-%target
                                    NEXT lv_max = COND /dmo/booking_id( WHEN lv_max < ls_booking-bookingid
                                                                        THEN ls_booking-bookingid
                                                                        ELSE lv_max ) ).

      "为空的booking id赋值
      LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>) USING KEY entity
       WHERE travelid = <ls_entiies_group>-travelid.

        LOOP AT <ls_entity>-%target ASSIGNING FIELD-SYMBOL(<ls_booking>).
          IF <ls_booking>-bookingid IS INITIAL.

            lv_max_booking_id += 10.

            APPEND CORRESPONDING #( <ls_booking> ) TO mapped-zi_booking_roc_m
             ASSIGNING FIELD-SYMBOL(<ls_booking_mapped>).

            <ls_booking_mapped>-bookingid = lv_max_booking_id.

          ENDIF.
        ENDLOOP.
      ENDLOOP.

    ENDLOOP.
  ENDMETHOD.

  METHOD copytravel.
    DATA:
      lt_travel_n        TYPE TABLE FOR CREATE zi_travel_roc_m,
      lt_booking_cba_n   TYPE TABLE FOR CREATE zi_travel_roc_m\_booking,
      lt_booksuppl_cba_n TYPE TABLE FOR CREATE zi_booking_roc_m\_booksuppl.

    "数据准备
    READ ENTITIES OF zi_travel_roc_m IN LOCAL MODE
      ENTITY zi_travel_roc_m
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travel_r)
      FAILED DATA(lt_failed_r).

    IF lt_failed_r IS INITIAL.
      READ ENTITIES OF zi_travel_roc_m IN LOCAL MODE
        ENTITY zi_travel_roc_m BY \_booking
        ALL FIELDS WITH CORRESPONDING #( lt_travel_r )
        RESULT DATA(lt_booking_r).

      READ ENTITIES OF zi_travel_roc_m IN LOCAL MODE
        ENTITY zi_booking_roc_m BY \_booksuppl
        ALL FIELDS WITH CORRESPONDING #( lt_booking_r )
        RESULT DATA(lt_booksuppl_r).

      LOOP AT lt_travel_r ASSIGNING FIELD-SYMBOL(<fs_travel_r>).

        APPEND VALUE #( %cid  = keys[ KEY entity travelid = <fs_travel_r>-travelid ]-%cid "keys内表里的数据
                        %data = CORRESPONDING #( <fs_travel_r> EXCEPT travelid ) )
                        TO lt_travel_n ASSIGNING FIELD-SYMBOL(<fs_travel_n>).

        "以上语句和下面语句效果一致
*        APPEND INITIAL LINE TO lt_travel_n ASSIGNING FIELD-SYMBOL(<fs_travel_n>).
*        <fs_travel_n>-%cid = keys[ key entity TravelId = <fs_travel_r>-TravelId ]-%cid.
*        <fs_travel_n>-%data = CORRESPONDING #( <fs_travel_r> EXCEPT TravelId ).

        <fs_travel_n>-begindate = cl_abap_context_info=>get_system_date(  ).
        <fs_travel_n>-enddate = cl_abap_context_info=>get_system_date(  ) + 60.
        <fs_travel_n>-overallstatus = 'O'.

        "处理booking数据
        APPEND VALUE #( %cid_ref = <fs_travel_n>-%cid ) TO lt_booking_cba_n ASSIGNING FIELD-SYMBOL(<fs_booking_cba_n>).
        LOOP AT lt_booking_r ASSIGNING FIELD-SYMBOL(<fs_booking_r>) USING KEY entity
          WHERE travelid = <fs_travel_r>-travelid.

          APPEND VALUE #( %cid  = <fs_travel_n>-%cid && <fs_booking_r>-bookingid
                          %data = CORRESPONDING #( <fs_booking_r> EXCEPT travelid bookingid ) )
                TO  <fs_booking_cba_n>-%target ASSIGNING FIELD-SYMBOL(<fs_booking_n>).

          <fs_booking_n>-bookingstatus = 'N'.

          "处理Booking supplement
          APPEND VALUE #( %cid_ref = <fs_booking_n>-%cid ) TO lt_booksuppl_cba_n ASSIGNING FIELD-SYMBOL(<fs_booksuppl_cba_n>).
          LOOP AT lt_booksuppl_r ASSIGNING FIELD-SYMBOL(<fs_booksuppl_r>) USING KEY entity
            WHERE travelid = <fs_travel_r>-travelid AND bookingid = <fs_booking_r>-bookingid.

            APPEND VALUE #( %cid  = <fs_booking_n>-%cid && <fs_booksuppl_r>-bookingsupplementid && sy-tabix
                            %data = CORRESPONDING #( <fs_booksuppl_r> EXCEPT travelid bookingid bookingsupplementid ) )
                TO  <fs_booksuppl_cba_n>-%target ASSIGNING FIELD-SYMBOL(<fs_booksuppl_n>).


          ENDLOOP.
        ENDLOOP.
      ENDLOOP.

      "更新数据  travelid bookingid booksupplid 都会重新生成
      MODIFY ENTITIES OF zi_travel_roc_m IN LOCAL MODE
        ENTITY zi_travel_roc_m CREATE
        FIELDS ( agencyid customerid begindate enddate bookingfee totalprice currencycode overallstatus description )
        WITH lt_travel_n

        ENTITY zi_travel_roc_m CREATE BY \_booking
        FIELDS (  bookingdate customerid carrierid connectionid flightdate flightprice currencycode bookingstatus )
        WITH lt_booking_cba_n

        ENTITY zi_booking_roc_m CREATE BY \_booksuppl
        FIELDS (  supplementid price currencycode )
        WITH lt_booksuppl_cba_n

        FAILED   FINAL(fail_mod)
        REPORTED FINAL(rep_mod)
        MAPPED FINAL(map_mod).

      failed = fail_mod.
      mapped = map_mod.
      reported = rep_mod.

    ENDIF.
  ENDMETHOD.

  METHOD accepttravel.

    MODIFY ENTITIES OF zi_travel_roc_m IN LOCAL MODE
      ENTITY zi_travel_roc_m
      UPDATE FIELDS ( overallstatus )
      WITH VALUE #( FOR ls_key IN keys ( %tky          = ls_key-%tky
                                         overallstatus = 'A' ) ).

    READ ENTITIES OF zi_travel_roc_m IN LOCAL MODE
      ENTITY zi_travel_roc_m
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result ( %tky   = ls_result-%tky
                                                   %param = ls_result
                      ) ).

  ENDMETHOD.

  METHOD rejecttravel.

    MODIFY ENTITIES OF zi_travel_roc_m IN LOCAL MODE
        ENTITY zi_travel_roc_m
        UPDATE FIELDS ( overallstatus )
        WITH VALUE #( FOR ls_key IN keys ( %tky          = ls_key-%tky
                                           overallstatus = 'X' ) ).

    READ ENTITIES OF zi_travel_roc_m IN LOCAL MODE
      ENTITY zi_travel_roc_m
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result ( %tky   = ls_result-%tky
                                                   %param = ls_result
                      ) ).

  ENDMETHOD.

  METHOD recalctotprice.

    TYPES: BEGIN OF ty_total,
             price TYPE /dmo/total_price ,
             curr  TYPE /dmo/currency_code,
           END OF ty_total.

    DATA: lt_total TYPE STANDARD TABLE OF ty_total.

    READ ENTITIES OF zi_travel_roc_m IN LOCAL MODE
      ENTITY zi_travel_roc_m
      FIELDS ( bookingfee currencycode )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travel).

    READ ENTITIES OF zi_travel_roc_m IN LOCAL MODE
      ENTITY zi_travel_roc_m BY \_booking
      FIELDS ( flightprice currencycode )
      WITH CORRESPONDING #( lt_travel )
      RESULT DATA(lt_ba_booking).

    READ ENTITIES OF zi_travel_roc_m IN LOCAL MODE
      ENTITY zi_booking_roc_m BY \_booksuppl
      FIELDS ( price currencycode )
      WITH CORRESPONDING #( lt_ba_booking )
      RESULT DATA(lt_ba_booksuppl).

    "只是示例，简单的金额相加算出总金额
    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).

      lt_total = VALUE #( ( price = <fs_travel>-bookingfee curr = <fs_travel>-currencycode ) ).

      LOOP AT lt_ba_booking ASSIGNING FIELD-SYMBOL(<fs_ba_booking>) USING KEY entity
        WHERE travelid = <fs_travel>-travelid.

        APPEND VALUE #( price = <fs_ba_booking>-flightprice curr = <fs_ba_booking>-currencycode ) TO lt_total.

        LOOP AT lt_ba_booksuppl ASSIGNING FIELD-SYMBOL(<fs_ba_booksuppl>) USING KEY entity
        WHERE travelid = <fs_travel>-travelid AND bookingid = <fs_ba_booking>-bookingid.
          APPEND VALUE #( price = <fs_ba_booksuppl>-price curr = <fs_ba_booksuppl>-currencycode ) TO lt_total.
        ENDLOOP.
      ENDLOOP.

      clear <fs_travel>-totalprice.
      LOOP AT  lt_total INTO DATA(ls_total).
        <fs_travel>-totalprice = <fs_travel>-totalprice + ls_total-price.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zi_travel_roc_m IN LOCAL MODE
      ENTITY zi_travel_roc_m
      UPDATE FIELDS ( totalprice )
      WITH CORRESPONDING #( lt_travel ).

  ENDMETHOD.



  METHOD get_instance_features.

    READ ENTITIES OF zi_travel_roc_m IN LOCAL MODE
      ENTITY zi_travel_roc_m
      FIELDS ( travelid overallstatus )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel (
      %tky = ls_travel-%tky
      %features-%action-accepttravel = COND #( WHEN ls_travel-overallstatus = 'A'
                                               THEN if_abap_behv=>fc-o-disabled
                                               ELSE if_abap_behv=>fc-o-enabled )
      %features-%action-rejecttravel = COND #( WHEN ls_travel-overallstatus = 'X'
                                               THEN if_abap_behv=>fc-o-disabled
                                               ELSE if_abap_behv=>fc-o-enabled )
      %features-%assoc-_booking = COND #( WHEN ls_travel-overallstatus = 'X'
                                               THEN if_abap_behv=>fc-o-disabled
                                               ELSE if_abap_behv=>fc-o-enabled )
     ) ).

  ENDMETHOD.

  METHOD validatecustomer.

    READ ENTITY IN LOCAL MODE zi_travel_roc_m
      FIELDS ( customerid )
      WITH CORRESPONDING #( keys  )
      RESULT DATA(lt_travel).

    "根据customer id 删除重复项目
    DATA: lt_cust TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.
    lt_cust = CORRESPONDING #( lt_travel DISCARDING DUPLICATES     MAPPING customer_id = customerid ).

    DELETE lt_cust WHERE customer_id IS INITIAL.

    IF lt_cust IS NOT INITIAL.
      SELECT
        FROM /dmo/customer
      FIELDS customer_id
         FOR ALL ENTRIES IN @lt_cust
       WHERE customer_id = @lt_cust-customer_id
         INTO TABLE @DATA(lt_cust_db).
    ENDIF.

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).
      IF <fs_travel>-customerid IS INITIAL OR
        NOT line_exists(  lt_cust_db[ customer_id = <fs_travel>-customerid  ] ).

        APPEND VALUE #( %tky = <fs_travel>-%tky ) TO failed-zi_travel_roc_m.
        APPEND VALUE #( %tky                = <fs_travel>-%tky
                        %element-customerid = if_abap_behv=>mk-on
                        %msg                = NEW /dmo/cm_flight_messages(
                        textid      = /dmo/cm_flight_messages=>customer_unkown
                        customer_id = <fs_travel>-customerid
                        severity    = if_abap_behv_message=>severity-error
                        ) ) TO reported-zi_travel_roc_m.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatedate.
    READ ENTITY IN LOCAL MODE zi_travel_roc_m
      FIELDS ( begindate enddate )
      WITH CORRESPONDING #( keys  )
      RESULT DATA(lt_travel).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).
      IF <fs_travel>-begindate > <fs_travel>-enddate.

        APPEND VALUE #( %tky = <fs_travel>-%tky ) TO failed-zi_travel_roc_m.
        APPEND VALUE #( %tky               = <fs_travel>-%tky
                        %element-begindate = if_abap_behv=>mk-on
                        %element-enddate   = if_abap_behv=>mk-on
                        %msg               = NEW /dmo/cm_flight_messages(
                        textid     = /dmo/cm_flight_messages=>begin_date_bef_end_date
                        begin_date = <fs_travel>-begindate
                        end_date   = <fs_travel>-enddate
                        severity   = if_abap_behv_message=>severity-error
                        ) ) TO reported-zi_travel_roc_m.

      ELSEIF <fs_travel>-begindate <= cl_abap_context_info=>get_system_date( ).

        APPEND VALUE #( %tky = <fs_travel>-%tky ) TO failed-zi_travel_roc_m.
        APPEND VALUE #( %tky               = <fs_travel>-%tky
                        %element-begindate = if_abap_behv=>mk-on
                        %msg               = NEW /dmo/cm_flight_messages(
                        textid     = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
                        begin_date = <fs_travel>-begindate
                        severity   = if_abap_behv_message=>severity-error
                        ) ) TO reported-zi_travel_roc_m.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD calcutetotalprice.

    MODIFY ENTITIES OF zi_travel_roc_m IN LOCAL MODE
      ENTITY zi_travel_roc_m
      EXECUTE recalctotprice
      FROM CORRESPONDING #( keys ).

  ENDMETHOD.

ENDCLASS.
