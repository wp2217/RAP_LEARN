CLASS lhc_ZI_ROC_CODE DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_roc_code RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_roc_code RESULT result.

    METHODS Activate FOR MODIFY
      IMPORTING keys FOR ACTION zi_roc_code~Activate.

    METHODS Discard FOR MODIFY
      IMPORTING keys FOR ACTION zi_roc_code~Discard.

    METHODS Edit FOR MODIFY
      IMPORTING keys FOR ACTION zi_roc_code~Edit.

    METHODS Resume FOR MODIFY
      IMPORTING keys FOR ACTION zi_roc_code~Resume.

ENDCLASS.

CLASS lhc_ZI_ROC_CODE IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD Activate.
  ENDMETHOD.

  METHOD Discard.
  ENDMETHOD.

  METHOD Edit.
  ENDMETHOD.

  METHOD Resume.
  ENDMETHOD.

ENDCLASS.
