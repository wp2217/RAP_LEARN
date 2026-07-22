@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for ZI_ROC_CODE_ATTACH'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_ROC_CODE_ATTACH
  as projection on ZI_ROC_CODE_ATTACH
{
  key CodeUuid,
  key CodeAttachUuid,
      MimeType,
      FileName,

      @Semantics.largeObject: {
      mimeType: 'Mimetype',
      fileName: 'Filename',
      //acceptableMimeTypes:[image/*, 'application/*'],
      //acceptableMimeTypes: [ 'text/csv', 'application/vnd.ms-excel' ,'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ],
      contentDispositionPreference: #INLINE  //#INLINE代表浏览器中直接打开，#Attachment代表下载打开
      }
      Attachment,
      /* Associations */
      _Code : redirected to parent ZC_ROC_CODE
}
