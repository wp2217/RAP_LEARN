CLASS zcl_roc_domain_vh DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_roc_domain_vh IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    IF io_request->is_data_requested( ).

      DATA:
        lr_filter     TYPE REF TO if_rap_query_filter,
        lv_domainname TYPE sxco_ad_object_name.

      "如下top及order by必须要加，否则调用时会报错
      DATA(lv_top)     = io_request->get_paging( )->get_page_size( ).
      IF lv_top <= 0. lv_top = 1. ENDIF.

      DATA(lv_skip)    = io_request->get_paging( )->get_offset( ).
      DATA(lt_sort)    = io_request->get_sort_elements( ).

      DATA : lv_orderby TYPE string.
      LOOP AT lt_sort INTO DATA(ls_sort).
        IF ls_sort-descending = abap_true.
          lv_orderby = |{ lv_orderby } { ls_sort-element_name } DESCENDING |.
        ELSE.
          lv_orderby = |{ lv_orderby } { ls_sort-element_name } ASCENDING |.
        ENDIF.
      ENDLOOP.
      IF lv_orderby IS INITIAL.
        lv_orderby = 'Value'.
      ENDIF.

      lr_filter = io_request->get_filter( ).
      TRY.
          DATA(lt_ranges) = lr_filter->get_as_ranges( ).

        CATCH cx_rap_query_filter_no_range.
          RETURN.
      ENDTRY.

      READ TABLE lt_ranges INTO DATA(ls_ranges) WITH KEY name = 'DOMAINNAME'.
      IF sy-subrc = 0.
        READ TABLE ls_ranges-range INTO DATA(ls_domain) INDEX 1.
        IF sy-subrc = 0.

          lv_domainname = ls_domain-low.
          IF lv_domainname IS NOT INITIAL.
            SELECT
              val~domain_name AS DomainName,
              Val~value_low AS Value,
              Txt~text AS Text
            FROM ddcds_customer_domain_value( p_domain_name = @lv_domainname )   AS Val
            LEFT OUTER JOIN ddcds_customer_domain_value_t( p_domain_name = @lv_domainname ) AS Txt
              ON  Txt~domain_name    = Val~domain_name
              AND Txt~value_position = Val~value_position
              AND Txt~language       = @sy-langu
              ORDER BY (lv_orderby)
              INTO TABLE @DATA(lt_result)
              UP TO @lv_top ROWS OFFSET @lv_skip..

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    SORT lt_result BY DomainName value.

    DATA(lv_records) = lines( lt_result ).
    io_response->set_data( lt_result ).
    io_response->set_total_number_of_records( CONV int8( lv_records ) ).

  ENDMETHOD.
ENDCLASS.
