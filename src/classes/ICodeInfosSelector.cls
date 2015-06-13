public interface ICodeInfosSelector
    extends fflib_ISObjectSelector
{
    list<CodeInfo__c> selectById(set<ID> idSet);
    list<CodeInfo__c> selectByApexClassNameWithClassLinks(set<string> fileNameSet);
    list<CodeInfo__c> selectAll();
}