@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for ZROC_INV_SET_I'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_ROC_INV_SET_I
  as select from zroc_inv_set_i
  association to parent ZI_ROC_INV_SET_H as _invHeader on $projection.SettleNo = _invHeader.SettleNo
{
  key settle_no               as SettleNo,
  key item_no                 as ItemNo,
      invoice_no              as InvoiceNo,
      purchase_order          as PurchaseOrder,
      purchase_order_item     as PurchaseOrderItem,
      po_type                 as PoType,
      po_date                 as PoDate,
      po_changed_date         as PoChangedDate,
      po_created_by           as PoCreatedBy,
      plant                   as Plant,
      storage_location        as StorageLocation,
      batch                   as Batch,
      material                as Material,
      short_text              as ShortText,
      @Semantics.quantity.unitOfMeasure: 'OrderUnit'
      quantity                as Quantity,
      order_unit              as OrderUnit,
      net_price               as NetPrice,
      price_unit              as PriceUnit,
      @Semantics.amount.currencyCode: 'Currency'
      document_amount         as DocumentAmount,
      @Semantics.amount.currencyCode: 'Currency'
      planned_delivery_amount as PlannedDeliveryAmount,
      currency                as Currency,
      tax_code                as TaxCode,
      tax_rate                as TaxRate,
      @Semantics.amount.currencyCode: 'Currency'
      tax_amount              as TaxAmount,
      material_document       as MaterialDocument,
      material_doc_year       as MaterialDocYear,
      material_doc_item       as MaterialDocItem,
      reference_document      as ReferenceDocument,
      condition_type          as ConditionType,
      external_delivery       as ExternalDelivery,
      entry_date              as EntryDate,
      entry_time              as EntryTime,
      debit_credit            as DebitCredit,
      gl_account_npo          as GlAccountNpo,
      cost_center_npo         as CostCenterNpo,
      assignment_npo          as AssignmentNpo,
      item_text_npo           as ItemTextNpo,
      debit_credit_npo        as DebitCreditNpo,
      @Semantics.amount.currencyCode: 'Currency'
      amount_npo              as AmountNpo,
      tax_code_npo            as TaxCodeNpo,
      tax_rate_npo            as TaxRateNpo,
      @Semantics.amount.currencyCode: 'Currency'
      tax_amount_npo          as TaxAmountNpo,

      _invHeader
}
