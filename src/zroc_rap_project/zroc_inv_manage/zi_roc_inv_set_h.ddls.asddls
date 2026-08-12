@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for ZROC_INV_SET_H'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_ROC_INV_SET_H
  as select from zroc_inv_set_h
  composition [0..*] of ZI_ROC_INV_SET_I        as _invItem
  association [0..1] to ZI_ROC_INV_BUS_TYPE_VH  as _BUS_TYPE_VH      on $projection.BusinessType = _BUS_TYPE_VH.Code
  association [0..1] to ZI_ROC_SETTLE_TYPE_VH   as _SETTLE_TYPE_VH   on $projection.SettleType = _SETTLE_TYPE_VH.Code
  association [0..1] to ZI_ROC_SETTLE_STATUS_VH as _SETTLE_STATUS_VH on $projection.SettleStatus = _SETTLE_STATUS_VH.Code
  association [0..1] to ZI_ROC_TRANS_EVENT_VH   as _TRANS_EVENT_VH   on $projection.TransactionEvent = _TRANS_EVENT_VH.Code
{

  key settle_no           as SettleNo,
      business_type       as BusinessType,
      settle_type         as SettleType,
      settle_status       as SettleStatus,
      transaction_event   as TransactionEvent,
      invoice_no          as InvoiceNo,
      invoice_type        as InvoiceType, 
      invoice_date        as InvoiceDate,
      bukrs               as Bukrs,
      buyer_name          as BuyerName,
      lifnr               as Lifnr,
      seller_name         as SellerName,
      @Semantics.amount.currencyCode: 'Waers'
      gross_amount        as GrossAmount,
      @Semantics.amount.currencyCode: 'Waers'
      tax_amount          as TaxAmount,
      @Semantics.amount.currencyCode: 'Waers'
      net_amount          as NetAmount,
      @Semantics.amount.currencyCode: 'Waers'
      selected_tax_amount as SelectedTaxAmount,
      @Semantics.amount.currencyCode: 'Waers'
      selected_net_amount as SelectedNetAmount,
      @Semantics.amount.currencyCode: 'Waers'
      diff_tax_amount     as DiffTaxAmount,
      @Semantics.amount.currencyCode: 'Waers'
      diff_net_amount     as DiffNetAmount,
      mwskz               as Mwskz,
      tax_rate            as TaxRate,
      waers               as Waers,
      bktxt               as Bktxt,
      sgtxt               as Sgtxt,
      dp_no               as DpNo,
      idoc_number         as IdocNumber,
      accounting_document as AccountingDocument,
      fiscal_year         as FiscalYear,
      batch_created       as BatchCreated,

      @Semantics.user.createdBy: true
      created_by          as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at          as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by     as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at     as LastChangedAt,

      _invItem, // Make association public
      _BUS_TYPE_VH,
      _SETTLE_TYPE_VH,
      _SETTLE_STATUS_VH,
      _TRANS_EVENT_VH
}
