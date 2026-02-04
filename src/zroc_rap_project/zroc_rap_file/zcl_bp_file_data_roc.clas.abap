CLASS zcl_bp_file_data_roc DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zi_file_data_roc.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_po_excel,
             ebeln         TYPE string,
             ebelp         TYPE string,
             quantity      TYPE string,
             base_uom      TYPE string,
             error         TYPE string,
             error_message TYPE string,
             line_id       TYPE string,
             line_no       TYPE string,
           END OF ty_po_excel.
ENDCLASS.

CLASS zcl_bp_file_data_roc IMPLEMENTATION.
ENDCLASS.
