/**
 * Class encapsulates query logic for Attachment
 *
 * https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Selector_Layer
 **/
public class AttachmentsSelector
	extends fflib_SObjectSelector
	implements IAttachmentsSelector
{
    public static IAttachmentsSelector newInstance()
    {
        return (IAttachmentsSelector) Application.Selector.newInstance(Attachment.SObjectType);
    }

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
				Attachment.Id,
				Attachment.IsDeleted,
				Attachment.ParentId,
				Attachment.Name,
				Attachment.IsPrivate,
				Attachment.ContentType,
				Attachment.BodyLength,
				// This field cannot be included by default because when Attachments are included in other
				// queries as a sub-select, SOQL does not allow binary fields in sub-selects
				// Attachment.Body,
				Attachment.OwnerId,
				Attachment.CreatedDate,
				Attachment.CreatedById,
				Attachment.LastModifiedDate,
				Attachment.LastModifiedById,
				Attachment.SystemModstamp,
				Attachment.Description
			};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Attachment.sObjectType;
	}

	public List<Attachment> selectById(Set<ID> idSet)
	{
		return (List<Attachment>) selectSObjectsById(idSet);
	}

	public list<Attachment> selectByApexClassNameParent(set<string> parentApexClassNameSet)
    {
    	return Database.query( newQueryFactory().selectField(Attachment.Body)
    									.setCondition(Attachment.ParentId + ' in (select id from ' + CodeInfo__c.SObjectType
    									                                                    + ' where ' + CodeInfo__c.FileName__c + ' in :parentApexClassNameSet)')
    									.toSOQL() );
    }

	public list<Attachment> selectByApexClassNameParent(set<id> parentCodeInfoIdSet)
    {
    	return Database.query( newQueryFactory().selectField(Attachment.Body)
    									.setCondition(Attachment.ParentId + ' in :parentCodeInfoIdSet')
    									.toSOQL() );
    }
}