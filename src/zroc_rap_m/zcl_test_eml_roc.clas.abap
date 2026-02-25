CLASS zcl_test_eml_roc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS:
      _data_init,
      _eml_read   IMPORTING out TYPE REF TO if_oo_adt_classrun_out,
      _eml_modify   IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
ENDCLASS.



CLASS ZCL_TEST_EML_ROC IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    "me->_data_init(  ).
    me->_eml_read( out ).
    " me->_eml_modify( out ).


  ENDMETHOD.


  METHOD _data_init.
    "Data initial
    DATA:
      ls_ztravel TYPE ztravel_roc_m,
      lt_ztravel TYPE STANDARD TABLE OF ztravel_roc_m.

    SELECT *
    FROM /dmo/travel
    INTO TABLE @DATA(lt_travel).

    LOOP AT lt_travel INTO DATA(ls_travel).
      MOVE-CORRESPONDING ls_travel TO ls_ztravel.
      APPEND ls_ztravel TO lt_ztravel.
    ENDLOOP.

    MODIFY ztravel_roc_m FROM TABLE @lt_ztravel.

    COMMIT WORK AND WAIT.

    DATA:
      ls_zbooking TYPE zbooking_roc_m,
      lt_zbooking TYPE STANDARD TABLE OF zbooking_roc_m.

    SELECT *
    FROM /dmo/booking
    INTO TABLE @DATA(lt_booking).

    LOOP AT lt_booking INTO DATA(ls_booking).
      MOVE-CORRESPONDING ls_booking TO ls_zbooking.
      APPEND ls_zbooking TO lt_zbooking.
    ENDLOOP.

    MODIFY zbooking_roc_m FROM TABLE @lt_zbooking.

    COMMIT WORK AND WAIT.

    DATA:
      ls_zbooksuppl TYPE zbooksuppl_roc_m,
      lt_zbooksuppl TYPE STANDARD TABLE OF zbooksuppl_roc_m.

    SELECT *
    FROM /dmo/booksuppl_m
    INTO TABLE @DATA(lt_booksuppl).

    LOOP AT lt_booksuppl INTO DATA(ls_booksuppl).
      MOVE-CORRESPONDING ls_booksuppl TO ls_zbooksuppl.
      APPEND ls_zbooksuppl TO lt_zbooksuppl.
    ENDLOOP.

    MODIFY zbooksuppl_roc_m FROM TABLE @lt_zbooksuppl.

    COMMIT WORK AND WAIT.
  ENDMETHOD.


  METHOD _eml_modify.
    "1.Short form create
*    MODIFY ENTITY zi_travel_roc_m
*      CREATE FROM VALUE #( ( %cid = 'CID1' %data-BeginDate = '20250602' %data-EndDate = '20250618'
*              %control-BeginDate = if_abap_behv=>mk-on
*              %control-EndDate = if_abap_behv=>mk-on
*             ) )
*
*     CREATE BY \_Booking
*       FROM VALUE #( ( %cid_ref =  'CID1' %target = VALUE #( ( %cid = 'CID11' %data-BookingDate = '20250602'
*                   %control-BookingDate = if_abap_behv=>mk-on ) )
*                 ) )
*
*              FAILED   FINAL(fail_mod)
*              REPORTED FINAL(rep_mod)
*              MAPPED FINAL(map_mod).
*
*    IF fail_mod IS NOT INITIAL.
*      out->write( fail_mod ).
*    ELSE.
*      COMMIT ENTITIES.
*    ENDIF.

    "Create with AUTO FILL CID  不能有association
