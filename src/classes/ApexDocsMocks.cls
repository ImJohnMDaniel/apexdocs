@isTest
public class ApexDocsMocks
{
    public class ApexClassesSelector implements IApexClassesSelector
    {
        private fflib_ApexMocks mocks;

        public ApexClassesSelector(fflib_ApexMocks mocks)
		{
			this.mocks = mocks;
		}

        public list<ApexClass> selectById(set<ID> idSet)
        {
            return (list<ApexClass>) mocks.mockNonVoidMethod(this, 'selectById', new List<Object>{idSet});
        }

        public list<ApexClass> selectByName(set<String> nameSet)
        {
            return (list<ApexClass>) mocks.mockNonVoidMethod(this, 'selectByName', new List<Object>{nameSet});
        }

        public string selectAllQuery()
        {
            return (string) mocks.mockNonVoidMethod(this, 'selectAllQuery', new List<Object>{});
        }

        public list<ApexClass> selectAll()
        {
            return (list<ApexClass>) mocks.mockNonVoidMethod(this, 'selectAll', new List<Object>{});
        }

        public list<Schema.FieldSet> getSObjectFieldSetList()
		{
			return (list<Schema.FieldSet>) mocks.mockNonVoidMethod(this, 'getSObjectFieldSetList', new List<Object>{});
		}

		public List<SObject> selectSObjectsById(Set<Id> idSet)
		{
			return (List<SObject>) mocks.mockNonVoidMethod(this, 'selectSObjectsById', new List<Object>{idSet});
		}

		public Schema.SObjectType sObjectType()
		{
			return ApexClass.sObjectType;
		}
    }

    public class CodeInfosSelector implements ICodeInfosSelector
    {
        private fflib_ApexMocks mocks;

        public CodeInfosSelector(fflib_ApexMocks mocks)
		{
			this.mocks = mocks;
		}

        public list<CodeInfo__c> selectById(set<ID> idSet)
        {
            return (list<CodeInfo__c>) mocks.mockNonVoidMethod(this, 'selectById', new List<Object>{ idSet });
        }

        public list<CodeInfo__c> selectByApexClassNameWithClassLinks(set<string> fileNameSet)
        {
            return (list<CodeInfo__c>) mocks.mockNonVoidMethod(this, 'selectByApexClassNameWithClassLinks', new List<Object>{ fileNameSet });
        }

        public list<CodeInfo__c> selectAll()
        {
            return (list<CodeInfo__c>) mocks.mockNonVoidMethod(this, 'selectAll', new List<Object>{});
        }

        public list<CodeInfo__c> selectByModelType(final set<string> modelTypes)
        {
            return (list<CodeInfo__c>) mocks.mockNonVoidMethod(this, 'selectByModelType', new List<Object>{ modelTypes });
        }

        public list<Schema.FieldSet> getSObjectFieldSetList()
		{
			return (list<Schema.FieldSet>) mocks.mockNonVoidMethod(this, 'getSObjectFieldSetList', new List<Object>{});
		}

		public List<SObject> selectSObjectsById(Set<Id> idSet)
		{
			return (List<SObject>) mocks.mockNonVoidMethod(this, 'selectSObjectsById', new List<Object>{idSet});
		}

		public Schema.SObjectType sObjectType()
		{
			return CodeInfo__c.sObjectType;
		}
    }

    public class ClassLinksSelector implements IClassLinksSelector
    {
        private fflib_ApexMocks mocks;

        public ClassLinksSelector(fflib_ApexMocks mocks)
		{
			this.mocks = mocks;
		}

        public list<ClassLink__c> selectById(set<ID> idSet)
        {
            return (list<ClassLink__c>) mocks.mockNonVoidMethod(this, 'selectById', new List<Object>{idSet});
        }

        public list<ClassLink__c> selectByLinksNotResolved()
        {
            return (list<ClassLink__c>) mocks.mockNonVoidMethod(this, 'selectByLinksNotResolved', new List<Object>{});
        }

        public list<ClassLink__c> selectByLinkTo(final id linkToId)
        {
            return (list<ClassLink__c>) mocks.mockNonVoidMethod(this, 'selectByLinkTo', new List<Object>{linkToId});
        }

