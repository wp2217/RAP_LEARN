@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Maintain original invoice data'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZROC_INVOICE'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_ROC_INVOICE
  provider contract transactional_query
  as projection on ZR_ROC_INVOICE
  association [1..1] to ZR_ROC_INVOICE as _BaseEntity on $projection.InvUUID = _BaseEntity.InvUUID
{
  key InvUUID,
      InvoiceNo,
      Bukrs,
      InvoiceDate,
      BuyerName,
      BuyerTaxno,
      Lifnr,
      SellerName,
      SellerTaxno,
      SellerBank,
      @Semantics: {
        amount.currencyCode: 'Waers'
      }
      NetAmount,
      @Semantics: {
        amount.currencyCode: 'Waers'
      }
      GrossAmount,
      @Semantics: {
        amount.currencyCode: 'Waers'
      }
      TaxAmount,
      @Consumption: {
        valueHelpDefinition: [ {
          entity.element: 'Currency',
          entity.name: 'I_CurrencyStdVH',
          useForValidation: true
        } ]
      }
      Waers,
      RequestNo,
      Remark,
      InvCategory,
      InvStatus,
      InvType,
      BusinessType,
      PdfUrl,
      XmlUrl,
      @Semantics: {
        user.createdBy: true
      }
      CreatedBy,
      @Semantics: {
        systemDateTime.createdAt: true
      }
      CreatedAt,
      @Semantics: {
        user.localInstanceLastChangedBy: true
      }
      LastChangedBy,
      @Semantics: {
        systemDateTime.localInstanceLastChangedAt: true
      }
      LastChangedAt,
      _BaseEntity
}
