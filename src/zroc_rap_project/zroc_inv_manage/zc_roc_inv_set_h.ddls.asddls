@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consume view of ZI_ROC_INV_SET_H'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_ROC_INV_SET_H
  provider contract transactional_query
  as projection on ZI_ROC_INV_SET_H
{
  key SettleNo,
      BusinessType,
      SettleType,
      SettleStatus,
      TransactionEvent,
      InvoiceNo,
      InvoiceType,
      InvoiceTime,
      Bukrs,
      BuyerName,
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
      _invItem : redirected to composition child ZC_ROC_INV_SET_I
}
