@ObjectModel.dataCategory: #VALUE_HELP
@EndUserText.label: 'Invoice F4'
@Search.searchable: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZI_ROC_INVOICE_VH
  as select from zroc_invoice
{
  key inv_uuid        as InvUuid,
      @Search.defaultSearchElement: true
      invoice_no      as InvoiceNo,
      @Search.defaultSearchElement: true
      bukrs           as Bukrs,
      invoice_date    as InvoiceDate,
      buyer_name      as BuyerName,
      buyer_taxno     as BuyerTaxno,
      lifnr           as Lifnr,
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      seller_name     as SellerName,
      seller_taxno    as SellerTaxno,
      seller_bank     as SellerBank,
      net_amount      as NetAmount,
      gross_amount    as GrossAmount,
      tax_amount      as TaxAmount,
      waers           as Waers,
      request_no      as RequestNo,
      remark          as Remark,
      inv_category    as InvCategory,
      inv_status      as InvStatus,
      inv_type        as InvType,
      business_type   as BusinessType,
      pdf_url         as PdfUrl,
      xml_url         as XmlUrl,
      created_by      as CreatedBy,
      created_at      as CreatedAt,
      last_changed_by as LastChangedBy,
      last_changed_at as LastChangedAt
}
