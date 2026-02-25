CLASS zcl_bp_tools_rap_roc DEFINITION
  PUBLIC
  INHERITING FROM cl_abap_behv
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS get_cause_from_message
      IMPORTING
        msgid             TYPE symsgid
        msgno             TYPE symsgno
        is_depended       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(fail_cause) TYPE if_abap_behv=>t_fail_cause.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BP_TOOLS_RAP_ROC IMPLEMENTATION.


  METHOD get_cause_from_message.
    fail_cause = if_abap_behv=>cause-unspecific.

    IF msgid = '/DMO/CM_FLIGHT_LEGAC'.
      CASE msgno.
        WHEN '002'. "Customer &1 unknown
          fail_cause = if_abap_behv=>cause-not_found.
        WHEN '009'  "Travel Key initial
          OR '016'  "Travel &1 does not exist
          OR '017'.  "Travel &1: Booking &2 does not exist

          IF is_depended = abap_true.
            fail_cause = if_abap_behv=>cause-dependency.
          ELSE.
            fail_cause = if_abap_behv=>cause-not_found.
          ENDIF.

        WHEN '032'. "Travel &1 is locked by &2
          fail_cause = if_abap_behv=>cause-locked.

        WHEN '046'. "You are not authorized to perform this activity
          fail_cause = if_abap_behv=>cause-unauthorized.
      ENDCASE.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
