CLASS lhc_zi_file_data_roc DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_file_data_roc RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_file_data_roc RESULT result.

    METHODS uploadexceldata FOR MODIFY
      IMPORTING keys FOR ACTION zi_file_data_roc~uploadexceldata RESULT result.

    METHODS fillfilestatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_file_data_roc~fillfilestatus.

    METHODS fillselectedstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_file_data_roc~fillselectedstatus.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_file_data_roc RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zi_file_data_roc.

ENDCLASS.

CLASS lhc_zi_file_data_roc IMPLEMENTATION.

  METHOD get_instance_authorizations.

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entities>).
      APPEND CORRESPONDING #( <fs_entities> ) TO mapped-zi_file_data_roc
        ASSIGNING FIELD-SYMBOL(<fs_mapped_file_data>).

      <fs_mapped_file_data>-enduser = lv_user.
      TRY.
          <fs_mapped_file_data>-fileid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.

  METHOD uploadexceldata.

    DATA:
      lv_index        TYPE sy-index,
      lo_table_descr  TYPE REF TO cl_abap_tabledescr,
      lo_struct_descr TYPE REF TO cl_abap_structdescr,
      lt_po_data      TYPE TABLE FOR CREATE zi_file_data_roc\_po_data,
      lt_excel        TYPE STANDARD TABLE OF zcl_bp_file_data_roc=>ty_po_excel.

    FIELD-SYMBOLS: <lfs_col_header>  TYPE any.

    "根据Key读取最新的数据
    READ ENTITIES OF zi_file_data_roc IN LOCAL MODE
      ENTITY zi_file_data_roc
      ALL FIELDS
      WITH CORRESPONDING  #( keys )
        RESULT DATA(lt_file_data).

    DATA(lv_attachment) = lt_file_data[ 1 ]-attachment.

    IF lv_attachment IS INITIAL .
      LOOP AT lt_file_data ASSIGNING FIELD-SYMBOL(<fs_file_data>).
        APPEND VALUE #( %tky = <fs_file_data>-%tky ) TO failed-zi_file_data_roc.

        APPEND VALUE #( %tky              = <fs_file_data>-%tky
                        %msg              = new_message(
                        id       = '00'
                        number   = '001'
                        severity = if_abap_behv_message=>severity-error
                        v1       = 'Attachment data is null, please check'
                        v2       = ''
                        v3       = ''
                        v4       = ''
                        )
                      "  %element- = if_abap_behv=>mk-on
        ) TO reported-zi_file_data_roc.
      ENDLOOP.
    ELSE. "Process attachment

      "Move Excel Data to Internal Table
      DATA(lo_xlsx) = xco_cp_xlsx=>document->for_file_content( iv_file_content = lv_attachment )->read_access( ).
      DATA(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ).  "get first worksheet
      DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).
      DATA(lo_execute) = lo_worksheet->select(  lo_selection_pattern )->row_stream( )->operation->write_to( REF #( lt_excel ) ).
      lo_execute->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value )->if_xco_xlsx_ra_operation~execute( ).

      "Get number of columns in upload file for validation
      TRY.
          lo_table_descr ?= cl_abap_tabledescr=>describe_by_data( p_data = lt_excel ).
          lo_struct_descr ?= lo_table_descr->get_table_line_type( ).
          DATA(lv_no_of_cols) = lines( lo_struct_descr->components ).
        CATCH cx_sy_move_cast_error.
          "Implement error handling
      ENDTRY.

      "Validate Header record
      DATA(ls_excel) = VALUE #( lt_excel[ 1 ] OPTIONAL ).
      IF ls_excel IS NOT INITIAL.
        DO lv_no_of_cols TIMES.
          lv_index = sy-index.
          ASSIGN COMPONENT lv_index OF STRUCTURE ls_excel TO <lfs_col_header>.
          CHECK <lfs_col_header> IS ASSIGNED.
          DATA(lv_value) =  to_upper(  <lfs_col_header> ) .
          DATA(lv_has_error) = abap_false.
          CASE lv_index.
            WHEN 1.
              lv_has_error = COND #( WHEN lv_value <> 'PO' THEN abap_true ELSE lv_has_error ).
            WHEN 2.
              lv_has_error = COND #( WHEN lv_value <> 'PO_ITEM' THEN abap_true ELSE lv_has_error ).
            WHEN 3.
              lv_has_error = COND #( WHEN lv_value <> 'QTY' THEN abap_true ELSE lv_has_error ).
            WHEN 4.
              lv_has_error = COND #( WHEN lv_value <> 'UNIT' THEN abap_true ELSE lv_has_error ).
            WHEN 9. "More than 9 columns (error)
              lv_has_error = abap_true.
          ENDCASE.
          IF lv_has_error = abap_true.
            APPEND VALUE #( %tky = lt_file_data[ 1 ]-%tky ) TO failed-zi_file_data_roc.
            APPEND VALUE #(
              %tky = lt_file_data[ 1 ]-%tky
              %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-error
                       text     = 'One or more heading is incorrect !!' )
            ) TO reported-zi_file_data_roc.
            UNASSIGN <lfs_col_header>.
            EXIT.
          ENDIF.
          UNASSIGN <lfs_col_header>.
        ENDDO.
      ENDIF.
      CHECK lv_has_error = abap_false.

      DELETE lt_excel INDEX 1.
      DELETE lt_excel WHERE ebeln  IS INITIAL.

      TRY.
          DATA(lv_line_id) =  cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.

      LOOP AT lt_excel ASSIGNING FIELD-SYMBOL(<fs_excel>).
        <fs_excel>-line_id = lv_line_id.
        <fs_excel>-line_no = sy-tabix.
      ENDLOOP.

      "Prepare Data for Child Entity
