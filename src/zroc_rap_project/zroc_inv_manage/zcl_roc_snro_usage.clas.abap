CLASS zcl_roc_snro_usage DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_roc_snro_usage IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*    " 1) 建对象
*    cl_numberrange_objects=>create(
*      EXPORTING
*        attributes = VALUE #(
*          object    = 'ZROC_DOCTYPE'
*          domlen    = 'ZROC_DOCTYPE_DOM'   " 建个 CHAR10 domain/data element
*          percentage = 5
*          buffer    = 'S'                  " S=主内存缓冲
*          noivbuffer = '1'
*          devclass  = 'ZROC_MY_PKG' )
*        obj_text = VALUE #(
*          langu = 'E' object = 'ZROC_DOCTYPE'
*          txt = 'ROC Document Type NR' txtshort = 'ROC Doc NR' )
*      IMPORTING errors = DATA(lt_err) returncode = DATA(lv_rc) ).
*    COMMIT WORK.

    " 2) 建区间 01（内部编号）
    TRY.
        cl_numberrange_intervals=>create(
          EXPORTING
            object = 'ZROC_INV01'
            interval = VALUE #( ( nrrangenr = '02'
                                  fromnumber = '100000000000'
                                  tonumber   = '199999999999'
                                  procind    = 'I' ) )   " I=内部
          IMPORTING error = data(lv_err) ).

      CATCH cx_number_ranges INTO data(lx_nr).

        out->write( lx_nr->get_longtext(  )  ).
        return.
        "handle exception
    ENDTRY.


    COMMIT WORK.

     out->write( 'Done '  ).

  ENDMETHOD.
ENDCLASS.
