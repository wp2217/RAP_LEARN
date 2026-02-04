CLASS lhc_zi_po_data_roc DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZI_PO_DATA_ROC RESULT result.

    METHODS processData FOR MODIFY
      IMPORTING keys FOR ACTION ZI_PO_DATA_ROC~processData RESULT result.

ENDCLASS.

CLASS lhc_zi_po_data_roc IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD processData.
  ENDMETHOD.

ENDCLASS.
