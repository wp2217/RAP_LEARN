CLASS zcl_query_travl_alv_roc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_query_travl_alv_roc IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA: lt_customer_data TYPE STANDARD TABLE OF ztravel_roc_m.

    IF io_request->is_data_requested( ).

      " Get the requested fields
      DATA(lt_requested_fields) = io_request->get_requested_elements( ).

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
        lv_orderby = 'travel_id'.
      ENDIF.

      DATA(lv_conditions) =  io_request->get_filter( )->get_as_sql_string( ).

*    Total number of records
      SELECT COUNT( * ) FROM ztravel_roc_m  INTO @DATA(lv_records).

      " Select: no alias for the main view (to keep filter simple), aliases only for joined texts
      IF lv_conditions IS INITIAL.
        SELECT * FROM ztravel_roc_m
          ORDER BY (lv_orderby)
          INTO CORRESPONDING FIELDS OF TABLE @lt_customer_data
          UP TO @lv_top ROWS OFFSET @lv_skip.
      ELSE.
        SELECT * FROM ztravel_roc_m
          WHERE (lv_conditions)               " only when not initial
          ORDER BY (lv_orderby)
          INTO CORRESPONDING FIELDS OF TABLE @lt_customer_data
          UP TO @lv_top ROWS OFFSET @lv_skip.
      ENDIF.

      io_response->set_total_number_of_records( lv_records ).
      io_response->set_data( lt_customer_data ).

    ENDIF.


  ENDMETHOD.
ENDCLASS.
