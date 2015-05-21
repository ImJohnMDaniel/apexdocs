public with sharing class FileViewController
{
    public static final string PARAM_ID = 'id';
    public static final string PARAM_NAME = 'name';
    public static final string PARAM_CODE_INFO_REFRESH = 'codeInfoRefresh';

    public boolean isFileViewable
    {
    	get
    	{
    		return model != null;
    	}
    }

    public list<IFile> getAvailableClasses()
    {
        return ApexDocsService.findAllFiles();
    }

    public ApexConstructBaseModel model { get; private set; }

    public IApexFileInfo apexFileInfo
    {
        get
        {
            return model instanceOf IApexFileInfo ? (IApexFileInfo)model : null;
        }
    }

    public IFile fileable
    {
        get
        {
            return model instanceOf IFile ? (IFile)model : null;
        }
    }

    public IApexModel apexModelable
    {
        get
        {
            return model instanceOf IApexModel ? (IApexModel)model : null;
        }
    }

    public IMethods methodsable
    {
        get
        {
            return model instanceOf IMethods ? (IMethods)model : null;
        }
    }

    public IProperties propertiesable
    {
        get
        {
            return model instanceOf IProperties ? (IProperties)model : null;
        }
    }

    public IConstructors constructorsable
    {
        get
        {
            return model instanceOf IConstructors ? (IConstructors)model : null;
        }
    }

    public IAuthorable authorable
    {
        get
        {
            return model instanceOf IAuthorable ? (IAuthorable)model : null;
        }
    }

    public IInnerClasses innerClassesable
    {
        get
        {
            return model instanceOf IInnerClasses ? (IInnerClasses)model : null;
        }
    }

    public IExtensible extensible
    {
        get
        {
            return model instanceOf IExtensible ? (IExtensible)model : null;
        }
    }

    public IImplementable implementable
    {
        get
        {
            return model instanceOf IImplementable ? (IImplementable)model : null;
        }
    }

    private void initialize(final string fileName)
    {
        system.debug('fileName == '+fileName);
        if ( fileName != null )
        {
        	try
        	{
                model = (ApexConstructBaseModel) ApexDocsService.getClass(fileName);

                if (ApexPages.currentPage().getParameters().containsKey( PARAM_CODE_INFO_REFRESH.toLowerCase() ))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, fileName + ' documentation has been refreshed.'));
                }
        	}
        	catch (ApexDocsServiceException adse)
        	{
        		system.debug(adse);
        		system.debug(adse.getCause() == null ? adse.getMessage() : adse.getCause().getMessage());
        		ApexPages.addMessages(adse);
        	}
        }
    }

    private void initialize(final id fileId)
    {
        system.debug('fileId == '+fileId);
        if ( fileId != null )
        {
        	try
        	{
                model = (ApexConstructBaseModel) ApexDocsService.getClass(fileId);
        	}
        	catch (ApexDocsServiceException adse)
        	{
        		system.debug(adse);
        		system.debug(adse.getCause() == null ? adse.getMessage() : adse.getCause().getMessage());
        		ApexPages.addMessages(adse);
        	}
        }
    }

    public FileViewController()
    {
        string nameParam = (string) ApexPages.currentPage().getParameters().get(PARAM_NAME);

        if ( string.isBlank(nameParam) )
        {
            string idParam = (string) ApexPages.currentPage().getParameters().get(PARAM_ID);

            if ( string.isNotBlank(idParam) )
            {
                initialize( id.valueOf(idParam) );
            }
        }
        else
        {
            initialize(nameParam);
        }

        system.debug('model == '+model);

        if ( model != null && string.isNotBlank( ((IFile)model).getId() ) )
        {
            if ( ((IFile)model).getIsInterface() )
            {
                knownImplementors.addAll( ApexDocsService.findKnownImplementorsForFile((IFile)model) );
            }
            else
            {
                knownSubClasses.addAll( ApexDocsService.findKnownSubClassesForFile((IFile)model) );
            }
        }
    }

    public FileViewController(ApexPages.StandardController stdController)
    {
        string nameParam = (string) ApexPages.currentPage().getParameters().get(PARAM_NAME);

        system.debug('nameParam == '+nameParam);

        if ( string.isBlank(nameParam) )
        {
            string idParam = (string) ApexPages.currentPage().getParameters().get(PARAM_ID);

            system.debug('idParam == '+idParam);

            if ( string.isNotBlank(idParam) )
            {
                initialize( id.valueOf(idParam) );
            }
        }
        else
        {
            initialize(nameParam);
        }

        system.debug('model == '+model);

        if ( model != null && string.isNotBlank( ((IFile)model).getId() ) )
        {
            if ( ((IFile)model).getIsInterface() )
            {
                knownImplementors.addAll( ApexDocsService.findKnownImplementorsForFile((IFile)model) );
            }
            else
            {
                if ( ((ClassModel)model).getIsException() )
                {
                    knownThrowersOfException.addAll( ApexDocsService.findKnownThrowersOfExceptionForFile((IFile)model) );
                }
                knownSubClasses.addAll( ApexDocsService.findKnownSubClassesForFile((IFile)model) );
            }
        }
    }

    public list<ClassLinkModel> knownSubClasses { get; private set; } { knownSubClasses = new list<ClassLinkModel>(); }
    public list<ClassLinkModel> knownImplementors { get; private set; } { knownImplementors = new list<ClassLinkModel>(); }
    public list<ClassLinkModel> knownThrowersOfException { get; private set; } { knownThrowersOfException = new list<ClassLinkModel>(); }

    public PageReference refreshDocumentation()
    {
        system.debug(((IFile)model).getId());
        ApexDocsService.document(((IFile)model));

        PageReference nextPage = ApexPages.currentPage();

        nextPage.getParameters().put(PARAM_NAME, ((IFile)model).getName() );
        nextPage.getParameters().put(PARAM_CODE_INFO_REFRESH, 'true' );
        nextPage.setRedirect(true);

        return nextPage;
    }

    public void refreshAll()
    {
        ApexDocsService.documentAll();
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'All Apex code has been documented.'));
    }
}