public with sharing class BigClassWtihTwoInterfaces {

    /**
     *  Notice this interface extends a parent interface but the
     *  the actual extends statement is on the next line.  This should
     *  prove to be a good test of the Apex parser.
     */
    public interface IInnerClassAccountsSelector
        extends fflib_ISObjectSelector
    {
        list<Account> selectById(set<id> idSet);
        list<Account> selectById(set<string> idStringSet);
    }

    /**
     *  Notice this interface extends a parent interface but the
     *  the actual extends statement is on the next line.  This should
     *  prove to be a good test of the Apex parser.
     */
    public interface IInnerClassContactsSelector
        extends fflib_ISObjectSelector
    {
        list<Account> selectById(set<id> idSet);
        list<Account> selectById(set<string> idStringSet);
    }


}