*    MODIFY ENTITY zi_travel_roc_m
*      CREATE AUTO FILL CID with VALUE #( (  %data-BeginDate = '20250602' %data-EndDate = '20250618'
*              %control-BeginDate = if_abap_behv=>mk-on
*              %control-EndDate = if_abap_behv=>mk-on
*             ) )
*              FAILED   FINAL(fail_mod)
*              REPORTED FINAL(rep_mod)
*              MAPPED FINAL(map_mod).
*
*    IF fail_mod IS NOT INITIAL.
*      out->write( fail_mod ).
*    ELSE.
*      COMMIT ENTITIES.
*    ENDIF.

    "2.Short form update
                                                            "00004434
    MODIFY ENTITY zi_travel_roc_m
      UPDATE FIELDS ( begindate  )
      WITH VALUE #( ( %key-travelid = '00004443' begindate = '20250610' ) )
              FAILED   FINAL(fail_mod)
              REPORTED FINAL(rep_mod)
              MAPPED FINAL(map_mod).

    IF fail_mod IS NOT INITIAL.
      out->write( fail_mod ).
    ELSE.
      out->write( 'Ok' ).
      COMMIT ENTITIES.
    ENDIF.

    "3.Short form delete
*    MODIFY ENTITY zi_booking_roc_m"zi_travel_roc_m
*      DELETE FROM VALUE #( ( %key-TravelId = '00004441'
*                             %key-BookingId = '0010' ) )
*              FAILED   FINAL(fail_mod)
*              REPORTED FINAL(rep_mod)
*              MAPPED FINAL(map_mod).
*
*    IF fail_mod IS NOT INITIAL.
*      out->write( fail_mod ).
*    ELSE.
*      COMMIT ENTITIES.
*    ENDIF.

  ENDMETHOD.


  METHOD _eml_read.
    "1.Short form read 一次只能读取一种类别的entity
    READ ENTITY zi_travel_roc_m
        BY \_booking                             "读取子节点数据
*      FIELDS ( AgencyId BeginDate EndDate )
      ALL FIELDS
      WITH VALUE #( ( %key-travelid = '00004193' )
                    ( %key-travelid = '00004194' )
                  )       "读取条件
      RESULT DATA(lt_result_short)
      FAILED DATA(lt_failed_short).


    "另一种写法
*
*                      %control = value #(        "结果字段
*                      AgencyId = if_abap_behv=>mk-on
*                      CustomerId = if_abap_behv=>mk-on
*                      Description = if_abap_behv=>mk-on
*                      )
*


*
    "2.Long form read entity
    READ ENTITIES OF zi_travel_roc_m

       ENTITY zi_travel_roc_m
       ALL FIELDS
       WITH VALUE #( ( %key-travelid = '00000002' )
                     ( %key-travelid = '00000003' )
                   )      "读取条件
      RESULT DATA(lt_result_long_travel)

      ENTITY zi_booking_roc_m
       ALL FIELDS
       WITH VALUE #( ( %key-travelid = '00000002' %key-bookingid = '0001' )
                     ( %key-travelid = '00000003' %key-bookingid = '0001' )
                   )
        RESULT DATA(lt_result_long_booking)

       FAILED DATA(lt_failed_long).


    "3.Dynamic form
*    DATA:
*      lt_travel_condition TYPE TABLE FOR READ IMPORT zi_travel_roc_m,
*      lt_travel_result    TYPE TABLE FOR READ RESULT zi_travel_roc_m,
*      lt_op_tab           TYPE abp_behv_retrievals_tab.
*
*    lt_travel_condition = VALUE #( ( %key-Travelid = '00000002'
*                                     %control = VALUE #(
*                                     AgencyId = if_abap_behv=>mk-on
*                                     CustomerId = if_abap_behv=>mk-on
*                                     Description = if_abap_behv=>mk-on
*                                     BeginDate = if_abap_behv=>mk-on
*                                     ) ) ).
*
*    lt_op_tab = VALUE #( ( op = 'R' "if_abap_behv=>op-r
*                            entity_name = 'ZI_TRAVEL_ROC_M'  "必须要大写
*                            instances = REF #( lt_travel_condition )
*                            results = REF #( lt_travel_result )
*                            )  ).
*
*    READ ENTITIES
*      OPERATIONS lt_op_tab
*      FAILED DATA(lt_failed_dynamic).
*
*    IF lt_failed_dynamic IS NOT INITIAL.
*      out->write( 'Dynamic form read failed--------->' ).
*      out->write( lt_failed_dynamic ).
*
*    ELSE.
*      out->write( lt_travel_result ).
*    ENDIF.
  ENDMETHOD.
ENDCLASS.
