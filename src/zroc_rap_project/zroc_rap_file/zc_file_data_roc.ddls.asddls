@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for ZI_FILE_DATA_ROC'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_FILE_DATA_ROC
  provider contract transactional_query
  as projection on ZI_FILE_DATA_ROC
{

  key EndUser, 
  key FileId,
      Status,
      @Semantics.largeObject: {
        mimeType: 'Mimetype',
        fileName: 'Filename',
        //acceptableMimeTypes:[image/*, 'application/*'],
        acceptableMimeTypes: [ 'text/csv', 'application/vnd.ms-excel' ,'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ],
        contentDispositionPreference: #INLINE  //#INLINE代表浏览器中直接打开，#Attachment代表下载打开
        }
      Attachment, 
      Mimetype,
      Filename,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _po_data : redirected to composition child ZC_PO_DATA_ROC
}
