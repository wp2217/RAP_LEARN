@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface Root view of Singleton SM30'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_SM30_SINGLETON
  as select from    I_Language
    left outer join ztb_sm30_roc as zsm30 on 1 = 1  // for total Etag
  composition [0..*] of ZI_SM30_ROC as _SM30_DATA
{
  key 1                        as SM30SingletonField,
      max(zsm30.lastchangedat) as maxChangeAt,
      _SM30_DATA

}
where
  I_Language.Language = $session.system_language
