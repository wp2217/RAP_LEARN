@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consume view of ZI_ROC_INV_SET_H'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_ROC_INV_SET_H
  provider contract transactional_query
  as projection on ZI_ROC_INV_SET_H
{
  key SettleNo,
      @ObjectModel.text.element: [ 'BusTypeText' ]
      BusinessType,
      _BUS_TYPE_VH.Text      as BusTypeText,

      @ObjectModel.text.element: [ 'SettleTypeText' ]
      SettleType,
      _SETTLE_TYPE_VH.Text   as SettleTypeText,

      @ObjectModel.text.element: [ 'SettleStatusText' ]
      SettleStatus,
      _SETTLE_STATUS_VH.Text as SettleStatusText,

      @ObjectModel.text.element: [ 'TransEventText' ]
      TransactionEvent,
      _TRANS_EVENT_VH.Text   as TransEventText,

      InvoiceNo,
      InvoiceType,
      InvoiceDate,
      @ObjectModel.text.element: [ 'BuyerName' ]
      Bukrs,
      BuyerName,
      @ObjectModel.text.element: [ 'SellerName' ]
      Lifnr,
      SellerName,
      @Semantics: {
        amount.currencyCode: 'Waers'
      }
      GrossAmount,
      @Semantics: {
      amount.currencyCode: 'Waers'
      }
      TaxAmount,
      @Semantics: {
      amount.currencyCode: 'Waers'
      }
      NetAmount,
      @Semantics: {
      amount.currencyCode: 'Waers'
      }
      SelectedTaxAmount,
      @Semantics: {
      amount.currencyCode: 'Waers'
      }
      SelectedNetAmount,
      @Semantics: {
      amount.currencyCode: 'Waers'
      }
      DiffTaxAmount,
      @Semantics: {
      amount.currencyCode: 'Waers'
      }
      DiffNetAmount,
      Mwskz,
      TaxRate,
      Waers,
      Bktxt,
      Sgtxt,
      DpNo,
      IdocNumber,
      AccountingDocument,
      FiscalYear,
      BatchCreated,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      /* Associations */
      _invItem : redirected to composition child ZC_ROC_INV_SET_I,
      _BUS_TYPE_VH
}
