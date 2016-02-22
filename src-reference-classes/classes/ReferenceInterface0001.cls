public interface ReferenceInterface0001 extends fflib_ISObjectSelector {
    list<Account> selectById(set<id> idSet);
    list<Account> selectById(set<string> idStringSet);
    list<Account> selectByOwnerIdAndAccountSource(final set<id> ownerId, final string accountSource);
    list<Account> selectByParent(list<Account> parentRecords);
    list<Account> selectByRoot(list<Account> rootCategorizationRecords);
    list<Account> selectAll();
    list<Account> selectAllRootHierarchyNodes();

}