        public list<ClassLink__c> selectByApexClassNameParent(final set<string> fileNameSet)
        {
            return (list<ClassLink__c>) mocks.mockNonVoidMethod(this, 'selectByApexClassNameParent', new List<Object>{fileNameSet});
        }

        public list<Schema.FieldSet> getSObjectFieldSetList()
		{
			return (list<Schema.FieldSet>) mocks.mockNonVoidMethod(this, 'getSObjectFieldSetList', new List<Object>{});
		}

		public List<SObject> selectSObjectsById(Set<Id> idSet)
		{
			return (List<SObject>) mocks.mockNonVoidMethod(this, 'selectSObjectsById', new List<Object>{idSet});
		}

		public Schema.SObjectType sObjectType()
		{
			return ClassLink__c.sObjectType;
		}
    }

    public class AttachmentsSelector implements IAttachmentsSelector
    {
        private fflib_ApexMocks mocks;

        public AttachmentsSelector(fflib_ApexMocks mocks)
        {
            this.mocks = mocks;
        }

        public list<Attachment> selectById(set<ID> idSet)
        {
            return (list<Attachment>) mocks.mockNonVoidMethod(this, 'selectById', new List<Object>{idSet});
        }

        public list<Attachment> selectByApexClassNameParent(set<string> parentApexClassNameSet)
        {
            return (list<Attachment>) mocks.mockNonVoidMethod(this, 'selectByApexClassNameParent', new List<Object>{parentApexClassNameSet});
        }

        public list<Attachment> selectByApexClassNameParent(set<id> parentCodeInfoIdSet)
        {
            return (list<Attachment>) mocks.mockNonVoidMethod(this, 'selectByApexClassNameParent', new List<Object>{parentCodeInfoIdSet});
        }

        public list<Schema.FieldSet> getSObjectFieldSetList()
        {
            return (list<Schema.FieldSet>) mocks.mockNonVoidMethod(this, 'getSObjectFieldSetList', new List<Object>{});
        }

        public List<SObject> selectSObjectsById(Set<Id> idSet)
        {
            return (List<SObject>) mocks.mockNonVoidMethod(this, 'selectSObjectsById', new List<Object>{idSet});
        }

        public Schema.SObjectType sObjectType()
        {
            return Attachment.sObjectType;
        }
    }

    public class ApexDocsService implements IApexDocsService
    {
        private fflib_ApexMocks mocks;

		public ApexDocsService(fflib_ApexMocks mocks)
		{
			this.mocks = mocks;
		}

        public IFile getClass(final id classId)
        {
            return (IFile) mocks.mockNonVoidMethod(this, 'getClass', new List<Object>{ classId });
        }

        public IFile getClass(final string className)
        {
            return (IFile) mocks.mockNonVoidMethod(this, 'getClass', new List<Object>{ className });
        }

        public list<IFile> findAllFiles()
        {
            return (list<IFile>) mocks.mockNonVoidMethod(this, 'findAllFiles', new List<Object>{});
        }

        public list<ClassLinkModel> findKnownSubClassesForFile(final IFile model)
        {
            return (list<ClassLinkModel>) mocks.mockNonVoidMethod(this, 'findKnownSubClassesForFile', new List<Object>{ model });
        }

        public list<ClassLinkModel> findKnownImplementorsForFile(final IFile model)
        {
            return (list<ClassLinkModel>) mocks.mockNonVoidMethod(this, 'findKnownImplementorsForFile', new List<Object>{ model });
        }

        public list<ClassLinkModel> findKnownThrowersOfExceptionForFile(final IFile model)
        {
            return (list<ClassLinkModel>) mocks.mockNonVoidMethod(this, 'findKnownThrowersOfExceptionForFile', new List<Object>{ model });
        }

        public void documentAll()
        {
            mocks.mockVoidMethod(this, 'documentAll', new List<Object>{});
        }

        public IFile document(final ApexClass clazz)
        {
            return (IFile) mocks.mockNonVoidMethod(this, 'document', new List<Object>{ clazz });
        }

        public IFile document(final IFile model)
        {
            return (IFile) mocks.mockNonVoidMethod(this, 'document', new List<Object>{ model });
        }

        public void reset()
        {
            mocks.mockVoidMethod(this, 'reset', new List<Object>{  });
        }

    }

}