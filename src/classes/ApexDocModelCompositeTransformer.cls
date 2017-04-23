public class ApexDocModelCompositeTransformer
{
    public static ClassLinkModel createClassLinkModel(final ClassLink__c input)
    {
        ClassLinkModel output = new ClassLinkModel(ClassLinkModel.getTypeByName(input.Type__c), input.linksToName__c);

        output.setUrl( input.LinksTo__c == null ? input.CoreApexLink__c : '/'+input.LinksTo__c ) ;

        output.setFromUrl( '/' + input.CodeInfo__c);
        output.setFromName( input.CodeInfoName__c);

        return output;
    }

    public static ClassLink__c createClassLinkRecord(final ClassLinkModel input)
    {
        ClassLink__c classLinkRecord = new ClassLink__c();

        classLinkRecord.Type__c = input.getLinkType().name();
        classLinkRecord.LinksToName__c = input.getName();
        classLinkRecord.CoreApexLink__c = input.getUrl();

        return classLinkRecord;
    }

    public static list<ClassLink__c> createClassLinkRecords(final list<ClassLinkModel> input)
    {
        list<ClassLink__c> output = new list<ClassLink__c>();

        for (ClassLinkModel model : input)
        {
            output.add( createClassLinkRecord(model) );
        }

        return output;
    }

    public static list<ClassLink__c> createClassLinkRecords(final list<ClassLinkModel> input, final string apexConstructName)
    {
        list<ClassLink__c> output = new list<ClassLink__c>();

        ClassLink__c classLink = null;

        for (ClassLinkModel model : input)
        {
            classLink = createClassLinkRecord(model);
            classLink.RelatedConstruct__c = apexConstructName;
            output.add( classLink );
        }

        return output;
    }

    public static IFile convertSObjectToDomainModel(final CodeInfo__c input)
    {
        IFile output = null;

        if ( input != null )
        {
            try
            {
                Type modelType = Type.forName( input.ModelType__c );
    
                output = (IFile)JSON.deserialize( input.Json__c, modelType );
    
                output.setId(input.id);
            }
            catch (System.SObjectException soe)
            {
                throw new ApexDocModelCompositeTransformer.ApexDocModelTransformerException('The current Model Type for record id is not the correct type.');
            }            
        }

        return output;
    }

    public static CodeInfo__c convertDomainModelToSObject(final IFile input)
    {
        CodeInfo__c output = new CodeInfo__c();

        output.filename__c = input.getName();

        if (input instanceOf FileModel)
        {
            output.ModelType__c = ClassModel.class.getName();
        }
        else
        {
            output.ModelType__c = ((ApexConstructBaseModel)input).getClassType().getName();
        }

        output.ApexClassId__c = input.getApexFileId();
        
        if ( input instanceOf ApexConstructBaseModel )
        {
            output.JSON__c = JSON.serialize( (ApexConstructBaseModel)input );
        }

        return output;
    }

    /**
     *  @description This is the standard exception that will be thrown by the
     *      ApexDocModelCompositeTransformer class
     *  @since 1.0
     */
    public class ApexDocModelTransformerException extends Exception {}
}