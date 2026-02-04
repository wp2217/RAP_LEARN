CLASS lhc_zi_booking_roc_d DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS setbookinglid FOR DETERMINE ON SAVE
      IMPORTING keys FOR zi_booking_roc_d~setbookinglid.
    METHODS calctotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_booking_roc_d~calctotalprice.
    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_booking_roc_d~validatecustomer.

ENDCLASS.

CLASS lhc_zi_booking_roc_d IMPLEMENTATION.

  METHOD setbookinglid.

    DATA:
      lv_max_bookingid  TYPE zi_booking_roc_d-bookingid,
      lt_booking_update TYPE TABLE FOR UPDATE zi_booking_roc_d.

    READ ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_booking_roc_d BY \_travel
      FIELDS ( traveluuid )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travel).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).

      READ ENTITIES OF zi_travel_roc_d IN LOCAL MODE
       ENTITY zi_travel_roc_d BY \_booking
       ALL FIELDS
       WITH VALUE #( ( %tky = <fs_travel>-%tky ) )
       RESULT DATA(lt_booking).

      lv_max_bookingid = '0000'.
      LOOP AT lt_booking ASSIGNING FIELD-SYMBOL(<fs_booking>).
        IF lv_max_bookingid < <fs_booking>-bookingid.
          lv_max_bookingid = <fs_booking>-bookingid.
        ENDIF.
      ENDLOOP.

      CLEAR lt_booking_update[].
      LOOP AT lt_booking ASSIGNING <fs_booking> WHERE bookingid IS INITIAL.
        lv_max_bookingid = lv_max_bookingid + 10.
        APPEND VALUE #(  %tky = <fs_booking>-%tky bookingid = lv_max_bookingid ) TO lt_booking_update.
      ENDLOOP.

      MODIFY ENTITIES OF zi_travel_roc_d IN LOCAL MODE
        ENTITY zi_booking_roc_d
        UPDATE FIELDS ( bookingid )
        WITH lt_booking_update .

    ENDLOOP.



  ENDMETHOD.

  METHOD calctotalprice.

    READ ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_booking_roc_d BY \_travel
      FIELDS ( traveluuid )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travel).


    MODIFY ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_travel_roc_d
      EXECUTE recalctotprice
      FROM CORRESPONDING #( lt_travel ).


  ENDMETHOD.

  METHOD validatecustomer.

    READ ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_booking_roc_d
          FIELDS ( customerid )
          WITH CORRESPONDING #( keys  )
          RESULT DATA(lt_booking).

    READ ENTITIES OF zi_travel_roc_d IN LOCAL MODE
     ENTITY zi_booking_roc_d BY \_travel
     FROM CORRESPONDING #( lt_booking )
     LINK DATA(lt_booking_travel_link).

    "根据customer id 删除重复项目
    DATA: lt_cust TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.
    lt_cust = CORRESPONDING #( lt_booking DISCARDING DUPLICATES     MAPPING customer_id = customerid ).

    DELETE lt_cust WHERE customer_id IS INITIAL.

    IF lt_cust IS NOT INITIAL.
      SELECT
        FROM /dmo/customer
      FIELDS customer_id
         FOR ALL ENTRIES IN @lt_cust
       WHERE customer_id = @lt_cust-customer_id
         INTO TABLE @DATA(lt_cust_db).
    ENDIF.

    LOOP AT lt_booking ASSIGNING FIELD-SYMBOL(<fs_booking>).
      APPEND VALUE #( %tky        = <fs_booking>-%tky
                      %state_area = 'InvalidCustomer' )
                TO reported-zi_booking_roc_d.

      IF <fs_booking>-customerid IS INITIAL OR
        NOT line_exists(  lt_cust_db[ customer_id = <fs_booking>-customerid  ] ).

        APPEND VALUE #( %tky = <fs_booking>-%tky ) TO failed-zi_booking_roc_d.
        APPEND VALUE #( %tky                = <fs_booking>-%tky
                        %state_area         = 'InvalidCustomer'
                        %path               = VALUE #( zi_travel_roc_d-%tky = lt_booking_travel_link[ KEY id
                                         source-%tky = <fs_booking>-%tky ]-target-%tky )

                        %element-customerid = if_abap_behv=>mk-on
                        %msg                = NEW /dmo/cm_flight_messages(
                                                       textid               = /dmo/cm_flight_messages=>customer_unkown
                                                       customer_id          = <fs_booking>-customerid
                                                       severity             = if_abap_behv_message=>severity-error
                        ) ) TO reported-zi_booking_roc_d.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