*      lt_po_data = VALUE #( (
*           %cid_ref =  keys[ 1 ]-%cid_ref
*           %is_draft = keys[ 1 ]-%is_draft
*           enduser = keys[ 1 ]-enduser
*           fileid = keys[ 1 ]-fileid
*           %target = VALUE #(
*             FOR ls_excel_tmp IN lt_excel (
*                 %cid =  keys[ 1 ]-%cid_ref
*                 %is_draft = keys[ 1 ]-%is_draft
*                 enduser = keys[ 1 ]-enduser
*                 fileid = keys[ 1 ]-fileid
*                 lineid = ls_excel_tmp-line_id
*                 linenum = ls_excel_tmp-line_no
*                 ebeln = ls_excel_tmp-ebeln
*                 ebelp = ls_excel_tmp-ebelp
*                 quantity = ls_excel_tmp-quantity
*                 baseuom = ls_excel_tmp-base_uom
*              ) )
*      ) ).

      lt_po_data = VALUE #( (
           %cid_ref =  keys[ 1 ]-%cid_ref
           %is_draft = keys[ 1 ]-%is_draft
           enduser = keys[ 1 ]-enduser
           fileid = keys[ 1 ]-fileid
           %target = VALUE #(
             FOR ls_excel_tmp IN lt_excel (
                 %cid =  keys[ 1 ]-%cid_ref
                 %is_draft = keys[ 1 ]-%is_draft
                 %data = VALUE #(
                   enduser = keys[ 1 ]-enduser
                   fileid = keys[ 1 ]-fileid
                   lineid = ls_excel_tmp-line_id
                   linenum = ls_excel_tmp-line_no
                   ebeln = |{ ls_excel_tmp-ebeln ALPHA = IN }|
                   ebelp = |{ ls_excel_tmp-ebelp ALPHA = IN }|
                   quantity = ls_excel_tmp-quantity
                   baseuom = |{ ls_excel_tmp-base_uom ALPHA = IN }|
                 )
                 %control = VALUE #(
                   enduser = if_abap_behv=>mk-on
                   fileid = if_abap_behv=>mk-on
                   lineid = if_abap_behv=>mk-on
                   linenum = if_abap_behv=>mk-on
                   ebeln = if_abap_behv=>mk-on
                   ebelp = if_abap_behv=>mk-on
                   quantity = if_abap_behv=>mk-on
                   baseuom  = if_abap_behv=>mk-on
                 )
              ) )
      ) ).

      MODIFY ENTITIES OF zi_file_data_roc IN LOCAL MODE
        ENTITY zi_file_data_roc CREATE BY \_po_data
        AUTO FILL CID WITH lt_po_data.

      MODIFY ENTITIES OF zi_file_data_roc IN LOCAL MODE
         ENTITY zi_file_data_roc
         UPDATE FIELDS ( status )
         WITH VALUE #( FOR ls_key IN keys (
         %tky = ls_key-%tky
         status = 'File Uploaded'
         ) ).

      "Read updated data and send back to front
      READ ENTITIES OF zi_file_data_roc IN LOCAL MODE
        ENTITY zi_file_data_roc
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_updated_data).


      result = VALUE #(
        FOR ls_updated_data IN lt_updated_data (
         %tky = ls_updated_data-%tky
         %param = ls_updated_data
        )
       ).

    ENDIF.

  ENDMETHOD.

  METHOD fillfilestatus.
    MODIFY ENTITIES OF zi_file_data_roc IN LOCAL MODE
      ENTITY zi_file_data_roc
      UPDATE FIELDS ( status )
      WITH VALUE #( FOR ls_key IN keys (
      %tky = ls_key-%tky
      status = 'File Not Selected'
      ) ).

  ENDMETHOD.

  METHOD fillselectedstatus.
    "根据Key读取最新的数据
    READ ENTITIES OF zi_file_data_roc IN LOCAL MODE
      ENTITY zi_file_data_roc
      ALL FIELDS
      WITH CORRESPONDING  #( keys )
        RESULT DATA(lt_file_data).

    LOOP AT lt_file_data ASSIGNING FIELD-SYMBOL(<fs_file_data>).
      IF <fs_file_data>-attachment IS NOT INITIAL.
        <fs_file_data>-status = 'File Selected'.
      ELSE.
        <fs_file_data>-status = 'File Not Selected'.
      ENDIF.
    ENDLOOP.

    "修改状态
    MODIFY ENTITIES OF zi_file_data_roc IN LOCAL MODE
      ENTITY zi_file_data_roc
      UPDATE FIELDS ( status )
      WITH CORRESPONDING #( lt_file_data ).

  ENDMETHOD.

  METHOD get_instance_features.

    "根据Key读取最新的数据
    READ ENTITIES OF zi_file_data_roc IN LOCAL MODE
      ENTITY zi_file_data_roc
      ALL FIELDS
      WITH CORRESPONDING  #( keys )
        RESULT DATA(lt_file_data).

    result = VALUE #( FOR ls_file_data IN lt_file_data (
      %tky = ls_file_data-%tky
      %features-%action-uploadexceldata = COND #( WHEN ls_file_data-status = 'File Selected'
                                               THEN if_abap_behv=>fc-o-enabled
                                               ELSE if_abap_behv=>fc-o-disabled )
     ) ).

  ENDMETHOD.

ENDCLASS.
