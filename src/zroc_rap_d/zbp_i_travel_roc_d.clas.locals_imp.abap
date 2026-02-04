CLASS lhc_zi_travel_roc_d DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_travel_roc_d RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_travel_roc_d RESULT result.

    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE zi_travel_roc_d.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE zi_travel_roc_d.

    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_roc_d~accepttravel RESULT result.

    METHODS recalctotprice FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_roc_d~recalctotprice.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_roc_d~rejecttravel RESULT result.

    METHODS deductdiscount FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_roc_d~deductdiscount RESULT result.
    METHODS calctotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_travel_roc_d~calctotalprice.

    METHODS setstatusopen FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_travel_roc_d~setstatusopen.

    METHODS settravelid FOR DETERMINE ON SAVE
      IMPORTING keys FOR zi_travel_roc_d~settravelid.
    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_roc_d~validatecustomer.

    " Draft additional Action
    METHODS activate FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_roc_d~activate.

    METHODS discard FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_roc_d~discard.

    METHODS edit FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_roc_d~edit.

    METHODS resume FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_roc_d~resume.

ENDCLASS.

CLASS lhc_zi_travel_roc_d IMPLEMENTATION.

  METHOD get_global_authorizations.
    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
        ID '/DMO/CNTRY' DUMMY
        ID 'ACTVT' FIELD '01'.

      result-%create = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized ).
    ENDIF.

    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
        ID '/DMO/CNTRY' DUMMY
        ID 'ACTVT' FIELD '02'.

      result-%update = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized ).
    ENDIF.

    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
        ID '/DMO/CNTRY' DUMMY
        ID 'ACTVT' FIELD '06'.

      result-%delete = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized ).
    ENDIF.
  ENDMETHOD.


  METHOD get_instance_authorizations.
    DATA:
      lv_auth_update TYPE abp_behv_auth,
      lv_auth_delete TYPE abp_behv_auth.

    READ ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_travel_roc_d
      FIELDS (  agencyid )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travels)
      FAILED failed.

    CHECK lt_travels IS NOT INITIAL.

    SELECT
      FROM /dmo/a_travel_d AS a
      JOIN /dmo/agency AS b
        ON a~agency_id = b~agency_id
      FIELDS a~travel_uuid, a~travel_id, a~agency_id, b~country_code
       FOR ALL ENTRIES IN @lt_travels
      WHERE a~travel_uuid = @lt_travels-traveluuid
       INTO TABLE @DATA(lt_agency_ctry).

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<fs_travels>).
      CLEAR: lv_auth_update,lv_auth_delete.

      READ TABLE lt_agency_ctry INTO DATA(ls_agency_ctry)
       WITH KEY travel_uuid = <fs_travels>-traveluuid.

      IF sy-subrc = 0.
        IF requested_authorizations-%update = if_abap_behv=>mk-on.
          AUTHORITY-CHECK OBJECT '/DMO/TRVL'
            ID '/DMO/CNTRY' FIELD ls_agency_ctry-country_code
            ID 'ACTVT' FIELD '02'.

          lv_auth_update = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized ).

          IF lv_auth_update = if_abap_behv=>auth-unauthorized.
            APPEND VALUE #( %tky = <fs_travels>-%tky ) TO failed-zi_travel_roc_d.

            APPEND VALUE #( %tky              = <fs_travels>-%tky
                            %msg              = NEW /dmo/cm_flight_messages(
                            textid    = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                            agency_id = ls_agency_ctry-agency_id
                            severity  = if_abap_behv_message=>severity-error
                            )
                            %element-agencyid = if_abap_behv=>mk-on
            ) TO reported-zi_travel_roc_d.
          ENDIF.

        ENDIF.


        IF requested_authorizations-%delete = if_abap_behv=>mk-on.
          AUTHORITY-CHECK OBJECT '/DMO/TRVL'
            ID '/DMO/CNTRY' FIELD ls_agency_ctry-country_code
            ID 'ACTVT' FIELD '06'.

          lv_auth_delete = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized ).

          IF lv_auth_delete = if_abap_behv=>auth-unauthorized.
            APPEND VALUE #( %tky = <fs_travels>-%tky ) TO failed-zi_travel_roc_d.

            APPEND VALUE #( %tky              = <fs_travels>-%tky
                            %msg              = NEW /dmo/cm_flight_messages(
                            textid    = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                            agency_id = ls_agency_ctry-agency_id
                            severity  = if_abap_behv_message=>severity-error
                            )
                            %element-agencyid = if_abap_behv=>mk-on
            ) TO reported-zi_travel_roc_d.
          ENDIF.
        ENDIF.

      ELSE.
      ENDIF.

      APPEND VALUE #( traveluuid = <fs_travels>-traveluuid
                      %update    = lv_auth_update
                      %delete    = lv_auth_delete ) TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD precheck_create.
    DATA:
          lv_auth TYPE abp_behv_auth.

    CHECK entities[] IS NOT INITIAL.

    SELECT
      agency_id,
      country_code
      FROM /dmo/agency
       FOR ALL ENTRIES IN @entities
      WHERE agency_id = @entities-agencyid
       INTO TABLE @DATA(lt_agency).

    SORT lt_agency BY agency_id.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_travels>).
      CLEAR: lv_auth.

      READ TABLE lt_agency INTO DATA(ls_agency) WITH KEY agency_id = <fs_travels>-agencyid
        BINARY SEARCH.

      IF sy-subrc = 0.
        AUTHORITY-CHECK OBJECT '/DMO/TRVL'
         ID '/DMO/CNTRY' FIELD ls_agency-country_code
         ID 'ACTVT' FIELD '01'.

        lv_auth = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized ).
      ENDIF.

      IF lv_auth = if_abap_behv=>auth-unauthorized.
        APPEND VALUE #( %cid = <fs_travels>-%cid ) TO failed-zi_travel_roc_d.

        APPEND VALUE #( %cid              = <fs_travels>-%cid
                        %msg              = NEW /dmo/cm_flight_messages(
                        textid    = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                        agency_id = ls_agency-agency_id
                        severity  = if_abap_behv_message=>severity-error
                        )
                        %element-agencyid = if_abap_behv=>mk-on
        ) TO reported-zi_travel_roc_d.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD precheck_update.

    DATA:
      lv_auth TYPE abp_behv_auth.

    CHECK entities[] IS NOT INITIAL.

    SELECT
      agency_id,
      country_code
      FROM /dmo/agency
       FOR ALL ENTRIES IN @entities
      WHERE agency_id = @entities-agencyid
       INTO TABLE @DATA(lt_agency).

    SORT lt_agency BY agency_id.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_travels>).
      CLEAR: lv_auth.

      READ TABLE lt_agency INTO DATA(ls_agency) WITH KEY agency_id = <fs_travels>-agencyid
        BINARY SEARCH.

      IF sy-subrc = 0.
        AUTHORITY-CHECK OBJECT '/DMO/TRVL'
         ID '/DMO/CNTRY' FIELD ls_agency-country_code
         ID 'ACTVT' FIELD '02'.

        lv_auth = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized ).
      ENDIF.

      IF lv_auth = if_abap_behv=>auth-unauthorized.
        APPEND VALUE #( %tky = <fs_travels>-%tky ) TO failed-zi_travel_roc_d.

        APPEND VALUE #( %tky              = <fs_travels>-%tky
                        %msg              = NEW /dmo/cm_flight_messages(
                        textid    = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                        agency_id = ls_agency-agency_id
                        severity  = if_abap_behv_message=>severity-error
                        )
                        %element-agencyid = if_abap_behv=>mk-on
        ) TO reported-zi_travel_roc_d.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD accepttravel.

    MODIFY ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_travel_roc_d
      UPDATE FIELDS ( overallstatus )
      WITH VALUE #( FOR ls_key IN keys ( %tky          = ls_key-%tky
                                         overallstatus = 'A' ) ).

    READ ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_travel_roc_d
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result ( %tky   = ls_result-%tky
                                                   %param = ls_result
                      ) ).

    APPEND VALUE #( %msg = new_message(
                    id       = '/DMO/CM_FLIGHT'
                    number   = '001'
                    severity = if_abap_behv_message=>severity-success
                    v1       = '[Approved Ok!]'
                    )
    ) TO reported-zi_travel_roc_d.

  ENDMETHOD.

  METHOD rejecttravel.

    MODIFY ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_travel_roc_d
      UPDATE FIELDS ( overallstatus )
      WITH VALUE #( FOR ls_key IN keys ( %tky          = ls_key-%tky
                                         overallstatus = 'X' ) ).

    READ ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_travel_roc_d
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result ( %tky   = ls_result-%tky
                                                   %param = ls_result
                      ) ).

  ENDMETHOD.

  METHOD recalctotprice.

    TYPES: BEGIN OF ty_total,
             price TYPE /dmo/total_price,
             curr  TYPE /dmo/currency_code,
           END OF ty_total.

    DATA: lt_total TYPE STANDARD TABLE OF ty_total.

    READ ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_travel_roc_d
      FIELDS ( bookingfee currencycode )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travel).

    READ ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_travel_roc_d BY \_booking
      FIELDS ( flightprice currencycode )
      WITH CORRESPONDING #( lt_travel )
      RESULT DATA(lt_ba_booking).

    READ ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_booking_roc_d BY \_booksuppl
      FIELDS ( price currencycode )
      WITH CORRESPONDING #( lt_ba_booking )
      RESULT DATA(lt_ba_booksuppl).

    "只是示例，简单的金额相加算出总金额
    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).

      lt_total = VALUE #( ( price = <fs_travel>-bookingfee curr = <fs_travel>-currencycode ) ).

      LOOP AT lt_ba_booking ASSIGNING FIELD-SYMBOL(<fs_ba_booking>)
        WHERE traveluuid = <fs_travel>-traveluuid.

        APPEND VALUE #( price = <fs_ba_booking>-flightprice curr = <fs_ba_booking>-currencycode ) TO lt_total.

        LOOP AT lt_ba_booksuppl ASSIGNING FIELD-SYMBOL(<fs_ba_booksuppl>)
        WHERE traveluuid = <fs_travel>-traveluuid AND bookinguuid = <fs_ba_booking>-bookinguuid.
          APPEND VALUE #( price = <fs_ba_booksuppl>-price curr = <fs_ba_booksuppl>-currencycode ) TO lt_total.
        ENDLOOP.
      ENDLOOP.

      CLEAR <fs_travel>-totalprice.
      LOOP AT  lt_total INTO DATA(ls_total).
        <fs_travel>-totalprice = <fs_travel>-totalprice + ls_total-price.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_travel_roc_d
      UPDATE FIELDS ( totalprice )
      WITH CORRESPONDING #( lt_travel ).

  ENDMETHOD.

  METHOD deductdiscount.
    DATA:
      lt_keys TYPE TABLE FOR ACTION IMPORT zi_travel_roc_d~deductdiscount.

    lt_keys = keys.

    LOOP AT lt_keys ASSIGNING FIELD-SYMBOL(<fs_keys>)
      WHERE %param-discount IS INITIAL OR %param-discount <= 0 OR %param-discount >= 100.


      APPEND VALUE #( %tky = <fs_keys>-%tky )
              TO failed-zi_travel_roc_d.

      APPEND VALUE #( %tky                = <fs_keys>-%tky
                      %element-bookingfee = if_abap_behv=>mk-on
                      %msg                = NEW /dmo/cm_flight_messages(
                      textid   = /dmo/cm_flight_messages=>discount_invalid
                      severity = if_abap_behv_message=>severity-error
                      ) )
              TO reported-zi_travel_roc_d.

      DELETE lt_keys.
    ENDLOOP.

    CHECK lt_keys IS NOT INITIAL.

    READ ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_travel_roc_d
      FIELDS ( bookingfee )
      WITH CORRESPONDING #( lt_keys )
      RESULT DATA(lt_travel).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).
      DATA: lv_discount_rate TYPE decfloat16.
      DATA: lt_travel_new TYPE TABLE FOR UPDATE zi_travel_roc_d.

      DATA(lv_discount) = lt_keys[ KEY id  %tky = <fs_travel>-%tky ]-%param-discount.

      lv_discount_rate = lv_discount / 100.

      DATA(lv_discount_value) = <fs_travel>-bookingfee - lv_discount_rate * <fs_travel>-bookingfee.

      APPEND VALUE #( %tky = <fs_travel>-%tky bookingfee = lv_discount_value ) TO lt_travel_new.

    ENDLOOP.

    MODIFY ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_travel_roc_d
      UPDATE FIELDS ( bookingfee )
      WITH lt_travel_new.

    READ ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_travel_roc_d
      ALL FIELDS
      WITH CORRESPONDING #( lt_keys )
      RESULT DATA(lt_travel_modify).

    result = VALUE #( FOR ls_travel_modify IN lt_travel_modify
                      ( %tky = ls_travel_modify-%tky %param = ls_travel_modify ) ).
  ENDMETHOD.



  METHOD calctotalprice.

    MODIFY ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_travel_roc_d
      EXECUTE recalctotprice
      FROM CORRESPONDING #( keys ).

  ENDMETHOD.

  METHOD setstatusopen.

    MODIFY ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_travel_roc_d
      UPDATE FIELDS ( overallstatus )
      WITH VALUE #( FOR ls_key IN keys ( %tky          = ls_key-%tky
                                         overallstatus = 'O' ) ).

  ENDMETHOD.

  METHOD settravelid.

    SELECT MAX( travel_id )
    FROM /dmo/a_travel_d
    INTO @DATA(lv_travelid_max).

    lv_travelid_max = lv_travelid_max + 1.

    MODIFY ENTITIES OF zi_travel_roc_d IN LOCAL MODE
     ENTITY zi_travel_roc_d
     UPDATE FIELDS ( travelid )
     WITH VALUE #( FOR ls_key IN keys ( %tky     = ls_key-%tky
                                        travelid = lv_travelid_max ) ).


  ENDMETHOD.

  METHOD validatecustomer.

    READ ENTITY IN LOCAL MODE zi_travel_roc_d
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
      APPEND VALUE #( %tky        = <fs_travel>-%tky
                      %state_area = 'InvalidCustomer' )
                TO reported-zi_travel_roc_d.

      IF <fs_travel>-customerid IS INITIAL OR
        NOT line_exists(  lt_cust_db[ customer_id = <fs_travel>-customerid  ] ).

        APPEND VALUE #( %tky = <fs_travel>-%tky ) TO failed-zi_travel_roc_d.
        APPEND VALUE #( %tky                = <fs_travel>-%tky
                        %state_area         = 'InvalidCustomer'
                        %element-customerid = if_abap_behv=>mk-on
                        %msg                = NEW /dmo/cm_flight_messages(
                        textid      = /dmo/cm_flight_messages=>customer_unkown
                        customer_id = <fs_travel>-customerid
                        severity    = if_abap_behv_message=>severity-error
                        ) ) TO reported-zi_travel_roc_d.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD activate.
  ENDMETHOD.

  METHOD discard.
  ENDMETHOD.

  METHOD edit.
  ENDMETHOD.

  METHOD resume.
  ENDMETHOD.

ENDCLASS.
