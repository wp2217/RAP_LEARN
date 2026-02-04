CLASS lhc_zi_travel_roc_u DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR travel RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR travel RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE travel.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE travel.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE travel.

    METHODS read FOR READ
      IMPORTING keys FOR READ travel RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK travel.

    METHODS rba_booking FOR READ
      IMPORTING keys_rba FOR READ travel\_booking FULL result_requested RESULT result LINK association_links.

    METHODS cba_booking FOR MODIFY
      IMPORTING entities_cba FOR CREATE travel\_booking.

    TYPES:
      tt_travel_failed   TYPE TABLE FOR FAILED EARLY zi_travel_roc_u\\travel,
      tt_travel_reported TYPE TABLE FOR REPORTED EARLY zi_travel_roc_u\\travel.

    METHODS zmap_message
      IMPORTING
        iv_cid        TYPE abp_behv_cid   OPTIONAL
        iv_travel_id  TYPE /dmo/travel_id OPTIONAL
        it_message    TYPE /dmo/t_message
      EXPORTING
        ev_failed_flg TYPE abap_boolean
      CHANGING
        ct_failed     TYPE tt_travel_failed
        ct_reported   TYPE tt_travel_reported.

    TYPES:
      tt_booking_failed   TYPE TABLE FOR FAILED EARLY zi_travel_roc_u\\booking,
      tt_booking_reported TYPE TABLE FOR REPORTED EARLY zi_travel_roc_u\\booking.

    METHODS zmap_message_ba_booking
      IMPORTING
        iv_cid          TYPE abp_behv_cid  OPTIONAL
        iv_travel_id    TYPE /dmo/travel_id
        iv_booking_id   TYPE /dmo/booking_id
        iv_is_dependent TYPE abap_boolean DEFAULT abap_false
        it_message      TYPE /dmo/t_message
      EXPORTING
        ev_failed_flg   TYPE abap_boolean
      CHANGING
        ct_failed       TYPE tt_booking_failed
        ct_reported     TYPE tt_booking_reported.

ENDCLASS.

CLASS lhc_zi_travel_roc_u IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zi_travel_roc_u IN LOCAL MODE
      ENTITY travel
      FIELDS ( travelid overallstatus )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel (
      %tky = ls_travel-%tky
      %features-%assoc-_booking = COND #( WHEN ls_travel-overallstatus = 'X'
                                               THEN if_abap_behv=>fc-o-disabled
                                               ELSE if_abap_behv=>fc-o-enabled )
     ) ).
  ENDMETHOD.


  METHOD create.
    DATA:
      ls_travel     TYPE /dmo/travel,
      ls_travel_out TYPE /dmo/travel,
      lv_failed_flg TYPE abap_boolean,
      lt_message    TYPE /dmo/t_message.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entity>).
      "根据behavior定义的mapping，自动字段赋值
      ls_travel = CORRESPONDING #( <fs_entity> MAPPING FROM ENTITY USING CONTROL ).

      CLEAR lt_message[].
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_CREATE'
        EXPORTING
          is_travel         = CORRESPONDING /dmo/s_travel_in( ls_travel )
*         it_booking        =
*         it_booking_supplement =
          iv_numbering_mode = /dmo/if_flight_legacy=>numbering_mode-late
        IMPORTING
          es_travel         = ls_travel_out
