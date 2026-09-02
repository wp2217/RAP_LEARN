CLASS lhc_zi_roc_inv_set_h DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_roc_inv_set_h RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_roc_inv_set_h RESULT result.
    METHODS setinvoicedata FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_roc_inv_set_h~setinvoicedata.
    METHODS createwithparams FOR MODIFY
      IMPORTING keys FOR ACTION zi_roc_inv_set_h~createwithparams.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_roc_inv_set_h RESULT result.
    METHODS validaterequiredfields FOR VALIDATE ON SAVE
       keys FOR zi_roc_inv_set_h~validaterequiredfields.
    METHODS getgritem FOR MODIFY
       keys FOR ACTION zi_roc_inv_set_h~getgritem RESULT result.
    METHODS dosubmit FOR MODIFY
      keys FOR ACTION zi_roc_inv_set_h~dosubmit RESULT result.

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
    DATA:
      lt_mapped    TYPE TABLE FOR MAPPED EARLY zi_roc_inv_set_h,
      ls_mapped    LIKE LINE OF lt_mapped,
      lt_to_number TYPE TABLE FOR CREATE zi_roc_inv_set_h.

    " 1) 过滤：框架可能已经给过号（重入时），或外部早期编号已带进来
    lt_to_number = entities.
    DELETE lt_to_number WHERE SettleNo IS NOT INITIAL.   " 必须有这行 [6](@ref)
    IF lt_to_number IS INITIAL.

      LOOP AT entities INTO DATA(ls_entities).
        ls_mapped-%cid = ls_entities-%cid.
        ls_mapped-%is_draft = ls_entities-%is_draft.
        ls_mapped-settleno = ls_entities-SettleNo.
        APPEND ls_mapped TO mapped-zi_roc_inv_set_h.
      ENDLOOP.

    ELSE.

      DATA(lv_qty) = lines( lt_to_number ).

      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr       = '01'
              object            = 'ZROC_INV01'
              quantity          = CONV #( lv_qty )
            IMPORTING
              number            = DATA(lv_number)
              returncode        = DATA(lv_returncode)
              returned_quantity = DATA(lv_return_qty)
          ).
        CATCH cx_nr_object_not_found.
        CATCH cx_number_ranges INTO DATA(lo_error).

          LOOP AT lt_to_number INTO ls_entities.
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

      LOOP AT lt_to_number INTO ls_entities.
        ls_mapped-%cid = ls_entities-%cid.
        ls_mapped-%is_draft = ls_entities-%is_draft.

        ls_mapped-settleno = lv_number+8(12).
        lv_number += 1.

        APPEND ls_mapped TO mapped-zi_roc_inv_set_h.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD earlynumbering_cba_invitem.

    DATA: lv_max_item_id TYPE zroc_inv_set_i-item_no.

    READ ENTITIES OF zi_roc_inv_set_h IN LOCAL MODE
      ENTITY zi_roc_inv_set_h BY \_invItem
      FROM CORRESPONDING #( entities )
      RESULT DATA(lt_item_result)
      LINK DATA(lt_item_link).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entiies_group>)
      GROUP BY <ls_entiies_group>-SettleNo.

      "lt_item_link中会存已经创建的item id
      lv_max_item_id = REDUCE #( INIT lv_max = CONV zroc_inv_set_i-item_no( 0 )
                                    FOR ls_link IN lt_item_link USING KEY entity
                                    WHERE ( source-SettleNo = <ls_entiies_group>-SettleNo )
                                    NEXT lv_max = COND zroc_inv_set_i-item_no( WHEN lv_max < ls_link-target-ItemNo
                                                                        THEN ls_link-target-ItemNo
                                                                        ELSE lv_max ) ).
      "entities中的%target只存最新的无item id的item数据
      lv_max_item_id = REDUCE #( INIT lv_max = lv_max_item_id
                                    FOR ls_entity IN entities USING KEY entity
                                    WHERE ( SettleNo = <ls_entiies_group>-SettleNo )
                                      FOR ls_item IN ls_entity-%target
                                    NEXT lv_max = COND zroc_inv_set_i-item_no( WHEN lv_max < ls_item-ItemNo
                                                                        THEN ls_item-ItemNo
                                                                        ELSE lv_max ) ).

      "为空的item id赋值
      LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>) USING KEY entity
       WHERE SettleNo = <ls_entiies_group>-SettleNo.

        LOOP AT <ls_entity>-%target ASSIGNING FIELD-SYMBOL(<ls_item>).
          IF <ls_item>-ItemNo IS INITIAL.

            "生成编号
            lv_max_item_id += 10.

            APPEND VALUE #(
              %cid    = <ls_item>-%cid
              %is_draft = <ls_item>-%is_draft
              settleno = <ls_item>-SettleNo
              ItemNo  = lv_max_item_id
            ) TO mapped-zi_roc_inv_set_i.

          ELSE.

            "已有编号，同样必须返回
            APPEND VALUE #(
              %cid    = <ls_item>-%cid
              %is_draft = <ls_item>-%is_draft
               settleno = <ls_item>-SettleNo
              ItemNo  = <ls_item>-ItemNo
            ) TO mapped-zi_roc_inv_set_i.

          ENDIF.
        ENDLOOP.
      ENDLOOP.

    ENDLOOP.

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
          ls_set_h-lifnr = ls_invoice-lifnr.
          ls_set_h-sellername = ls_invoice-seller_name.
          ls_set_h-waers = ls_invoice-waers.
          ls_set_h-bktxt = ls_invoice-remark.
          ls_set_h-grossamount = ls_invoice-gross_amount.
          ls_set_h-netamount = ls_invoice-net_amount.
          ls_set_h-taxamount = ls_invoice-tax_amount.
          ls_set_h-invoicedate = ls_invoice-invoice_date.
          MODIFY lt_set_h FROM ls_set_h.
        ENDIF.
      ENDLOOP.

      MODIFY ENTITIES OF zi_roc_inv_set_h IN LOCAL MODE
        ENTITY zi_roc_inv_set_h
        UPDATE FIELDS ( lifnr sellername waers bktxt grossamount netamount taxamount invoicedate )
        WITH CORRESPONDING #( lt_set_h ).

    ENDIF.

  ENDMETHOD.

  METHOD createwithparams.
    CHECK keys IS NOT INITIAL.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_keys>).
      IF <fs_keys>-%param-companycode IS INITIAL OR <fs_keys>-%param-settletype IS INITIAL OR <fs_keys>-%param-businesstype IS INITIAL.

        APPEND VALUE #( %cid = <fs_keys>-%cid ) TO failed-zi_roc_inv_set_h.

        APPEND VALUE #( %cid              = <fs_keys>-%cid
                        %msg              = new_message(
                      id       = '00'
                      number   = '001'
                      severity = if_abap_behv_message=>severity-error
                      v1       = '请录入必填项'
                      v2       = space
                      v3       = space
                      v4       = space
                      )

        ) TO reported-zi_roc_inv_set_h.

      ENDIF.

      IF <fs_keys>-%param-settletype = '02' AND <fs_keys>-%param-businesstype = '03'.
        APPEND VALUE #( %cid = <fs_keys>-%cid ) TO failed-zi_roc_inv_set_h.

        APPEND VALUE #( %cid              = <fs_keys>-%cid
                        %msg              = new_message(
                      id       = '00'
                      number   = '001'
                      severity = if_abap_behv_message=>severity-error
                      v1       = '寄售业务只能选择基于PO的结算类型'
                      v2       = space
                      v3       = space
                      v4       = space
                      )

        ) TO reported-zi_roc_inv_set_h.
      ENDIF.

    ENDLOOP.

    CHECK failed IS INITIAL.

    MODIFY ENTITIES OF zi_roc_inv_set_h IN LOCAL MODE
      ENTITY zi_roc_inv_set_h
      CREATE FIELDS ( bukrs settletype businesstype settlestatus )
      WITH VALUE #( FOR key IN keys
        ( %cid         = key-%cid
          %is_draft    = if_abap_behv=>mk-on          " 进 draft，不激活
          bukrs        = key-%param-companycode
          settletype   = key-%param-settletype
          businesstype = key-%param-businesstype
          settlestatus = '01'  "默认草稿状态
           ) )
      MAPPED mapped
      FAILED failed
      REPORTED reported.

  ENDMETHOD.

  METHOD get_instance_features.

    " 读父实体状态（单据头状态）
    READ ENTITIES OF zi_roc_inv_set_h IN LOCAL MODE
      ENTITY zi_roc_inv_set_h
      "FIELDS ( settletype )
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_set_h)
      FAILED failed.

    LOOP AT lt_set_h INTO DATA(ls_set_h).

      "基于PO的且是草稿状态，且必输入项全填 抬头GET GR Item按钮才可用
      DATA(lv_getgritem_enabled) =
        COND #( WHEN ls_set_h-settletype = '01' AND ls_set_h-%is_draft = if_abap_behv=>mk-on
                 AND ls_set_h-InvoiceNo IS NOT INITIAL AND ls_set_h-Lifnr IS NOT INITIAL AND ls_set_h-TransactionEvent IS NOT INITIAL
                THEN if_abap_behv=>fc-o-enabled
                ELSE if_abap_behv=>fc-o-disabled ).


      "无PO的且是草稿状态，行项目create按钮才可用
      DATA(lv_item_enabled) =
        COND #( WHEN ls_set_h-settletype = '02' AND ls_set_h-%is_draft = if_abap_behv=>mk-on
                THEN if_abap_behv=>fc-o-enabled
                ELSE if_abap_behv=>fc-o-disabled ).

      APPEND VALUE #(
        %tky        = ls_set_h-%tky
        %assoc-_invitem = lv_item_enabled
        %action-getgritem = lv_getgritem_enabled
      ) TO result.

    ENDLOOP.

  ENDMETHOD.


  METHOD validateRequiredFields.

    READ ENTITIES OF zi_roc_inv_set_h IN LOCAL MODE
        ENTITY zi_roc_inv_set_h
        ALL FIELDS
        "FIELDS ( InvoiceNo )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_set_h).

    LOOP AT lt_set_h ASSIGNING FIELD-SYMBOL(<fs_sel_h>).
      IF <fs_sel_h>-InvoiceNo IS INITIAL OR <fs_sel_h>-Lifnr IS INITIAL OR <fs_sel_h>-TransactionEvent IS INITIAL.

        APPEND VALUE #( %tky = <fs_sel_h>-%tky ) TO failed-zi_roc_inv_set_h.
        APPEND VALUE #( %tky              = <fs_sel_h>-%tky
                        %msg              = new_message(
                      id       = '00'
                      number   = '001'
                      severity = if_abap_behv_message=>severity-error
                      v1       = '请录入必填项'
                      v2       = space
                      v3       = space
                      v4       = space
                      )

        ) TO reported-zi_roc_inv_set_h.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD getGRItem.
    "Action 方法是在用户确认参数弹出框以后才会被调用
    CHECK keys IS NOT INITIAL.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_keys>).
      IF <fs_keys>-%param IS INITIAL.

        APPEND VALUE #( %tky = <fs_keys>-%tky ) TO failed-zi_roc_inv_set_h.

        APPEND VALUE #( %tky              = <fs_keys>-%tky
                        %msg              = new_message(
                      id       = '00'
                      number   = '001'
                      severity = if_abap_behv_message=>severity-error
                      v1       = '至少录入一个查询条件'
                      v2       = space
                      v3       = space
                      v4       = space
                      )

        ) TO reported-zi_roc_inv_set_h.

        RETURN.

      ENDIF.

    ENDLOOP.

    CHECK failed IS INITIAL.
  ENDMETHOD.

  METHOD doSubmit.


  ENDMETHOD.

ENDCLASS.
