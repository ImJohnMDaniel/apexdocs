public interface IAttachmentsSelector
    extends fflib_ISObjectSelector
{
    list<Attachment> selectById(set<ID> idSet);
    list<Attachment> selectByApexClassNameParent(set<string> parentApexClassNameSet);
    list<Attachment> selectByApexClassNameParent(set<id> parentCodeInfoIdSet);
}