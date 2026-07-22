@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view of Table ZROC_CODE_ATTACH'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_ROC_CODE_ATTACH
  as select from zroc_code_attach
  association to parent ZI_ROC_CODE as _Code on $projection.CodeUuid = _Code.CodeUuid
{
  key code_uuid        as CodeUuid,
  key code_attach_uuid as CodeAttachUuid,

      @Semantics.mimeType: true
      mimetype         as MimeType,
      filename         as FileName,
      attachment       as Attachment,
      _Code
}