*         et_booking        =
*         et_booking_supplement =
          et_messages       = lt_message.

      CLEAR lv_failed_flg.
      zmap_message(
        EXPORTING
          iv_cid        = <fs_entity>-%cid
          it_message    = lt_message
        IMPORTING
          ev_failed_flg = lv_failed_flg
        CHANGING
          ct_failed     = failed-travel
          ct_reported   = reported-travel ).

      IF lv_failed_flg = abap_false.
        APPEND VALUE #( %cid     = <fs_entity>-%cid
                        travelid = ls_travel_out-travel_id ) TO mapped-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.

    DATA:
      ls_travel     TYPE /dmo/travel,
      ls_travelx    TYPE /dmo/s_travel_intx,
      ls_travel_inx TYPE /dmo/s_travel_inx,
      ls_travel_out TYPE /dmo/travel,
      lv_failed_flg TYPE abap_boolean,
      lt_message    TYPE /dmo/t_message.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entity>).

      "根据behavior定义的mapping，自动字段赋值
      ls_travel = CORRESPONDING #( <fs_entity> MAPPING FROM ENTITY USING CONTROL ).
      ls_travelx = CORRESPONDING #( <fs_entity> MAPPING FROM ENTITY USING CONTROL ).

      ls_travel_inx = CORRESPONDING #( ls_travelx ).
      ls_travel_inx-travel_id = <fs_entity>-travelid.
      ls_travel-travel_id = <fs_entity>-travelid.

      CLEAR lt_message[].
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = CORRESPONDING /dmo/s_travel_in( ls_travel )
          is_travelx  = ls_travel_inx
*         it_booking  =
*         it_bookingx =
*         it_booking_supplement  =
*         it_booking_supplementx =
        IMPORTING
          es_travel   = ls_travel_out
*         et_booking  =
*         et_booking_supplement =
          et_messages = lt_message.

      CLEAR lv_failed_flg.
      zmap_message(
        EXPORTING
          iv_travel_id  = <fs_entity>-travelid
          it_message    = lt_message
        IMPORTING
          ev_failed_flg = lv_failed_flg
        CHANGING
          ct_failed     = failed-travel
          ct_reported   = reported-travel ).

      IF lv_failed_flg = abap_false.
        APPEND VALUE #( travelid = ls_travel_out-travel_id ) TO mapped-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD delete.

    DATA:
      lv_failed_flg TYPE abap_boolean,
      lt_message    TYPE /dmo/t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_keys>).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_DELETE'
        EXPORTING
          iv_travel_id = <fs_keys>-travelid
        IMPORTING
          et_messages  = lt_message.

      CLEAR lv_failed_flg.
      zmap_message(
        EXPORTING
          iv_travel_id  = <fs_keys>-travelid
          it_message    = lt_message
        IMPORTING
          ev_failed_flg = lv_failed_flg
        CHANGING
          ct_failed     = failed-travel
          ct_reported   = reported-travel ).
    ENDLOOP.

  ENDMETHOD.

  METHOD read.
    DATA:
      ls_travel_out TYPE /dmo/travel,
      lv_failed_flg TYPE abap_boolean,
      lt_message    TYPE /dmo/t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_keys>).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <fs_keys>-travelid
*         iv_include_buffer     = abap_true
        IMPORTING
          es_travel    = ls_travel_out
*         et_booking   =
*         et_booking_supplement =
          et_messages  = lt_message.

      CLEAR lv_failed_flg.
      zmap_message(
        EXPORTING
          iv_travel_id  = <fs_keys>-travelid
          it_message    = lt_message
        IMPORTING
          ev_failed_flg = lv_failed_flg
        CHANGING
          ct_failed     = failed-travel
          ct_reported   = reported-travel ).

      IF lv_failed_flg = abap_false.
        APPEND CORRESPONDING #( ls_travel_out MAPPING TO ENTITY ) TO  result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.

    TRY.
        DATA(lr_lock) = cl_abap_lock_object_factory=>get_instance( '/DMO/ETRAVEL' ).

      CATCH cx_abap_lock_failure INTO DATA(lr_lock_fail).
        "handle exception
        RAISE SHORTDUMP lr_lock_fail.
    ENDTRY.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_keys>).
      TRY.
          lr_lock->enqueue(
            it_parameter = VALUE #( ( name = 'TRAVEL_ID' value = REF #( <fs_keys>-travelid ) ) )
          ).
        CATCH cx_abap_foreign_lock INTO DATA(lr_fo_lock).
          zmap_message(
            EXPORTING
              iv_travel_id = <fs_keys>-travelid
              it_message   = VALUE #( ( msgid = '/DMO/CM_FLIGHT_LEGAC'
                                        msgty = 'E'
                                        msgno = '032'
                                        msgv1 = <fs_keys>-travelid
                                        msgv2 = lr_fo_lock->user_name
                                      ) )
            CHANGING
              ct_failed    = failed-travel
              ct_reported  = reported-travel
          ).

          EXIT.

        CATCH cx_abap_lock_failure INTO lr_lock_fail.
          "handle exception
          RAISE SHORTDUMP lr_lock_fail.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_booking.

  ENDMETHOD.

  METHOD cba_booking.

    "错误消息不能报出来，待研究

    DATA:
      ls_travel_out  TYPE /dmo/travel,
      lv_failed_flg  TYPE abap_boolean,
      lt_booking_old TYPE /dmo/t_booking,
      lt_message     TYPE /dmo/t_message.

    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<fs_entities_cba>).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <fs_entities_cba>-travelid
