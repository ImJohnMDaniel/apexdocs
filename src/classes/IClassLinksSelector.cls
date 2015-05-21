public interface IClassLinksSelector
    extends fflib_ISObjectSelector
{
    list<ClassLink__c> selectById(set<ID> idSet);
    list<ClassLink__c> selectByLinksNotResolved();
    list<ClassLink__c> selectByLinkTo(final id linkToId);
    list<ClassLink__c> selectByApexClassNameParent(final set<string> fileNameSet);
}