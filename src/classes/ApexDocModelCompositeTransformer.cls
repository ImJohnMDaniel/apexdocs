public class ApexDocModelCompositeTransformer
{
/*
    // TODO: Need to change the param "theType" to something more "type safe" than just a string.
    private static CodeInfoExtra__c createCodeInfoExtraRecord(final string theType, final string value)
    {
        CodeInfoExtra__c codeInfoExtraRecord = new CodeInfoExtra__c();
        codeInfoExtraRecord.Type__c = theType;
        codeInfoExtraRecord.Value__c = value;
        system.debug('codeInfoExtraRecord == '+codeInfoExtraRecord);
        return codeInfoExtraRecord;
    }
*/
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

        try
        {
            Type theModelType = Type.forName(input.ModelType__c);

            //output = (IFile)JSON.deserialize(input.AggregateInfo__c, theModelType);
        }
        catch (System.SObjectException soe)
        {
            throw new ApexDocModelCompositeTransformer.ApexDocModelTransformerException('The current Model Type for record id is not the correct type.');
        }

        //output.setName(input.filename__c);
        //output.setApexFileId(input.ApexClassId__c);

        return output;

    }

    public static IFile convertJSONStringToDomainModel(final String input)
    {
        IFile output = null;

        return output;
    }

    public static IFile convertAttachmentToDomainModel(final Attachment input)
    {
        IFile output = null;

        try
        {
            // grab the first line of the string in order to determine the Model Type
            string jsonContent = input.body.toString();
            system.debug(jsonContent);

            list<string> headerAndBody = jsonContent.split(HEADER_BODY_SEPARATOR);
            string headerInfo = headerAndBody[0];
            system.debug(headerInfo);

            map<string, object> headInfoMap = (map<string, object>)JSON.deserializeUntyped(headerInfo);

            string modelData = headerAndBody[1];

            Type modelType = Type.forName((string)headInfoMap.get(MODEL_TYPE));

            output = (IFile)JSON.deserialize(modelData, modelType);

            output.setId(input.ParentId);

            output.setCodeInfoAttachmentId(input.id);
        }
        catch (System.SObjectException soe)
        {
            throw new ApexDocModelCompositeTransformer.ApexDocModelTransformerException('The current Model Type for record id is not the correct type.');
        }

        return output;
    }

    private static final string MODEL_TYPE = 'MODEL_TYPE';
    private static final string HEADER_BODY_SEPARATOR = '\n\n\n';

    public static Attachment convertDomainModelToAttachment(final IFile input)
    {
    	string modelType = ((ApexConstructBaseModel)input).getClassType().getName();

    	map<string, string> headerInfo = new map<string, string>();

    	headerInfo.put(MODEL_TYPE, modelType);

    	string fullPayload = JSON.serialize(headerInfo) + HEADER_BODY_SEPARATOR + JSON.serialize(input);
    	system.debug(fullPayload);

    	Attachment attach = new Attachment();
        attach.body = Blob.valueOf(fullPayload);
        attach.ContentType = 'application/json';
        attach.name = ApexDocsUtils.getApexDocsFileName(input.getName());
        attach.Description = modelType;

    	return attach;
    }

    public static CodeInfo__c convertDomainModelToSObject(final IFile input)
    {
        CodeInfo__c output = new CodeInfo__c();

//        if (input instanceOf IOuterClassible)
//        {
//            // account for the outer class name
//            output.filename__c = ((IOuterClassible)input).getOuterClass().getName() + '.' + input.getName();
//        }
//        else
//        {
            output.filename__c = input.getName();
//        }

        if (input instanceOf FileModel)
        {
            output.ModelType__c = ClassModel.class.getName();
        }
        else
        {
            output.ModelType__c = ((ApexConstructBaseModel)input).getClassType().getName();
        }

        output.ApexClassId__c = input.getApexFileId();

        return output;
    }

    /**
     *  @description This is the standard exception that will be thrown by the
     *      ApexDocModelCompositeTransformer class
     *  @since 1.0
     */
    public class ApexDocModelTransformerException extends Exception {}


}