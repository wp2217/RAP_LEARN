@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consume view of ZI_ROC_INV_SET_I'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_ROC_INV_SET_I
  as projection on ZI_ROC_INV_SET_I
{
  key SettleNo,
  key ItemNo,
      InvoiceNo,
      PurchaseOrder,
      PurchaseOrderItem,
      PoType,
      PoDate,
      PoChangedDate,
      PoCreatedBy,
      Plant,
      StorageLocation,
      Batch,
      Material,
      ShortText,
      @Semantics.quantity.unitOfMeasure: 'OrderUnit'
      Quantity,
      OrderUnit,
      NetPrice,
      PriceUnit,
      @Semantics.amount.currencyCode: 'Currency'
      DocumentAmount,
      @Semantics.amount.currencyCode: 'Currency'
      PlannedDeliveryAmount,
      Currency,
      TaxCode,
      TaxRate,
      @Semantics.amount.currencyCode: 'Currency'
      TaxAmount,
      MaterialDocument,
      MaterialDocYear,
      MaterialDocItem,
      ReferenceDocument,
      ConditionType,
      ExternalDelivery,
      EntryDate,
      EntryTime,
      DebitCredit,
      GlAccountNpo,
      CostCenterNpo,
      AssignmentNpo,
      ItemTextNpo,
      DebitCreditNpo,
      @Semantics.amount.currencyCode: 'Currency'
      AmountNpo,
      TaxCodeNpo,
      TaxRateNpo,
      @Semantics.amount.currencyCode: 'Currency'
      TaxAmountNpo,
      /* Associations */
      _invHeader: redirected to parent ZC_ROC_INV_SET_H
}
