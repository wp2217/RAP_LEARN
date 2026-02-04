@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view of SM30 Data'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_SM30_ROC
  as select from ztb_sm30_roc
  association to parent ZI_SM30_SINGLETON as _SM30_SINGLETON on $projection.SM30SingletonField = _SM30_SINGLETON.SM30SingletonField
{
  key param              as Param,
      1                  as SM30SingletonField,
      description        as Description,
      value              as Value,
       @EndUserText.label: 'Active or Not'
      active             as Active,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      locallastchangedat as Locallastchangedat, //Etag
      @Semantics.systemDateTime.lastChangedAt: true
      lastchangedat      as Lastchangedat, //Total Etag

      _SM30_SINGLETON
}
