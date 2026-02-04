CLASS lhc_zi_booksuppl_roc_m DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calcutetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_booksuppl_roc_m~calcutetotalprice.

ENDCLASS.

CLASS lhc_zi_booksuppl_roc_m IMPLEMENTATION.

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

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
