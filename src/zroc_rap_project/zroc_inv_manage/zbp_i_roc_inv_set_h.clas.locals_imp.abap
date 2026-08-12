CLASS lhc_zi_roc_inv_set_h DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_roc_inv_set_h RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_roc_inv_set_h RESULT result.
    METHODS setinvoicedata FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_roc_inv_set_h~setinvoicedata.
    METHODS earlynumbering_cba_invitem FOR NUMBERING
      IMPORTING entities FOR CREATE zi_roc_inv_set_h\_invitem.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zi_roc_inv_set_h.

ENDCLASS.

CLASS lhc_zi_roc_inv_set_h IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA(lv_qty) = lines( entities ).

    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '02'
            object            = 'ZROC_INV01'
            quantity          = CONV #( lv_qty )
          IMPORTING
            number            = DATA(lv_number)
            returncode        = DATA(lv_returncode)
            returned_quantity = DATA(lv_return_qty)
        ).
      CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges INTO DATA(lo_error).

        LOOP AT entities INTO DATA(ls_entities).
          APPEND VALUE #( %cid = ls_entities-%cid %key = ls_entities-%key )
            TO failed-zi_roc_inv_set_h.
          APPEND VALUE #( %cid = ls_entities-%cid %key = ls_entities-%key %msg = lo_error )
            TO reported-zi_roc_inv_set_h.
        ENDLOOP.
        EXIT.

    ENDTRY.

    ASSERT lv_return_qty = lv_qty.

    "当前号码
    lv_number = lv_number - lv_qty.

    DATA: lt_mapped TYPE TABLE FOR MAPPED EARLY zi_roc_inv_set_h,
          ls_mapped LIKE LINE OF lt_mapped.

    LOOP AT entities INTO ls_entities.
      ls_mapped-%cid = ls_entities-%cid.
      ls_mapped-%is_draft = ls_entities-%is_draft.

      ls_mapped-settleno = lv_number+8(12).
      lv_number += 1.

      APPEND ls_mapped TO mapped-zi_roc_inv_set_h.
    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_invitem.
  ENDMETHOD.

  METHOD setinvoicedata.

    READ ENTITIES OF zi_roc_inv_set_h IN LOCAL MODE
      ENTITY zi_roc_inv_set_h
      ALL FIELDS
      "FIELDS ( InvoiceNo )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_set_h).

    IF lt_set_h[] IS NOT INITIAL.
      SELECT *
        FROM zroc_invoice
         FOR ALL ENTRIES IN @lt_set_h
        WHERE invoice_no = @lt_set_h-invoiceno
         INTO TABLE @DATA(lt_invoice).

      SORT lt_invoice BY invoice_no.

      LOOP AT lt_set_h INTO DATA(ls_set_h).
        READ TABLE lt_invoice INTO DATA(ls_invoice)
          WITH KEY invoice_no = ls_set_h-invoiceno
          BINARY SEARCH.

        IF sy-subrc = 0.
          ls_set_h-grossamount = ls_invoice-gross_amount.
          ls_set_h-netamount = ls_invoice-net_amount.
          ls_set_h-taxamount = ls_invoice-tax_amount.
          ls_set_h-invoicedate = ls_invoice-invoice_date.
          MODIFY lt_set_h FROM ls_set_h.
        ENDIF.
      ENDLOOP.

      MODIFY ENTITIES OF zi_roc_inv_set_h IN LOCAL MODE
        ENTITY zi_roc_inv_set_h
        UPDATE FIELDS ( grossamount netamount taxamount invoicedate )
        WITH CORRESPONDING #( lt_set_h ).

    ENDIF.




  ENDMETHOD.

ENDCLASS.
