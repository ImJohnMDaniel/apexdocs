/**
 *  Service to handle all processing requests for the ApexDocs application. This class is responsible
 *      for parsing the Apex Class and organizing the information
 *      for display in the "docs" section.
 *  @author John M. Daniel
 * @date 7 MARCH 2015
 * @see ClassModel
 * @see IFile
 * @see MethodModel
 * @see PropertyModel
 * @since 1.0
 * @version 1.0
 */
public with sharing class ApexDocsServiceImpl
    implements IApexDocsService
{
    public ApexDocsServiceImpl()
    {

    }

    private IFile assembleModel( final CodeInfo__c codeInfo )
    {
        IFile model = ApexDocModelCompositeTransformer.convertSObjectToDomainModel( codeInfo );

        list<ClassLink__c> classLinkRecords = ClassLinksSelector.newInstance().selectByApexClassNameParent( new set<string>{ model.getName() } );

        list<ApexClass> apexClasses = ApexClassesSelector.newInstance().selectById( new set<id>{ model.getApexFileId() } );

        if ( ! apexClasses.isEmpty()
            && ( model instanceOf IApexFileInfo
                || model instanceOf IOuterClassible
                )
            )
        {
            ApexClass apexClassToCheck = null;
            IFile modelToCheck = null;

            if (model instanceOf IOuterClassible)
            {
                ClassLinkModel outerClassLinkModel = ((IOuterClassible)model).getOuterClass();

                String outerClassInfoRecord = outerClassLinkModel.getName();

                list<CodeInfo__c> codeInfos = CodeInfosSelector.newInstance().selectByApexClassName( new set<string>{ outerClassInfoRecord } );
    
                IFile outerClassModel = ApexDocModelCompositeTransformer.convertSObjectToDomainModel( codeInfos[0] );

                list<ApexClass> outerApexClasses = ApexClassesSelector.newInstance().selectById( new set<id>{ outerClassModel.getApexFileId() } );

                apexClassToCheck = outerApexClasses[0];

                modelToCheck = outerClassModel;
            }
            else
            {
                apexClassToCheck = apexClasses[0];

                modelToCheck = model;
            }

            if (apexClassToCheck.lastmodifieddate == ((IApexFileInfo)modelToCheck).getApexFileLastModifiedDate())
            {
                model.setIsModelCurrent(true);
            }
        }

        if (model instanceOf IImplementable)
        {
            ((IImplementable)model).getInterfacesImplemented().clear();
        }

        if (model instanceOf ISees)
        {
            ((ISees)model).getSees().clear();
        }

        if (model instanceOf IInnerClasses)
        {
            ((IInnerClasses)model).getInnerClasses().clear();
        }

        if (model instanceOf IDescriptionLinks)
        {
            ((IDescriptionLinks)model).getDescriptionLinks().clear();
        }

        for (ClassLink__c classLinkRecord : classLinkRecords)
        {
            if (ClassLinkModel.ClassLinkTypes.EXTENDING.name().equalsIgnoreCase( classLinkRecord.Type__c )
                && model instanceOf IExtensible
                )
            {
                ((IExtensible)model).setExtends( ApexDocModelCompositeTransformer.createClassLinkModel( classLinkRecord ) );
            }

            if (ClassLinkModel.ClassLinkTypes.IMPLEMENTING.name().equalsIgnoreCase( classLinkRecord.Type__c )
                && model instanceOf IImplementable
                )
            {
                ((IImplementable)model).getInterfacesImplemented().add( ApexDocModelCompositeTransformer.createClassLinkModel( classLinkRecord ) );
            }

            if (ClassLinkModel.ClassLinkTypes.SEEING.name().equalsIgnoreCase( classLinkRecord.Type__c )
                && model instanceOf ISees
                )
            {
                ((ISees)model).getSees().add( ApexDocModelCompositeTransformer.createClassLinkModel( classLinkRecord ) );
            }

            if (ClassLinkModel.ClassLinkTypes.DESCRIPTION.name().equalsIgnoreCase( classLinkRecord.Type__c )
                && model instanceOf IDescriptionLinks
                )
            {
                ((IDescriptionLinks)model).getDescriptionLinks().add( ApexDocModelCompositeTransformer.createClassLinkModel( classLinkRecord ) );
            }

            if (ClassLinkModel.ClassLinkTypes.THROWING.name().equalsIgnoreCase( classLinkRecord.Type__c )
                && model instanceOf IThrows
                )
            {
                ((IThrows)model).getThrows().add( ApexDocModelCompositeTransformer.createClassLinkModel( classLinkRecord ) );
            }

            if (ClassLinkModel.ClassLinkTypes.OUTERCLASS.name().equalsIgnoreCase( classLinkRecord.Type__c )
                && model instanceOf IOuterClassible
                )
            {
                ((IOuterClassible)model).setOuterClass( ApexDocModelCompositeTransformer.createClassLinkModel( classLinkRecord ) );
            }

            if (ClassLinkModel.ClassLinkTypes.INNERCLASS.name().equalsIgnoreCase( classLinkRecord.Type__c )
                && model instanceOf IInnerClasses
                )
            {
                ((IInnerClasses)model).getInnerClasses().add( ApexDocModelCompositeTransformer.createClassLinkModel( classLinkRecord ) );
            }
        }

        if (model instanceOf IMethods
            && ((IMethods)model).getMethods() != null
            && ! ((IMethods)model).getMethods().isEmpty()
            )
        {
            for (MethodModel method : ((IMethods)model).getMethods())
            {
                ((IThrows)method).getThrows().clear();

                ((ISees)method).getSees().clear();

                ((IDescriptionLinks)method).getDescriptionLinks().clear();

                for (ClassLink__c classLinkRecord : classLinkRecords)
                {
					if (ClassLinkModel.ClassLinkTypes.THROWING.name().equalsIgnoreCase( classLinkRecord.Type__c )
					    && method.getNameLine().equalsIgnoreCase( classLinkRecord.RelatedConstruct__c )
					    )
					{
					    ((IThrows)method).getThrows().add( ApexDocModelCompositeTransformer.createClassLinkModel( classLinkRecord ) );
					}

					if (ClassLinkModel.ClassLinkTypes.SEEING.name().equalsIgnoreCase( classLinkRecord.Type__c )
					    && method.getNameLine().equalsIgnoreCase( classLinkRecord.RelatedConstruct__c )
					    )
					{
					    ((ISees)method).getSees().add( ApexDocModelCompositeTransformer.createClassLinkModel( classLinkRecord ) );
					}

					if (ClassLinkModel.ClassLinkTypes.DESCRIPTION.name().equalsIgnoreCase( classLinkRecord.Type__c )
					    && method.getNameLine().equalsIgnoreCase( classLinkRecord.RelatedConstruct__c )
					    )
					{
					    ((IDescriptionLinks)method).getDescriptionLinks().add( ApexDocModelCompositeTransformer.createClassLinkModel( classLinkRecord ) );
                    }
                }
            }
        }

        return model;
    }

//    // For now, I am commenting out this code.  It is a good idea, but fails because this method
//    //  could be called in the constructor of the FileViewController.  When that happens, an
//    //  exception is thrown -- "DML currently not allowed" -- and DML is not allowed at that point.
//    private void verifyModelIsUpToDate(IFile model)
//    {
//        if (model instanceOf IApexFileInfo)
//        {
//            // find the ApexClass
//            list<ApexClass> classes = ApexClassesSelector.newInstance().selectById( new set<id>{ model.getApexFileId() } );
//
//            // Compare the last modified dates between the two.
//            if ( ! classes.isEmpty()
//                && ((IApexFileInfo)model).getApexFileLastModifiedDate() != classes[0].lastModifiedDate )
//            {
//                // the code info model is out of date and needs to be updated before continuing.
//                model = document(model);
//            }
//        }
//    }

    /**
     *  @throw ApexDocsServiceException
     */
    public IFile getClass(final id classId)
    {
    	if (classId == null)
        {
            throw new ApexDocsServiceException('The id must be specified.');
        }

        list<CodeInfo__c> codeInfos = CodeInfosSelector.newInstance().selectById( new set<Id>{ classId } );

        iFile model = assembleModel( codeInfos[0] );

        // Commented out for now.  See comments elsewhere in this class about the verifyModelIsUpToDate(IFile) method
        //verifyModelIsUpToDate(model);

        return model;
    }

    /**
     *  This method will get the full model (either ClassModel or InterfaceModel) based on the name supplied.
     *
     *  @throws ApexDocsServiceException
     *  @see ApexDocsServiceException
     *  @param className - the name of the Apex class desired.
     */
    public IFile getClass(final string className)
    {
        if (className == null)
        {
            throw new ApexDocsServiceException('The className must be specified.');
        }

        list<CodeInfo__c> codeInfos = CodeInfosSelector.newInstance().selectByApexClassName( new set<String>{ className } );

        iFile model = assembleModel( codeInfos[0] );

        // Commented out for now.  See comments elsewhere in this class about the verifyModelIsUpToDate(IFile) method
        //verifyModelIsUpToDate(model);

        return model;
    }

    public list<IFile> findAllFiles()
    {
        final list<IFile> files = new list<IFile>();

        for (CodeInfo__c obj : CodeInfosSelector.newInstance().selectAll())
        {
            files.add(new FileModel(obj.id, obj.FileName__c, Type.forName(obj.ModelType__c), obj.ApexClassId__c));
        }

        return files;
    }

    public list<ClassLinkModel> findKnownSubClassesForFile(final IFile model)
    {
        list<ClassLinkModel> models = new list<ClassLinkModel>();

        for ( ClassLink__c aClassLink : ClassLinksSelector.newInstance().selectByLinkTo(model.getId()))
        {
            if ( ClassLinkModel.ClassLinkTypes.EXTENDING.name() == aClassLink.Type__c )
            {
                models.add(ApexDocModelCompositeTransformer.createClassLinkModel(aClassLink));
            }
        }

        return models;
    }

    public list<ClassLinkModel> findKnownImplementorsForFile(final IFile model)
    {
        list<ClassLinkModel> models = new list<ClassLinkModel>();

        for ( ClassLink__c aClassLink : ClassLinksSelector.newInstance().selectByLinkTo(model.getId()))
        {
            if ( ClassLinkModel.ClassLinkTypes.IMPLEMENTING.name() == aClassLink.Type__c )
            {
                models.add(ApexDocModelCompositeTransformer.createClassLinkModel(aClassLink));
            }
        }

        return models;
    }

    public list<ClassLinkModel> findKnownThrowersOfExceptionForFile(final IFile model)
    {
        list<ClassLinkModel> models = new list<ClassLinkModel>();

        set<string> classesThrowingThisException = new set<string>();

        for ( ClassLink__c aClassLink : ClassLinksSelector.newInstance().selectByLinkTo(model.getId()))
        {
            if ( ClassLinkModel.ClassLinkTypes.THROWING.name() == aClassLink.Type__c
                && ! classesThrowingThisException.contains( aClassLink.CodeInfoName__c ))
            {
                models.add(ApexDocModelCompositeTransformer.createClassLinkModel(aClassLink));

                classesThrowingThisException.add( aClassLink.CodeInfoName__c );
            }
        }

        return models;
    }

    public void documentAll()
    {
        CodeDocumenter.documentApexFiles(ApexClassesSelector.newInstance().selectAll());
    }

    public IFile document(final ApexClass clazz)
    {
        return CodeDocumenter.documentApexFile( clazz );
    }

    public IFile document(final IFile model)
    {
        IFile outputModel = null;

        list<ApexClass> classes = ApexClassesSelector.newInstance().selectById( new set<id>{model.getApexFileId()} );

        if ( ! classes.isEmpty() )
        {
            outputModel = CodeDocumenter.documentApexFile( classes[0] );
        }

    	return outputModel;
    }

	public void initializeEnvironment()
	{
		initializePushTopic();
	}

	private void initializePushTopic()
	{
		delete [select id from PushTopic where name = 'CodeInfoUpdates'];

		PushTopic pt = new PushTopic();

		pt.name = 'CodeInfoUpdates';
		// TODO: switch this assignment of the PushTopic.query to use the selector instead once the framework is updated.
		pt.query = 'select Id, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, ap3xdocs__ApexClassId__c, ap3xdocs__Filename__c, ap3xdocs__ModelType__c from ap3xdocs__CodeInfo__c';
		pt.ApiVersion = 39.0;
		pt.isActive = true;
		pt.NotifyForFields = 'All';
		//pt.NotifyForOperations = 'All';
		pt.Description = '';
		pt.NotifyForOperationCreate = true;
		pt.NotifyForOperationUpdate = true;
		pt.NotifyForOperationDelete = true;
		pt.NotifyForOperationUndelete = true;

		insert pt;
	}

    public void reset()
    {
        delete [select id from CodeInfo__c];
    }
}