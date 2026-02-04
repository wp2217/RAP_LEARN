CLASS lhc_zi_booking_roc_u DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE booking.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE booking.

    METHODS read FOR READ
      IMPORTING keys FOR READ booking RESULT result.

    METHODS rba_travel FOR READ
      IMPORTING keys_rba FOR READ booking\_travel FULL result_requested RESULT result LINK association_links.

    TYPES:
      tt_booking_failed   TYPE TABLE FOR FAILED EARLY zi_travel_roc_u\\booking,
      tt_booking_reported TYPE TABLE FOR REPORTED EARLY zi_travel_roc_u\\booking.

    METHODS zmap_message
      IMPORTING
        iv_cid        TYPE abp_behv_cid   OPTIONAL
        iv_travel_id  TYPE /dmo/travel_id OPTIONAL
        iv_booking_id TYPE /dmo/booking_id OPTIONAL
        it_message    TYPE /dmo/t_message
      EXPORTING
        ev_failed_flg TYPE abap_boolean
      CHANGING
        ct_failed     TYPE tt_booking_failed
        ct_reported   TYPE tt_booking_reported.



ENDCLASS.

CLASS lhc_zi_booking_roc_u IMPLEMENTATION.

  METHOD update.
    DATA messages TYPE /dmo/t_message.
    DATA booking  TYPE /dmo/booking.
    DATA bookingx TYPE /dmo/s_booking_inx.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking>).

      booking = CORRESPONDING #( <booking> MAPPING FROM ENTITY ).

      bookingx-booking_id  = <booking>-bookingid.
      bookingx-_intx       = CORRESPONDING #( <booking> MAPPING FROM ENTITY ).
      bookingx-action_code = /dmo/if_flight_legacy=>action_code-update.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = VALUE /dmo/s_travel_in(  travel_id = <booking>-travelid )
          is_travelx  = VALUE /dmo/s_travel_inx( travel_id = <booking>-travelid )
          it_booking  = VALUE /dmo/t_booking_in( ( CORRESPONDING #( booking ) ) )
          it_bookingx = VALUE /dmo/t_booking_inx( ( bookingx ) )
        IMPORTING
          et_messages = messages.

      zmap_message(
        EXPORTING
          iv_cid        = <booking>-%cid_ref
          iv_travel_id  = <booking>-travelid
          iv_booking_id = <booking>-bookingid
          it_message    = messages
        CHANGING
          ct_failed     = failed-booking
          ct_reported   = reported-booking ).

    ENDLOOP.
  ENDMETHOD.

  METHOD delete.

    DATA messages TYPE /dmo/t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<booking>).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = VALUE /dmo/s_travel_in(  travel_id = <booking>-travelid )
          is_travelx  = VALUE /dmo/s_travel_inx( travel_id = <booking>-travelid )
          it_booking  = VALUE /dmo/t_booking_in(  ( booking_id  = <booking>-bookingid ) )
          it_bookingx = VALUE /dmo/t_booking_inx( ( booking_id  = <booking>-bookingid
                                                    action_code = /dmo/if_flight_legacy=>action_code-delete ) )
        IMPORTING
          et_messages = messages.

      zmap_message(
        EXPORTING
          iv_cid        = <booking>-%cid_ref
          iv_travel_id  = <booking>-travelid
          iv_booking_id = <booking>-bookingid
          it_message    = messages
        CHANGING
          ct_failed     = failed-booking
          ct_reported   = reported-booking ).
    ENDLOOP.

  ENDMETHOD.

  METHOD read.

    DATA: travel_out   TYPE /dmo/travel,
          bookings_out TYPE /dmo/t_booking,
          messages     TYPE /dmo/t_message.

    "Only one function call for each requested travelid
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<booking_by_travel>)
                               GROUP BY <booking_by_travel>-travelid .

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <booking_by_travel>-travelid
        IMPORTING
          es_travel    = travel_out
          et_booking   = bookings_out
          et_messages  = messages.

      zmap_message(
        EXPORTING
          " iv_cid        = <booking>-%cid_ref
          iv_travel_id  = <booking_by_travel>-travelid
          iv_booking_id = <booking_by_travel>-bookingid
          it_message    = messages
        IMPORTING
          ev_failed_flg = DATA(failed_added)
        CHANGING
          ct_failed     = failed-booking
          ct_reported   = reported-booking ).


      IF failed_added = abap_false.
        "For each travelID find the requested bookings
        LOOP AT GROUP <booking_by_travel> ASSIGNING FIELD-SYMBOL(<booking>)
                                          GROUP BY <booking>-%tky.

          READ TABLE bookings_out INTO DATA(booking_out) WITH KEY travel_id  = <booking>-%key-travelid
                                                                  booking_id = <booking>-%key-bookingid .
          "if read was successful
          IF sy-subrc = 0.
            INSERT CORRESPONDING #( booking_out MAPPING TO ENTITY ) INTO TABLE result.
          ELSE.
            "BookingID not found
            INSERT VALUE #( travelid    = <booking>-travelid
                            bookingid   = <booking>-bookingid
                            %fail-cause = if_abap_behv=>cause-not_found )
              INTO TABLE failed-booking.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDLOOP.

