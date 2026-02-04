CLASS lhc_zi_booksuppl_roc_d DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS setbooksupplid FOR DETERMINE ON SAVE
      IMPORTING keys FOR zi_booksuppl_roc_d~setbooksupplid.
    METHODS calctotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_booksuppl_roc_d~calctotalprice.
    METHODS validatesupplement FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_booksuppl_roc_d~validatesupplement.

ENDCLASS.

CLASS lhc_zi_booksuppl_roc_d IMPLEMENTATION.

  METHOD setbooksupplid.
    DATA:
      lv_max_booksupplid  TYPE zi_booksuppl_roc_d-bookingsupplementid,
      lt_booksuppl_update TYPE TABLE FOR UPDATE zi_booksuppl_roc_d.

    READ ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_booksuppl_roc_d BY \_booking
      FIELDS ( bookinguuid )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_booking).

    LOOP AT lt_booking ASSIGNING FIELD-SYMBOL(<fs_booking>).

      READ ENTITIES OF zi_travel_roc_d IN LOCAL MODE
       ENTITY zi_booking_roc_d BY \_booksuppl
       ALL FIELDS
       WITH VALUE #( ( %tky = <fs_booking>-%tky ) )
       RESULT DATA(lt_booksuppl).

      lv_max_booksupplid = '0000'.
      LOOP AT lt_booksuppl ASSIGNING FIELD-SYMBOL(<fs_booksuppl>).
        IF lv_max_booksupplid < <fs_booking>-bookingid.
          lv_max_booksupplid = <fs_booking>-bookingid.
        ENDIF.
      ENDLOOP.

      CLEAR lt_booksuppl_update[].
      LOOP AT lt_booksuppl ASSIGNING <fs_booksuppl> WHERE bookingsupplementid IS INITIAL.
        lv_max_booksupplid = lv_max_booksupplid + 10.
        APPEND VALUE #(  %tky = <fs_booksuppl>-%tky bookingsupplementid  = lv_max_booksupplid ) TO lt_booksuppl_update.
      ENDLOOP.

      MODIFY ENTITIES OF zi_travel_roc_d IN LOCAL MODE
        ENTITY zi_booksuppl_roc_d
        UPDATE FIELDS ( bookingsupplementid )
        WITH lt_booksuppl_update .

    ENDLOOP.
  ENDMETHOD.

  METHOD calctotalprice.

    READ ENTITIES OF zi_travel_roc_d IN LOCAL MODE
        ENTITY zi_booksuppl_roc_d BY \_travel
        FIELDS ( traveluuid )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_travel).


    MODIFY ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_travel_roc_d
      EXECUTE recalctotprice
      FROM CORRESPONDING #( lt_travel ).

  ENDMETHOD.

  METHOD validatesupplement.

    READ ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_booksuppl_roc_d
      FIELDS ( supplementid )
      WITH CORRESPONDING #( keys  )
      RESULT DATA(lt_booksuppl).

    READ ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_booksuppl_roc_d BY \_travel
      FROM CORRESPONDING #( lt_booksuppl )
      LINK DATA(lt_booksuppl_travel_link).

    READ ENTITIES OF zi_travel_roc_d IN LOCAL MODE
      ENTITY zi_booksuppl_roc_d BY \_booking
      FROM CORRESPONDING #( lt_booksuppl )
      LINK DATA(lt_booksuppl_booking_link).

    "根据customer id 删除重复项目
    DATA: lt_supplement TYPE SORTED TABLE OF /dmo/supplement WITH UNIQUE KEY supplement_id.
    lt_supplement = CORRESPONDING #( lt_booksuppl DISCARDING DUPLICATES     MAPPING supplement_id = supplementid ).

    DELETE lt_supplement WHERE supplement_id IS INITIAL.

    IF lt_supplement IS NOT INITIAL.
      SELECT
        FROM /dmo/supplement
      FIELDS supplement_id
         FOR ALL ENTRIES IN @lt_supplement
       WHERE supplement_id = @lt_supplement-supplement_id
         INTO TABLE @DATA(lt_supplement_db).
    ENDIF.

    LOOP AT lt_booksuppl ASSIGNING FIELD-SYMBOL(<fs_booksuppl>).
      APPEND VALUE #( %tky        = <fs_booksuppl>-%tky
                      %state_area = 'InvalidBooksuppl' )
                TO reported-zi_booksuppl_roc_d.

      IF <fs_booksuppl>-supplementid IS INITIAL OR
        NOT line_exists(  lt_supplement_db[ supplement_id = <fs_booksuppl>-supplementid  ] ).

        APPEND VALUE #( %tky = <fs_booksuppl>-%tky ) TO failed-zi_booksuppl_roc_d.
        APPEND VALUE #( %tky                  = <fs_booksuppl>-%tky
                        %state_area           = 'InvalidBooksuppl'
                        %path                 = VALUE #( zi_booking_roc_d-%tky = lt_booksuppl_booking_link[ KEY id source-%tky = <fs_booksuppl>-%tky ]-target-%tky
                                                         zi_travel_roc_d-%tky  = lt_booksuppl_travel_link[ KEY id source-%tky = <fs_booksuppl>-%tky ]-target-%tky )

                        %element-supplementid = if_abap_behv=>mk-on
                        %msg                  = NEW /dmo/cm_flight_messages(
                                                         textid                = /dmo/cm_flight_messages=>supplement_unknown
                                                         supplement_id         = <fs_booksuppl>-supplementid
                                                         severity              = if_abap_behv_message=>severity-error
                        ) ) TO reported-zi_booksuppl_roc_d.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
