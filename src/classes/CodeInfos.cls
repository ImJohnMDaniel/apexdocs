/**
 *  A domain model for the CodeInfo__c SObject
 *
 * @see fflib_SObjectDomain
 * @since 1.0
 * @date 21 MAY 2015
 * @version 1.0
 * @author John M. Daniel
 *
 */
public with sharing class CodeInfos extends fflib_SObjectDomain
    implements ICodeInfos
{
    /**
     * Primary constructor for CodeInfos class.
     * @param list<CodeInfo__c> - the records to initialize with.
     */
    public CodeInfos(List<CodeInfo__c> sObjectList)
    {
        // Domain classes are initialised with lists to enforce bulkification throughout
        super(sObjectList);
    }

    /**
     *  SObjectDomain IConstructable
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new CodeInfos(sObjectList);
        }
    }

}