CLASS lhc_zi_booking_roc_m DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS earlynumbering_cba_booksuppl FOR NUMBERING
      IMPORTING entities FOR CREATE zi_booking_roc_m\_booksuppl.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_booking_roc_m RESULT result.
    METHODS calcutetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_booking_roc_m~calcutetotalprice.

ENDCLASS.

CLASS lhc_zi_booking_roc_m IMPLEMENTATION.

  METHOD earlynumbering_cba_booksuppl.
    DATA: lv_max_booksuppl_id TYPE /dmo/supplement_id.

    READ ENTITIES OF zi_travel_roc_m IN LOCAL MODE
      ENTITY zi_booking_roc_m BY \_booksuppl
      FROM CORRESPONDING #( entities )
      RESULT DATA(lt_booksuppl_result)
      LINK DATA(lt_booksuppl_link).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entiies_group>)
      GROUP BY <ls_entiies_group>-%tky.

      "lt_booksuppl_link中会存已经创建的booksuppl id
      lv_max_booksuppl_id = REDUCE #( INIT lv_max = CONV /dmo/supplement_id( 0 )
                                    FOR ls_link IN lt_booksuppl_link USING KEY entity
                                    WHERE ( source-travelid = <ls_entiies_group>-travelid AND
                                            source-bookingid = <ls_entiies_group>-bookingid )
                                    NEXT lv_max = COND /dmo/supplement_id( WHEN lv_max < ls_link-target-bookingsupplementid
                                                                        THEN ls_link-target-bookingsupplementid
                                                                        ELSE lv_max ) ).
      "entities中的%target只存最新的无booksuppl id的booksuppl数据
      lv_max_booksuppl_id = REDUCE #( INIT lv_max = lv_max_booksuppl_id
                                    FOR ls_entity IN entities USING KEY entity
                                    WHERE ( travelid = <ls_entiies_group>-travelid AND
                                            bookingid = <ls_entiies_group>-bookingid )
                                      FOR ls_booksuppl IN ls_entity-%target
                                    NEXT lv_max = COND /dmo/supplement_id( WHEN lv_max < ls_booksuppl-bookingsupplementid
                                                                        THEN ls_booksuppl-bookingsupplementid
                                                                        ELSE lv_max ) ).

      "为空的booksuppl id赋值
      LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>) USING KEY entity
       WHERE travelid = <ls_entiies_group>-travelid
         AND bookingid = <ls_entiies_group>-bookingid.

        LOOP AT <ls_entity>-%target ASSIGNING FIELD-SYMBOL(<ls_booksuppl>).
          IF <ls_booksuppl>-bookingsupplementid IS INITIAL.

            lv_max_booksuppl_id += 10.

            APPEND CORRESPONDING #( <ls_booksuppl> ) TO mapped-zi_booksuppl_roc_m
             ASSIGNING FIELD-SYMBOL(<ls_booksuppl_mapped>).

            <ls_booksuppl_mapped>-bookingsupplementid = lv_max_booksuppl_id.

          ENDIF.
        ENDLOOP.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zi_travel_roc_m IN LOCAL MODE
        ENTITY zi_travel_roc_m BY \_booking
        FIELDS ( travelid bookingid bookingstatus )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_booking).

    result = VALUE #( FOR ls_booking IN lt_booking (
      %tky = ls_booking-%tky
      %features-%assoc-_booksuppl = COND #( WHEN ls_booking-bookingstatus = 'X'
                                               THEN if_abap_behv=>fc-o-disabled
                                               ELSE if_abap_behv=>fc-o-enabled )
     ) ).

  ENDMETHOD.

  METHOD calcutetotalprice.

    "排序并根据字段删除重复项
    DATA: lt_travel TYPE STANDARD TABLE OF zi_travel_roc_m WITH UNIQUE HASHED KEY key COMPONENTS travelid.
    lt_travel = CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING travelid = travelid ).

    MODIFY ENTITIES OF zi_travel_roc_m IN LOCAL MODE
      ENTITY zi_travel_roc_m
      EXECUTE recalctotprice
      FROM CORRESPONDING #( lt_travel ).

  ENDMETHOD.

ENDCLASS.
