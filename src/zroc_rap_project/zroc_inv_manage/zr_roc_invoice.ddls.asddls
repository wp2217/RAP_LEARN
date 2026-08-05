@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZROC_INVOICE'
@EndUserText.label: 'Maintain original invoice data'
define root view entity ZR_ROC_INVOICE
  as select from zroc_invoice
{
  key inv_uuid        as InvUUID,
      invoice_no      as InvoiceNo,
      bukrs           as Bukrs,
      invoice_date    as InvoiceDate,
      buyer_name      as BuyerName,
      buyer_taxno     as BuyerTaxno,
      lifnr           as Lifnr,
      seller_name     as SellerName,
      seller_taxno    as SellerTaxno,
      seller_bank     as SellerBank,
      @Semantics.amount.currencyCode: 'Waers'
      net_amount      as NetAmount,
      @Semantics.amount.currencyCode: 'Waers'
      gross_amount    as GrossAmount,
      @Semantics.amount.currencyCode: 'Waers'
      tax_amount      as TaxAmount,
      @Consumption.valueHelpDefinition: [ {
        entity.name: 'I_CurrencyStdVH',
        entity.element: 'Currency',
        useForValidation: true
      } ]
      waers           as Waers,
      request_no      as RequestNo,
      remark          as Remark,
      inv_category    as InvCategory,
      inv_status      as InvStatus,
      inv_type        as InvType,
      business_type   as BusinessType,
      pdf_url         as PdfUrl,
      xml_url         as XmlUrl,
      @Semantics.user.createdBy: true
      created_by      as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at      as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at as LastChangedAt
}
