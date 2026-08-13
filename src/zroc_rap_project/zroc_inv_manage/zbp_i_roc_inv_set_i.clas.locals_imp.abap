CLASS lhc_zi_roc_inv_set_i DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZI_ROC_INV_SET_I RESULT result.

    METHODS getGRItem FOR MODIFY
      IMPORTING keys FOR ACTION ZI_ROC_INV_SET_I~getGRItem RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ZI_ROC_INV_SET_I RESULT result.

ENDCLASS.

CLASS lhc_zi_roc_inv_set_i IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD getGRItem.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

