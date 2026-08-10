CLASS lhc_ZI_ROC_INV_SET_H DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_roc_inv_set_h RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_roc_inv_set_h RESULT result.
    METHODS earlynumbering_cba_invitem FOR NUMBERING
      IMPORTING entities FOR CREATE zi_roc_inv_set_h\_invitem.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zi_roc_inv_set_h.

ENDCLASS.

CLASS lhc_ZI_ROC_INV_SET_H IMPLEMENTATION.

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

      ls_mapped-SettleNo = lv_number+8(12).
      lv_number += 1.

      APPEND ls_mapped TO mapped-zi_roc_inv_set_h.
    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_Invitem.
  ENDMETHOD.

ENDCLASS.
