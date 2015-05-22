global class CodeDocumenter // implements Database.Batchable<SObject>  For Batch Mode, see note at the bottom of this class
{
    public static list<string> rgstrScope { get; set; }

    static
    {
        rgstrScope = new list<string>();

        // These next three strings are added to the list in this manner to ensure that
        // they are not accidently picked up as "methods" because they have the "scope" words
        rgstrScope.add('glo'+'bal');
        rgstrScope.add('pub'+'lic');
        rgstrScope.add('prot'+'ected');
    }

    // SObject's used by the logic in this service, listed in dependency order
    private static list<Schema.SObjectType> SERVICE_SOBJECTS =
                    new list<Schema.SObjectType>
                    {
                        CodeInfo__c.SObjectType,
                        ClassLink__c.SObjectType,
                        Attachment.SObjectType
                    };

    private static string EXTENDS_KEYWORD_STRING = ' extends ';
    private static string IMPLEMENTS_KEYWORD_STRING = ' implements ';

    private static string determineCompleteNameLine(final string strLine, final string fullFileBody)
    {
        // The "nameLine" is the complete declaration of the class or interface.
        //      It could span multiple lines.  We need to determine if the current
        //      strLine is the complete "nameLine" or do we need to include the
        //      next lines.
        //  The first thing to do is determine if the open bracket "{" is on the
        //      current line
        string nameLine = null;

        if ( strLine.containsIgnoreCase('{') )
        {
            // Then the "nameLine" is completely contained on the current strLine
            nameLine = strLine;
            system.debug('nameLine is the same as strLine');
        }
        else
        {
            // Then the "nameLine" spans the current strLine and subsequent lines.
            // In this case, the true "nameLine" is the strLine plus all subsequent
            // lines of the file.Body up to the first open bracket "{"
            nameLine = (strLine + ' ' + (fullFileBody.substringBetween(strLine,'{'))).normalizeSpace();
            system.debug('nameLine is on multiple lines');
        }

        system.debug('The NAMELINE is \n\n'+nameLine+'\n\n');

        return nameLine;
    }

    private static void fillModel ( IApexModel model, string name, list<string> lstComments )
    {
        model.setNameLine(name);
        boolean inDescription = false;
        boolean isLinkTagInCommentFound = false;
        string tagIdentified = null;
        system.debug(model);
        // system.debug( lstComments );

        for (string comment : lstComments)
        {
            comment = comment.trim();

            // system.debug( comment );

            // TODO: It might help to have a complete list of possible tags and see if the tagIdentified
            //      string matches one of the selections.
            tagIdentified = comment.substringBetween('@',' ');

            if (tagIdentified == null)
            {
                tagIdentified = comment.substringAfter('@');
            }

            if (tagIdentified != null)
            {
                tagIdentified.replace(':','');
            }
            // system.debug( comment );
            tagIdentified = tagIdentified.trim();

            if (model instanceOf IDescriptionLinks
                && tagIdentified != null
                && tagIdentified.equalsIgnoreCase('link'))
            {
                isLinkTagInCommentFound = true;
                tagIdentified = null;
            }
            else
            {
                isLinkTagInCommentFound = false;
            }

            system.debug('\n\ntagIdentified = '+tagIdentified + '\n'
                        + 'inDescription = '+inDescription + '\n'
                        + 'comment == '+comment + '\n'
                        + '\n\n');

            if ( string.isNotBlank(tagIdentified) )
            {
                tagIdentified = tagIdentified.toLowerCase();

                integer idxStart = comment.toLowerCase().indexOf(tagIdentified);

                if (idxStart != -1)
                {
                    string tagValue = null;

                    if (comment.length() > (idxStart + tagIdentified.length()))
                    {
                        tagValue = comment.substring(idxStart + tagIdentified.length() +1).trim();
                    }
                    else
                    {
                        tagValue = comment.substring(idxStart + tagIdentified.length()).trim();
                    }

                    model.set(tagIdentified, tagValue);

                    // TODO: Need to replace this string literal with a model ENUM or Interface constant or something.
                    inDescription = tagIdentified == 'description';
                }
            }
            // handle multiple lines for description.
            else
            {
                // TODO: Need to replace this string literal with a model ENUM or Interface constant or something.
                tagIdentified = 'description';
                integer i;
                for (i = 0; i < comment.length(); i++)
                {
                    string ch = comment.substring(i, i+1);
                    if (ch != '*' && ch != ' ')
                        break;
                }
                if (i < comment.length())
                {
                    //system.debug('description comment == >>'+comment.substring(i)+'<<');
                    if (model instanceOf IDescriptionLinks && isLinkTagInCommentFound)
                    {
                        string commentLineLinkTo = comment.substringBetween('{','}').replace('@link','').normalizeSpace();

                        ((IDescriptionLinks)model).addDescriptionLink(commentLineLinkTo);
                    }
                    model.set(tagIdentified, comment.substring(i));
                }
                else
                {
                    //system.debug('description comment 2 == >>'+comment+'<<');
                    model.set(tagIdentified, '<br/><br/>');
                }
            }
        }

        system.debug('\n\n\n' + model + '\n\n\n');

    }

    private static list<ClassLinkModel> findImplementedInterfacesClassLinks(final string strLine)
    {
        list<ClassLinkModel> output = new list<ClassLinkModel>();

        if (strLine.containsIgnoreCase(IMPLEMENTS_KEYWORD_STRING.trim()))
        {
            // the name(s) of the implement interface(s) should between the IMPLEMENTS_KEYWORD_STRING and the
            //     end of the string
            list<string> implementedInterfaces = strLine.substringAfter(IMPLEMENTS_KEYWORD_STRING.trim()).split(',');
            system.debug('implementedInterfaces = '+implementedInterfaces);

            if (implementedInterfaces != null)
            {
                for (string implementedInterface : implementedInterfaces)
                {
                	if (string.isNotBlank(implementedInterface))
                	{
                        output.add(new ClassLinkModel(ClassLinkModel.ClassLinkTypes.IMPLEMENTING, implementedInterface));
                	}
                }
            }
        }

        return output;
    }

    private static ClassLinkModel findExtendsClassLink(final string strLine)
    {
        ClassLinkModel output = null;

        system.debug( (strLine.containsIgnoreCase(EXTENDS_KEYWORD_STRING) ? ' found extends keyword ' : 'didn\'t find extends keyword'));
        if (strLine.containsIgnoreCase(EXTENDS_KEYWORD_STRING.trim()))
        {
            // the name of the parent class should between the EXTENDS_KEYWORD_STRING and the
            //     next space
            string parentClassName = strLine.substringBetween(EXTENDS_KEYWORD_STRING, ' ');
            system.debug('parentClassName = '+parentClassName);
            if (parentClassName == null)
            {
                // then there was no space after the parentClassName.  It was the EOL.
                // try again considering that use case
                parentClassName = strLine.substringAfter(EXTENDS_KEYWORD_STRING);
            }
            system.debug('parentClassName = '+parentClassName);
            if (parentClassName != null)
            {
                output = new ClassLinkModel(ClassLinkModel.ClassLinkTypes.EXTENDING, parentClassName);
            }
        }

        return output;
    }

    private static IFile parseApexClass(ApexClass file)
    {
        system.debug('@@@@ file.name == ' + file.name);
        try
        {
            //string strLine = null;
            //Read File Line By Line
            boolean fileParsed = false;
            boolean commentsStarted = false;
            boolean internalCommentsStarted = false;
            list<string> lstComments = new list<string>();
            //ClassModel cModel = new ClassModel();
            IFile fileModel = null;
            list<MethodModel> methods = new list<MethodModel>();
            list<PropertyModel> properties = new list<PropertyModel>();
            list<ConstructorModel> constructors = new list<ConstructorModel>();
            list<ClassModel> innerClasses = new list<ClassModel>();

            for (string strLine : file.Body.split('\n'))
            {
                system.debug('strLine == '+strLine);

                strLine = strLine.trim();

                if (strLine.length() == 0)
                    continue;

                // ignore anything after // style comments.  this allows hiding of tokens from ApexDoc.
                integer ich = strLine.indexOf('//');
                integer httpich = strLine.indexOf('://');

                if (httpich == ich -1)
                {
                    // this is not a double slash comment.  It is a http://www.... or https://www..
                    // Let this comment through.
                    ich = -1;
                }

                if (ich > -1)
                {
                    strLine = strLine.substring(0, ich);
                }

                // gather up the comments
                if (strLine.startsWith('/**'))
                {
                    commentsStarted = true;
                    lstComments.clear();
                    continue;
                }

                // determine if this is a non "documentable" comment
                if (strLine.startsWith('/*'))
                {
                    internalCommentsStarted = true;
                    lstComments.clear();
                    continue;
                }

                if (commentsStarted && strLine.endsWith('*/'))
                {
                    commentsStarted = false;
                    continue;
                }

                if (internalCommentsStarted && strLine.trim().endsWith('*/'))
                {
                    internalCommentsStarted = false;
                    continue;
                }

                if (commentsStarted)
                {
                    // system.debug( 'adding strLine : '+strLine);
                    lstComments.add(strLine);
                    continue;
                }

                if (internalCommentsStarted)
                {
                    // ignore it
                    continue;
                }

                // ignore anything after an =.  this avoids confusing properties with methods.
                ich = strLine.indexOf('=');

                if (ich > -1)
                {
                    strLine = strLine.substring(0, ich);
                }

                // ignore anything after an {.  this avoids confusing properties with methods.
                ich = strLine.indexOf('{');

                if (ich > -1)
                {
                    strLine = strLine.substring(0, ich);
                }

                system.debug('@@@ strLine = '+strLine);

                // ignore lines not dealing with scope
                if ( ! strContainsScope(strLine)
                    && ! (fileModel instanceOf InterfaceModel)
                    )
                    continue;

                // look for a class
                if ( ! fileParsed && strLine.containsIgnoreCase(' class '))
                {
                    fileParsed = true;
                    fileModel = new ClassModel();

                    string fullNameLine = determineCompleteNameLine(strLine, file.Body);

                    fillModel((IApexModel)fileModel, fullNameLine, lstComments);
                    ((ClassModel)fileModel).setApexFileId(file.id);

                    // Check to see if the class extends another class
                    if (fullNameLine.containsIgnoreCase(EXTENDS_KEYWORD_STRING.trim()))
                    {
                        ((ClassModel)fileModel).setExtends(findExtendsClassLink(fullNameLine));
                    }

                    // Check to see if the class implements an interface
                    if (fullNameLine.containsIgnoreCase(IMPLEMENTS_KEYWORD_STRING.trim()))
                    {
                        ((ClassModel)fileModel).setInterfacesImplemented(findImplementedInterfacesClassLinks(fullNameLine));
                    }

                    lstComments.clear();
                    continue;
                }

                // look for a interface
                if ( ! fileParsed
                    && strLine.containsIgnoreCase(' interface ')
                    && ! strLine.containsIgnoreCase(' class ')
                    )
                {
                    fileParsed = true;
                    fileModel = new InterfaceModel();

                    string fullNameLine = determineCompleteNameLine(strLine, file.Body);

                    fillModel((IApexModel)fileModel, fullNameLine, lstComments);
                    ((InterfaceModel)fileModel).setApexFileId(file.id);

                    // Check to see if the interface extends another interface
                    if (fullNameLine.containsIgnoreCase(EXTENDS_KEYWORD_STRING.trim()))
                    {
                        ((InterfaceModel)fileModel).setExtends(findExtendsClassLink(fullNameLine));
                    }

                    lstComments.clear();
                    continue;
                }

                // look for an inner class
                if (fileParsed
                    && fileModel instanceOf IInnerClasses
                    && strLine.containsIgnoreCase(' class '))
                {
                    system.debug('Found the inner class ... '+strLine);
                    ClassModel innerClassModel = new ClassModel();
                    fillModel(innerClassModel, strLine, lstComments);
                    innerClasses.add(innerClassModel);

                    string fullNameLine = determineCompleteNameLine(strLine, file.Body);

                    // Check to see if the class extends another class
                    if (fullNameLine.containsIgnoreCase(EXTENDS_KEYWORD_STRING.trim()))
                    {
                        innerClassModel.setExtends(findExtendsClassLink(fullNameLine));
                    }

                    // Check to see if the class implements an interface
                    if (fullNameLine.containsIgnoreCase(IMPLEMENTS_KEYWORD_STRING.trim()))
                    {
                        innerClassModel.setInterfacesImplemented(findImplementedInterfacesClassLinks(fullNameLine));
                    }

                    lstComments.clear();
                    continue;
                }

                // look for a method
                if (fileModel instanceOf IMethods
                    && strLine.containsIgnoreCase('(')
                    && ! strLine.replace(' ','').containsIgnoreCase(file.name+'(')
                    )
                {
                    //system.debug(logginglevel.error, 'fileModel is instanceOf IMethods.');
                    MethodModel mModel = new MethodModel();
                    //system.debug(logginglevel.error, '\n\nlstComments = '+lstComments+'\nstrLine = '+strLine+'\n\n');
                    fillModel(mModel, strLine, lstComments);
                    //system.debug(logginglevel.error, 'mModel == '+mModel);
                    methods.add(mModel);
                    lstComments.clear();
                    continue;
                }

                // TODO: need to handle constructors for the class
                if (fileModel instanceOf IConstructors
                    && ! strLine.containsIgnoreCase(' class ')
                    && strLine.replace(' ','').containsIgnoreCase(file.name+'(') )
                {
                    ConstructorModel constructorModel = new ConstructorModel();
                    fillModel(constructorModel, strLine, lstComments);
                    constructors.add(constructorModel);
                    lstComments.clear();
                    continue;
                }

                if (fileModel instanceOf IProperties
                    && string.isNotBlank(strLine.trim())
                    )
                {
                    // must be a property of a Class
                    PropertyModel propertyModel = new PropertyModel();
                    fillModel(propertyModel, strLine, lstComments);
                    properties.add(propertyModel);
                    lstComments.clear();
                    continue;
                }
            }

            if (fileModel instanceOf IInnerClasses)
            {
                ((IInnerClasses)fileModel).setInnerClasses(innerClasses);
            }

            if (fileModel instanceOf IMethods)
            {
                ((IMethods)fileModel).setMethods(methods);
            }

            if (fileModel instanceOf IProperties)
            {
                ((IProperties)fileModel).setProperties(properties);
            }

            if (fileModel instanceOf IConstructors)
            {
                ((IConstructors)fileModel).setConstructors(constructors);
            }

            if ( fileModel instanceOf IApexFileInfo )
            {
                ((IApexFileInfo)fileModel).setApexFileCreatedDate( file.CreatedDate );
                ((IApexFileInfo)fileModel).setApexFileCreatedById( file.CreatedById );
                ((IApexFileInfo)fileModel).setApexFileLastModifiedDate( file.LastModifiedDate );
                ((IApexFileInfo)fileModel).setApexFileLastModifiedById( file.LastModifiedById );
                try
                {
                    ((IApexFileInfo)fileModel).setApexFileCreatedByName( file.CreatedBy.Name );
                    ((IApexFileInfo)fileModel).setApexFileLastModifiedByName( file.LastModifiedBy.Name );
                }
                catch (System.SObjectException oe)
                {
                    // the name of the file creater was not queried.  move on
                }
            }

            system.debug('\n\n\n'+fileModel+'\n\n\n');

            return fileModel;
        }
        catch (Exception e) //Catch exception if any
        {
            system.debug('\n\n'+e.getStackTraceString()+'\n\n');
            System.debug('Error: '+e.getTypeName()+' : line number ' + e.getLineNumber() + ' : ' + e.getMessage());
            if (e.getCause() != null)
            {
               System.debug('Error Cause: line number ' + e.getCause().getLineNumber() + ' : ' + e.getCause().getMessage());
            }
        }
        return null;
    }

    private static void persistFileModels(final list<IFile> fileModels)
    {
        set<string> apexFileNames = new set<string>();

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(SERVICE_SOBJECTS);

        CodeInfo__c codeInfoRecord = null;

        list<CodeInfo__c> codeInfoRecordList = new list<CodeInfo__c>();
        map<string, IFile> fileModelsByClassNameMap = new map<string, IFile>();

        for (IFile fileModel : fileModels)
        {
            if ( fileModel != null && ! string.isBlank( fileModel.getName() ) )
            {
                fileModelsByClassNameMap.put( fileModel.getName(), fileModel );
            }

            system.debug(fileModel);
            if (fileModel != null)
            {
                apexFileNames.add(fileModel.getName());

                codeInfoRecord = ApexDocModelCompositeTransformer.convertDomainModelToSObject(fileModel);

                codeInfoRecordList.add( codeInfoRecord );

                uow.registerNew( codeInfoRecord );

                uow.registerNew( ApexDocModelCompositeTransformer.convertDomainModelToAttachment(fileModel)
                                , Attachment.ParentId
                                , codeInfoRecord
                                );

                if (fileModel instanceOf IExtensible && ((IExtensible)fileModel).getExtends() != null)
                {
                    uow.registerNew( ApexDocModelCompositeTransformer.createClassLinkRecord( ((IExtensible)fileModel).getExtends()  )
                                    , ClassLink__c.CodeInfo__c
                                    , codeInfoRecord
                                    );
                }

                if (fileModel instanceOf IImplementable
                    && ((IImplementable)fileModel).getInterfacesImplemented() != null
                    && ! ((IImplementable)fileModel).getInterfacesImplemented().isEmpty())
                {
                    list<ClassLink__c> classLinkRecords = ApexDocModelCompositeTransformer.createClassLinkRecords( ((IImplementable)fileModel).getInterfacesImplemented() );

                    for (ClassLink__c classLinkRecord : classLinkRecords)
                    {
                        uow.registerNew( classLinkRecord
                                        , ClassLink__c.CodeInfo__c
                                        , codeInfoRecord
                                        );
                    }
                }

                if (fileModel instanceOf ISees
                    && ((ISees)fileModel).getSees() != null
                    && ! ((ISees)fileModel).getSees().isEmpty())
                {
                    list<ClassLink__c> classLinkRecords = ApexDocModelCompositeTransformer.createClassLinkRecords( ((ISees)fileModel).getSees() );

                    for (ClassLink__c classLinkRecord : classLinkRecords)
                    {
                        uow.registerNew( classLinkRecord
                                        , ClassLink__c.CodeInfo__c
                                        , codeInfoRecord
                                        );
                    }
                }

                if (fileModel instanceOf IDescriptionLinks
                    && ((IDescriptionLinks)fileModel).getDescriptionLinks() != null
                    && ! ((IDescriptionLinks)fileModel).getDescriptionLinks().isEmpty())
                {
                    list<ClassLink__c> classLinkRecords = ApexDocModelCompositeTransformer.createClassLinkRecords( ((IDescriptionLinks)fileModel).getDescriptionLinks() );

                    for (ClassLink__c classLinkRecord : classLinkRecords)
                    {
                        uow.registerNew( classLinkRecord
                                        , ClassLink__c.CodeInfo__c
                                        , codeInfoRecord
                                        );
                    }
                }

                if (fileModel instanceOf IMethods
                    && ((IMethods)fileModel).getMethods() != null
                    && ! ((IMethods)fileModel).getMethods().isEmpty())
                {
                    list<ClassLink__c> classLinkRecords = null;

                    for (MethodModel method : ((IMethods)fileModel).getMethods())
                    {
                        if ( ! method.getThrows().isEmpty() )
                        {
                            classLinkRecords = ApexDocModelCompositeTransformer.createClassLinkRecords( method.getThrows(), method.getNameLine() );

                            for (ClassLink__c classLinkRecord : classLinkRecords)
                            {
                                uow.registerNew( classLinkRecord
                                                , ClassLink__c.CodeInfo__c
                                                , codeInfoRecord
                                                );
                            }
                        }

                        if ( ! method.getSees().isEmpty() )
                        {
                            classLinkRecords = ApexDocModelCompositeTransformer.createClassLinkRecords( method.getSees(), method.getNameLine() );

                            for (ClassLink__c classLinkRecord : classLinkRecords)
                            {
                                uow.registerNew( classLinkRecord
                                                , ClassLink__c.CodeInfo__c
                                                , codeInfoRecord
                                                );
                            }
                        }

                        if ( ! method.getDescriptionLinks().isEmpty() )
                        {
                            classLinkRecords = ApexDocModelCompositeTransformer.createClassLinkRecords( method.getDescriptionLinks(), method.getNameLine() );

                            for (ClassLink__c classLinkRecord : classLinkRecords)
                            {
                                uow.registerNew( classLinkRecord
                                                , ClassLink__c.CodeInfo__c
                                                , codeInfoRecord
                                                );
                            }
                        }
                    }
                }
            }
        }

        // Register all of Code Info records for these particular files to be
        //      deleted.  Do this so that there are no duplicates.
        list<CodeInfo__c> codeInfoRecordsToDelete = CodeInfosSelector.newInstance().selectByApexClassNameWithClassLinks(apexFileNames);
        for (CodeInfo__c codeInfo : codeInfoRecordsToDelete)
        {
            uow.registerDeleted(codeInfo);
        }

        uow.commitWork();

        for (CodeInfo__c codeInfoRecordPostDML : codeInfoRecordList)
        {
            if ( fileModelsByClassNameMap.containsKey( codeInfoRecordPostDML.FileName__c ) )
            {
                fileModelsByClassNameMap.get( codeInfoRecordPostDML.FileName__c ).setId( codeInfoRecordPostDML.id );
            }
        }


    }

    private static void resolveTheClassLinks()
    {
        // Find all of the class links that have not been resolved
        list<ClassLink__c> classLinksNeedingToBeResolved = ClassLinksSelector.newInstance().selectByLinksNotResolved();

        // load all of the CodeInfo Ids
        list<CodeInfo__c> allClassesThatHaveBeenDocumented = CodeInfosSelector.newInstance().selectAll();

        // convert the class list into a map keyed on the name
        map<string, SObject> classesMap = ApexDocsUtils.generateMapFromField( allClassesThatHaveBeenDocumented, CodeInfo__c.FileName__c.getDescribe().getName());

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new list<Schema.SObjectType>{ ClassLink__c.SObjectType } );
        // load all of the core link references
        map<string, string> coreLinkReferences = ApexDocsConfigHelper.getSettingsForType(ApexDocsConfigHelper.Type.CORE_APEX_LINKS);

        //system.debug(classLinksNeedingToBeResolved.size());
        // add all of the links
        for (ClassLink__c aClassLink : classLinksNeedingToBeResolved)
        {
            system.debug('aClassLink.LinksToName__c = '+aClassLink.LinksToName__c);
            system.debug('classesMap.containsKey(aClassLink.LinksToName__c) = '+classesMap.containsKey(aClassLink.LinksToName__c));
            if ( classesMap.containsKey(aClassLink.LinksToName__c) )
            {
                aClassLink.LinksTo__c = classesMap.get(aClassLink.LinksToName__c).id;
                uow.registerDirty(aClassLink);
                continue;
            }

            system.debug('aClassLink.LinksToName__c.toLowerCase() = '+aClassLink.LinksToName__c.toLowerCase() );
            system.debug('coreLinkReferences.containsKey(aClassLink.LinksToName__c.toLowerCase()) = '+coreLinkReferences.containsKey(aClassLink.LinksToName__c.toLowerCase()));
            if ( coreLinkReferences.containsKey(aClassLink.LinksToName__c.toLowerCase()) )
            {
                aClassLink.CoreApexLink__c = coreLinkReferences.get(aClassLink.LinksToName__c.toLowerCase());
                uow.registerDirty(aClassLink);
            }
        }
        uow.commitWork();

    }

    private static boolean strContainsScope(final string str)
    {
        system.debug('str == '+str);

        for (string aScope : rgstrScope )
        {
            if (str.containsIgnoreCase(aScope))
            {
                return true;
            }
        }
        return false;
    }

    public static list<IFile> documentApexFiles(final list<ApexClass> files)
    {
    	if (files == null)
        {
            throw new CodeDoumenterException('The files parameter for the documentApexFiles(list<ApexClass>) method cannot be null.');
        }

        list<IFile> models = new list<IFile>();

        for (ApexClass file : files)
        {
            models.add(parseApexClass(file));
        }
        system.debug('models.size = '+models.size());

        persistFileModels(models);

        resolveTheClassLinks();

        return models;
    }


    public static IFile documentApexFile(final ApexClass file)
    {
        list<IFile> IFiles = documentApexFiles(new list<ApexClass>{ file });

        IFile model = null;

        if (IFiles != null)
        {
            model = IFiles[0];
        }

        return model;
    }

    /**
     *  @description This is the standard exception that will be thrown by the
     *      CodeDoumenter class
     *  @since 1.0
     */
    public class CodeDoumenterException extends Exception {}


}