*         iv_include_buffer     = abap_true
        IMPORTING
          es_travel    = ls_travel_out
          et_booking   = lt_booking_old
*         et_booking_supplement =
          et_messages  = lt_message.

      CLEAR lv_failed_flg.
      zmap_message(
        EXPORTING
          iv_travel_id  = <fs_entities_cba>-travelid
          it_message    = lt_message
        IMPORTING
          ev_failed_flg = lv_failed_flg
        CHANGING
          ct_failed     = failed-travel
          ct_reported   = reported-travel ).

      IF lv_failed_flg = abap_true.
        LOOP AT <fs_entities_cba>-%target ASSIGNING FIELD-SYMBOL(<fs_booking_create>).
          zmap_message_ba_booking(
            EXPORTING
              iv_cid          = <fs_booking_create>-%cid
              iv_travel_id    = <fs_booking_create>-travelid
              iv_booking_id   = <fs_booking_create>-bookingid
              iv_is_dependent = abap_true
              it_message      = lt_message
            IMPORTING
              ev_failed_flg   = lv_failed_flg
            CHANGING
              ct_failed       = failed-booking
              ct_reported     = reported-booking
          ).

        ENDLOOP.

      ELSE."No Errors
        DATA:
          ls_booking     TYPE /dmo/booking.

        "取最大的booking id ，加Optional防止记录不存在而报错
        DATA(lv_last_booking_id) = VALUE #( lt_booking_old[ lines( lt_booking_old[] ) ]-booking_id OPTIONAL ).

        LOOP AT <fs_entities_cba>-%target ASSIGNING <fs_booking_create>.

          "根据behavior定义的mapping，自动字段赋值
          ls_booking = CORRESPONDING #( <fs_booking_create> MAPPING FROM ENTITY USING CONTROL ).

          lv_last_booking_id = lv_last_booking_id + 1.
          ls_booking-booking_id = lv_last_booking_id.

          CLEAR lt_message[].
          CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
            EXPORTING
              is_travel   = VALUE /dmo/s_travel_in(  travel_id = <fs_entities_cba>-travelid )
              is_travelx  = VALUE /dmo/s_travel_inx( travel_id = <fs_entities_cba>-travelid )
              it_booking  = VALUE /dmo/t_booking_in(  ( CORRESPONDING #( ls_booking ) ) )
              it_bookingx = VALUE /dmo/t_booking_inx( ( booking_id  = ls_booking-booking_id
                                                        action_code = /dmo/if_flight_legacy=>action_code-create ) )
            IMPORTING
              es_travel   = ls_travel_out
              et_messages = lt_message.

          CLEAR lv_failed_flg.
          zmap_message_ba_booking(
            EXPORTING
              iv_cid          = <fs_booking_create>-%cid
              iv_travel_id    = <fs_booking_create>-travelid
              iv_booking_id   = ls_booking-booking_id
              iv_is_dependent = abap_true
              it_message      = lt_message
            IMPORTING
              ev_failed_flg   = lv_failed_flg
            CHANGING
              ct_failed       = failed-booking
              ct_reported     = reported-booking
          ).

          "No Errors
          IF lv_failed_flg IS INITIAL.
            APPEND VALUE #( %cid      = <fs_booking_create>-%cid
                            travelid  = <fs_entities_cba>-travelid
                            bookingid = ls_booking-booking_id ) TO mapped-booking.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD zmap_message.
    ev_failed_flg = abap_false.
    LOOP AT it_message INTO DATA(ls_message) WHERE msgty = 'E' OR msgty = 'A'.

      ev_failed_flg = abap_true.

      APPEND VALUE #( %cid        = iv_cid
                      travelid    = iv_travel_id
                      %fail-cause = zcl_bp_tools_rap_roc=>get_cause_from_message(
                      msgid = ls_message-msgid
                      msgno = ls_message-msgno
*                                      is_depended = abap_false
                      )
                    ) TO ct_failed.

      APPEND VALUE #( %cid     = iv_cid
                      travelid = iv_travel_id
                      %msg     = new_message(
                      id       = ls_message-msgid
                      number   = ls_message-msgno
                      severity = if_abap_behv_message=>severity-error
                      v1       = ls_message-msgv1
                      v2       = ls_message-msgv2
                      v3       = ls_message-msgv3
                      v4       = ls_message-msgv4
                      )
      ) TO ct_reported.
    ENDLOOP.
  ENDMETHOD.

  METHOD zmap_message_ba_booking.
    "ASSERT iv_CID IS NOT INITIAL.

    ev_failed_flg = abap_false.
    LOOP AT it_message INTO DATA(ls_message) WHERE msgty = 'E' OR msgty = 'A'.

      ev_failed_flg = abap_true.

      APPEND VALUE #( %cid        = iv_cid
                      travelid    = iv_travel_id
                      bookingid   = iv_booking_id
                      %fail-cause = zcl_bp_tools_rap_roc=>get_cause_from_message(
                      msgid       = ls_message-msgid
                      msgno       = ls_message-msgno
                      is_depended = iv_is_dependent
                      )
                    ) TO ct_failed.

      APPEND VALUE #( %cid      = iv_cid
                      travelid  = iv_travel_id
                      bookingid = iv_booking_id
                      %msg      = new_message(
                      id       = ls_message-msgid
                      number   = ls_message-msgno
                      severity = if_abap_behv_message=>severity-error
                      v1       = ls_message-msgv1
                      v2       = ls_message-msgv2
                      v3       = ls_message-msgv3
                      v4       = ls_message-msgv4
                      )
      ) TO ct_reported.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_travel_roc_u DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS adjust_numbers REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_travel_roc_u IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD adjust_numbers.
    DATA:
      lt_travel_mapping       TYPE /dmo/if_flight_legacy=>tt_ln_travel_mapping,
      lt_booking_mapping      TYPE /dmo/if_flight_legacy=>tt_ln_booking_mapping,
      lt_bookingsuppl_mapping TYPE /dmo/if_flight_legacy=>tt_ln_bookingsuppl_mapping.

    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_ADJ_NUMBERS'
      IMPORTING
        et_travel_mapping       = lt_travel_mapping
        et_booking_mapping      = lt_booking_mapping
        et_bookingsuppl_mapping = lt_bookingsuppl_mapping.


    mapped-travel = VALUE #( FOR ls_travel_mapping IN lt_travel_mapping ( %tmp-travelid = ls_travel_mapping-preliminary-travel_id
                                                                          travelid      = ls_travel_mapping-final-travel_id ) ).

    mapped-booking = VALUE #( FOR ls_booking_mapping IN lt_booking_mapping ( %tmp-travelid  = ls_booking_mapping-preliminary-travel_id
                                                                             %tmp-bookingid = ls_booking_mapping-preliminary-booking_id
                                                                             travelid       = ls_booking_mapping-final-travel_id
                                                                             bookingid      = ls_booking_mapping-final-booking_id ) ).
  ENDMETHOD.

  METHOD save.

    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_SAVE'.

  ENDMETHOD.

  METHOD cleanup.

    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_INITIALIZE'.

  ENDMETHOD.

  METHOD cleanup_finalize.
    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_INITIALIZE'.
  ENDMETHOD.

ENDCLASS.
