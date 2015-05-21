public interface IApexClassesSelector
    extends fflib_ISObjectSelector
{
    list<ApexClass> selectById(set<ID> idSet);
    list<ApexClass> selectByName(set<String> nameSet);
    string selectAllQuery();
    list<ApexClass> selectAll();
}