*    DATA:
*      ls_travel_out TYPE /dmo/travel,
*      lt_booking    TYPE /dmo/t_booking,
*      lv_failed_flg TYPE abap_boolean,
*      lt_message    TYPE /dmo/t_message.
*
*    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_keys>).
*      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
*        EXPORTING
*          iv_travel_id = <fs_keys>-TravelId
**         iv_include_buffer     = abap_true
*        IMPORTING
*          es_travel    = ls_travel_out
*          et_booking   = lt_booking
**         et_booking_supplement =
*          et_messages  = lt_message.
*
*      CLEAR lv_failed_flg.
*      zmap_message(
*       EXPORTING
*        iv_trAVEL_ID = <fs_keys>-TravelId
*        iv_bOOKING_ID = <fs_KEYS>-BookingId
*        it_message = lt_message
*       IMPORTING
*        ev_failed_flg = lv_failed_flg
*       CHANGING
*        ct_failed = failed-bOOKING
*        ct_reported = reported-bOOKING  ).
*
*      IF lv_failed_flg = abap_faLse.
*        DELETE lt_booking WHERE booking_id <> <fs_KEYS>-BookingId.
*
*        LOOP AT lt_bOOKING ASSIGNING FIELD-SYMBOL(<FS_booking>).
*          APPEND CORRESPONDING #( <FS_booking> MAPPING TO ENTITY ) TO  result.
*        ENDLOOP.
*      ENDIF.
*    ENDLOOP.

  ENDMETHOD.

  METHOD rba_travel.
    DATA:
      ls_travel_out TYPE /dmo/travel,
      lt_booking    TYPE /dmo/t_booking,
      lv_failed_flg TYPE abap_boolean,
      lt_message    TYPE /dmo/t_message.

    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<fs_keys_rba>)
      GROUP BY <fs_keys_rba>-travelid.  "TravelID 有重复的只循环一次

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <fs_keys_rba>-travelid
*         iv_include_buffer     = abap_true
        IMPORTING
          es_travel    = ls_travel_out
          et_booking   = lt_booking
*         et_booking_supplement =
          et_messages  = lt_message.

      CLEAR lv_failed_flg.
      zmap_message(
        EXPORTING
          iv_travel_id  = <fs_keys_rba>-travelid
          iv_booking_id = <fs_keys_rba>-bookingid
          it_message    = lt_message
        IMPORTING
          ev_failed_flg = lv_failed_flg
        CHANGING
          ct_failed     = failed-booking
          ct_reported   = reported-booking ).

      IF lv_failed_flg = abap_false.
        LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<fs_travel>) USING KEY entity WHERE travelid = <fs_keys_rba>-travelid.

          APPEND VALUE #( source-%tky     = <fs_travel>-%tky
                          target-travelid = <fs_travel>-travelid ) TO association_links.

          IF result_requested IS NOT INITIAL.
            APPEND CORRESPONDING #( ls_travel_out MAPPING TO ENTITY ) TO  result.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDLOOP.

    SORT association_links BY source ASCENDING.
    DELETE ADJACENT DUPLICATES FROM association_links COMPARING ALL FIELDS.

    SORT result BY %tky ASCENDING.
    DELETE ADJACENT DUPLICATES FROM result COMPARING ALL FIELDS.

  ENDMETHOD.

  METHOD zmap_message.
    ev_failed_flg = abap_false.
    LOOP AT it_message INTO DATA(ls_message) WHERE msgty = 'E' OR msgty = 'A'.

      ev_failed_flg = abap_true.

      APPEND VALUE #( %cid        = iv_cid
                      travelid    = iv_travel_id
                      bookingid   = iv_booking_id
                      %fail-cause = zcl_bp_tools_rap_roc=>get_cause_from_message(
                      msgid = ls_message-msgid
                      msgno = ls_message-msgno
*                                      is_depended = abap_false
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
