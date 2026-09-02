CLASS zcl_ve_roc_item_hide DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ve_roc_item_hide IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    LOOP AT it_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
      ASSIGN COMPONENT 'SETTLETYPE' OF STRUCTURE <fs_original_data> TO FIELD-SYMBOL(<fs_settle_type>).
      IF <fs_settle_type> IS ASSIGNED.

        READ TABLE ct_calculated_data INDEX sy-tabix ASSIGNING FIELD-SYMBOL(<fs_calculated_data>).
        IF sy-subrc = 0.

          ASSIGN COMPONENT 'HIDEPOFIELDS' OF STRUCTURE <fs_calculated_data> TO FIELD-SYMBOL(<fs_hide_po_fields>).
          IF <fs_hide_po_fields> IS ASSIGNED.
            <fs_hide_po_fields> = xsdbool( <fs_settle_type> = '02' ).  " 02时隐藏PO字段
          ENDIF.

          ASSIGN COMPONENT 'HIDENPOFIELDS' OF STRUCTURE <fs_calculated_data> TO FIELD-SYMBOL(<fs_hide_npo_fields>).
          IF <fs_hide_npo_fields> IS ASSIGNED.
            <fs_hide_npo_fields> = xsdbool( <fs_settle_type> = '01' ).  " 01时隐藏NPO字段
          ENDIF.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    LOOP AT it_requested_calc_elements INTO DATA(n).
      IF n = 'HIDEPOFIELDS' OR n = 'HIDENPOFIELDS'.
        APPEND 'SETTLETYPE' TO et_requested_orig_elements. " item 侧能拿到的抬头派生字段
        exit.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
