@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view of ZROC_FILE_DATA'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_FILE_DATA_ROC
  as select from zroc_file_data
  composition [0..*] of ZI_PO_DATA_ROC as _po_data
{
  key end_user              as EndUser,
  key file_id               as FileId,
      status                as Status,


      attachment            as Attachment, 

      @Semantics.mimeType: true
      mimetype              as Mimetype,
      filename              as Filename,

      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      //total ETag field
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      _po_data
}
