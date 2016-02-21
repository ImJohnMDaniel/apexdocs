public class CodeDocumenter
	implements Queueable
	//Database.Batchable<SObject>
{
    public static list<string> rgstrAccessModifier { get; set; }

    static
    {
        rgstrAccessModifier = new list<string>();

        // These next four strings are added to the list in this manner to ensure that
        // they are not accidently picked up as "methods" because they have the "access modifier" words
        rgstrAccessModifier.add('glo'+'bal');
        rgstrAccessModifier.add('pub'+'lic');
        rgstrAccessModifier.add('prot'+'ected');
        rgstrAccessModifier.add('webse'+'rvice');
    }

    private list<ApexClass> classListForProcessing = new list<ApexClass>();
    private boolean isQueueableMode = false;

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
    private static string CODE_BLOCK_DELIMETER_BEGIN = '{';
    private static string CODE_BLOCK_DELIMETER_END = '}';

    // a map of nested class string lines grouped by the inner class' outer Apex class id and then the inner class name.
    private map<id, map<string, list<string>>> nestedClassLineMap = new map<id, map<string, list<string>>>();

    // a map of Apex classes that serve as outer classes to any inner classes encountered
    private map<id, ApexClass> outerClassByIdMap = new map<id, ApexClass>();

    // Setup a map of the classlinks organized first by the linksToName field and then related construct field
    private map<string, map<string, ClassLink__c>> existingClassLinkRecordsMap = new map<string, map<string, ClassLink__c>>();

    private string determineCompleteNameLine(final string strLine, final string fullFileBody)
    {
        system.debug('strLine = ' + strLine);
        system.debug('fullFileBody = ' + fullFileBody);
        // The "nameLine" is the complete declaration of the class or interface.
        //      It could span multiple lines.  We need to determine if the current
        //      strLine is the complete "nameLine" or do we need to include the
        //      next lines.
        //  The first thing to do is determine if the open bracket "{" is on the
        //      current line
        string nameLine = null;

        if ( strLine.containsIgnoreCase(CODE_BLOCK_DELIMETER_BEGIN) )
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
            nameLine = (strLine + ' ' + (fullFileBody.normalizeSpace().substringBetween(strLine,CODE_BLOCK_DELIMETER_BEGIN))).normalizeSpace();
            system.debug('nameLine is on multiple lines');
        }

        //system.debug('The NAMELINE is \n\n'+nameLine+'\n\n');

        return nameLine;
    }

    private list<IFile> execute()
    {
        list<IFile> models = new list<IFile>();

        list<ApexClass> classesToProcessInQueueableMode = new list<ApexClass>();

        for (ApexClass clazz : classListForProcessing)
        {
            // if the execution context is not currently in QueueableMode
            if ( ! this.isQueueableMode
                // send this to Queuable if its size is greater than the threshold.
                && clazz.LengthWithoutComments > 25000
                // but only if we are processing more than one class.
                && classListForProcessing.size() > 1)
            {
                classesToProcessInQueueableMode.add(clazz);
                models.add(new FileModel(null, clazz.name, FileModel.class, clazz.id));
            }
            else
            {
                // otherwise process the class in the current context.
                models.add(parseApexClass(clazz, false));

                // process any nested classes that are present.
                if (this.nestedClassLineMap.containsKey(clazz.id))
                {
                    //system.debug('this.nestedClassLineMap.get(clazz.id).keyset() === '+this.nestedClassLineMap.get(clazz.id).keyset());
                    for (string nestedClassName : this.nestedClassLineMap.get(clazz.id).keyset())
                    {
                        ApexClass nestedClazz = new ApexClass();

                        nestedClazz.id = clazz.id;
                        nestedClazz.Name = nestedClassName;
                        nestedClazz.Body = String.join(this.nestedClassLineMap.get(clazz.id).get(nestedClassName), '\n');

                        models.add( parseApexClass(nestedClazz, true ) );
                    }
                }
            }
        }

        system.debug('models.size = '+models.size());

        persistFileModels(models);

        resolveTheClassLinks();

        if ( ! classesToProcessInQueueableMode.isEmpty() )
        {
            documentApexFilesInQueueableMode( classesToProcessInQueueableMode );
        }

        return models;
    }

    private void fillModel( IApexModel model, string name, list<string> lstComments )
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
            if (comment.startsWith('/**'))
            {
                comment = comment.substringAfter('/**');
            }

            if (comment.endsWith('*/'))
            {
                comment = comment.substringBefore('*/');
            }

            // filter out blank comment lines
            if (string.isBlank(comment.replace('*','').normalizeSpace()))
            {
                continue;
            }

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
                        string commentLineLinkTo = comment.substringBetween(CODE_BLOCK_DELIMETER_BEGIN,CODE_BLOCK_DELIMETER_END).replace('@link','').normalizeSpace();

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

    private list<ClassLinkModel> findImplementedInterfacesClassLinks(final string strLine)
    {
        list<ClassLinkModel> output = new list<ClassLinkModel>();

        if (strLine.containsIgnoreCase(IMPLEMENTS_KEYWORD_STRING.trim()))
        {
            // the name(s) of the implement interface(s) should between the IMPLEMENTS_KEYWORD_STRING and the
            //     end of the string
            list<string> implementedInterfaces = strLine.substringAfter(IMPLEMENTS_KEYWORD_STRING.trim()).split(',');

            system.debug('strLine = '+strLine);
            system.debug('implementedInterfaces = '+implementedInterfaces);

            if (implementedInterfaces != null)
            {
                for (string implementedInterface : implementedInterfaces)
                {
                	if (string.isNotBlank(implementedInterface))
                	{
                        output.add(new ClassLinkModel(ClassLinkModel.ClassLinkTypes.IMPLEMENTING, implementedInterface.trim()));
                	}
                }
            }
        }

        return output;
    }

    private string findInnerClassFullyQualifiedName(final string strLine, final string outerClassName)
    {
        system.debug('findInnerClassFullyQualifiedName strLine == '+strLine);
        system.debug('findInnerClassFullyQualifiedName outerClassName == '+outerClassName);

        string innerClassName = strLine.substringBetween('class ', ' ');
        //system.debug('innerClassName = '+innerClassName);

        if (String.isBlank( innerClassName ))
        {
            // then there was no space after the innerClassName.  It was the EOL.
            // try again considering that use case
            innerClassName = strLine.substringAfter('class ');
        }
        //system.debug('innerClassName = '+innerClassName);

        if (String.isBlank( innerClassName ))
        {
            // then there was no space after the innerClassName.  It was the EOL.
            // try again considering that use case
            innerClassName = strLine.substringBetween('interface ', ' ');
        }
        //system.debug('innerClassName = '+innerClassName);

        if (String.isBlank( innerClassName ))
        {
            // then there was no space after the innerClassName.  It was the EOL.
            // try again considering that use case
            innerClassName = strLine.substringAfter('interface ');
        }
        //system.debug('innerClassName = '+innerClassName);

        return outerClassName + '.' + innerClassName;
    }

    private ClassLinkModel findExtendsClassLink(final string strLine)
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

    private IFile parseApexClass(ApexClass file, final boolean isNestedClass)
    {
        system.debug('@@@@ file.name == ' + file.name);
        try
        {
            //string strLine = null;
            //Read File Line By Line
            boolean fileParsed = false;
            boolean commentsStarted = false;
            boolean internalCommentsStarted = false;
            boolean isParsingNestedClass = false;
            boolean isNestClassStrLineContainingCodeBlockDelimeter = false;
            boolean isCurrentlyInNestedClassConstruct = false;
            string currentNestedClassBeingParsed = null;
            string strLineRaw = null;
            string previousLineFragment = null;
            list<string> lstComments = new list<string>();
            IFile fileModel = null;
            list<MethodModel> methods = new list<MethodModel>();
            list<PropertyModel> properties = new list<PropertyModel>();
            list<ConstructorModel> constructors = new list<ConstructorModel>();
            list<ClassLinkModel> innerClasses = new list<ClassLinkModel>();

            // this variable will be used to detect when a class is opened and then closed on the same line.  e.g. " class foobar {  } "
            string fileNameWithoutEnclosingClassName = file.name.indexOf('.') == -1 ? file.name : file.name.substringAfter('.') ;

            for (string strLine : file.Body.split('\n'))
            {
                system.debug('_____________________________________________________________________ strLine == '+strLine);
                //system.debug('fileParsed == '+fileParsed);
                //system.debug('isParsingNestedClass == '+isParsingNestedClass);
                //system.debug('isCurrentlyInNestedClassConstruct == '+isCurrentlyInNestedClassConstruct);

                if ( ! string.isblank(previousLineFragment) )
                {
                    strLine = previousLineFragment + ' ' + strLine.trim();
                    previousLineFragment = null;
                    system.debug('_____________________________________________________________________ strLine == '+strLine);
                }

                strLineRaw = strLine;

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
                    lstComments.add('/**');
                    continue;
                }

                // determine if this is a non "documentable" comment
                if ( ! commentsStarted && strLine.startsWith('/*'))
                {
                    internalCommentsStarted = true;
                    lstComments.clear();
                    continue;
                }

                // ignore "double slash" type comments
                if ( ! commentsStarted && strLine.startsWith('//') )
                {
                    continue;
                }

                if (commentsStarted && strLine.endsWith('*/'))
                {
                    lstComments.add(strLine);
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

                if (fileParsed && isParsingNestedClass)
                {
                    //system.debug('adding line >> '+strLine);

                    this.nestedClassLineMap.get(file.id).get(currentNestedClassBeingParsed).addAll(lstComments);

                    lstComments.clear();
                    this.nestedClassLineMap.get(file.id).get(currentNestedClassBeingParsed).add(strLine);
                }

                // ignore methods, properties, and constructors that are part of nested classes
                if (fileParsed
                    && isParsingNestedClass
                    && ! isCurrentlyInNestedClassConstruct
                    && strLine.containsIgnoreCase('(')  // this will find methods and constructors ...probably not properties though.  We will wait and see on that.
                    )
                {
                    isCurrentlyInNestedClassConstruct = true;
                    system.debug('isCurrentlyInNestedClassConstruct = true');
                    continue;
                }

                // determine when the method, property, or constructor are completed.
                if (fileParsed
                    && isParsingNestedClass
                    && isCurrentlyInNestedClassConstruct
                    && strLine.containsIgnoreCase(CODE_BLOCK_DELIMETER_END)
                    )
                {
                    isCurrentlyInNestedClassConstruct = false;
                    system.debug('isCurrentlyInNestedClassConstruct = false');
                    continue;
                }

                // determine the end of the nested classed.
                if (fileParsed
                    && isParsingNestedClass
                    && ! isCurrentlyInNestedClassConstruct
                    && strLine.containsIgnoreCase(CODE_BLOCK_DELIMETER_END) // this is the end of the class definition
                    && ( ! strLine.containsIgnoreCase(CODE_BLOCK_DELIMETER_BEGIN) // a class definition will not have a "{" and a "}"
                        || ( strLine.containsIgnoreCase(CODE_BLOCK_DELIMETER_BEGIN) // ....unless it is an empty class definition like an e_ception
                            && string.isBlank(strLine.substringBetween(CODE_BLOCK_DELIMETER_BEGIN,CODE_BLOCK_DELIMETER_END).deleteWhitespace())  )
                        )
                    )
                {
                    isParsingNestedClass = false;
                    system.debug('isParsingNestedClass = false');
                    continue;
                }

                // ignore anything after an =.  this avoids confusing properties with methods.
                ich = strLine.indexOf('=');

                if (ich > -1)
                {
                    strLine = strLine.substring(0, ich);
                }

                // ignore anything after an {.  this avoids confusing properties with methods.
                ich = strLine.indexOf(CODE_BLOCK_DELIMETER_BEGIN);

                if (ich > -1)
                {
                    strLine = strLine.substring(0, ich);
                }

                system.debug('@@@ strLine = '+strLine);
                system.debug('fileParsed == '+fileParsed);
                system.debug('isParsingNestedClass == '+isParsingNestedClass);
                system.debug('fileModel instanceOf IInnerClasses == '+(fileModel instanceOf IInnerClasses));
                system.debug('strContainsAccessModifier(strLine) == '+strContainsAccessModifier(strLine));
                system.debug('fileModel instanceOf InterfaceModel == '+(fileModel instanceOf InterfaceModel));

                // if they put the access modifier value on one line and the clazz declaration on the next line, pick it up here.
                if ( strContainsAccessModifier(strLine)
                    && string.isblank(strLine.remove(retrieveAccessModifierFromString(strLine)).trim())
                    )
                {
                    // Basically, we found a line with a access modifier variable and no other string.  This means that the rest of the nameLine is on the next line.
                    previousLineFragment = strLine;
                    system.debug('Found a name line fragment.  Adding it to the next line.');
                    continue;
                }
                // ignore lines not dealing with access modifier
                else if ( ! strContainsAccessModifier(strLine)
                        && ! (fileModel instanceOf InterfaceModel)
                        )
                {
                    system.debug('ignore lines not dealing with access modifier');
                    continue;
                }

                // look for a class
                if ( ! fileParsed
                    && strLine.containsIgnoreCase(' class '))
                {
                    system.debug('Found an class ... '+strLine);
                    fileParsed = true;

                    if (isNestedClass)
                    {
                        fileModel = new NestedClassModel();
                    }
                    else
                    {
                        fileModel = new ClassModel();
                    }

                    string fullNameLine = determineCompleteNameLine(strLine, file.Body);
                    system.debug('fullNameLine in a class is ... '+fullNameLine);

                    fillModel((IApexModel)fileModel, fullNameLine, lstComments);

                    fileModel.setApexFileId(file.id);

                    // Check to see if the class extends another class
                    if (fullNameLine.containsIgnoreCase(EXTENDS_KEYWORD_STRING.trim())
                        && fileModel instanceOf IExtensible)
                    {
                        ((IExtensible)fileModel).setExtends(findExtendsClassLink(fullNameLine));
                    }

                    // Check to see if the class implements an interface
                    if (fullNameLine.containsIgnoreCase(IMPLEMENTS_KEYWORD_STRING.trim())
                        && fileModel instanceOf IImplementable)
                    {
                        ((IImplementable)fileModel).setInterfacesImplemented(findImplementedInterfacesClassLinks(fullNameLine));
                    }

                    // Check to see if the class has an outer class
                    if (fileModel instanceOf IOuterClassible
                        && this.outerClassByIdMap.containsKey(file.id))
                    {
                        ((IOuterClassible)fileModel).setOuterClass( new ClassLinkModel(ClassLinkModel.ClassLinkTypes.OUTERCLASS, this.outerClassByIdMap.get(file.id).name) );
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
                    system.debug('Found an interface ... '+strLine);
                    fileParsed = true;

                    if (isNestedClass)
                    {
                        fileModel = new NestedInterfaceModel();
                    }
                    else
                    {
                        fileModel = new InterfaceModel();
                    }

                    string fullNameLine = determineCompleteNameLine(strLine, file.Body);

                    fillModel((IApexModel)fileModel, fullNameLine, lstComments);

                    fileModel.setApexFileId(file.id);

                    // Check to see if the interface extends another interface
                    if (fullNameLine.containsIgnoreCase(EXTENDS_KEYWORD_STRING.trim())
                        && fileModel instanceOf IExtensible)
                    {
                        ((IExtensible)fileModel).setExtends(findExtendsClassLink(fullNameLine));
                    }

                    // Check to see if the class has an outer class
                    if (fileModel instanceOf IOuterClassible
                        && this.outerClassByIdMap.containsKey(file.id))
                    {
                        ((IOuterClassible)fileModel).setOuterClass( new ClassLinkModel(ClassLinkModel.ClassLinkTypes.OUTERCLASS, this.outerClassByIdMap.get(file.id).name) );
                    }

                    lstComments.clear();
                    continue;
                }

                // look for an inner class
                if (fileParsed
                    && ! isParsingNestedClass
                    && fileModel instanceOf IInnerClasses
                    && ( strLine.containsIgnoreCase(' class ')
                        || strLine.containsIgnoreCase(' interface ')
                        )
                    )
                {
                    system.debug('Found the inner class ... '+strLine);

                    // isParsingNestedClass will be true as long as the first line of the nested class does not immediately close out with a "}"
                    system.debug('strLineRaw = '+strLineRaw);
                    isNestClassStrLineContainingCodeBlockDelimeter = strLineRaw.containsIgnoreCase(CODE_BLOCK_DELIMETER_BEGIN);
                    isParsingNestedClass = ! strLineRaw.containsIgnoreCase(CODE_BLOCK_DELIMETER_END);
                    system.debug('isParsingNestedClass = ' + isParsingNestedClass);

                    string fullNameLine = determineCompleteNameLine(strLine, file.Body);

                    //add the class name outerClass name back in the strLine
                    string fullyQualifiedInnerClassName = findInnerClassFullyQualifiedName(fullNameLine, file.name);

                    system.debug('fullyQualifiedInnerClassName = '+fullyQualifiedInnerClassName);

			        if (fullyQualifiedInnerClassName != null)
			        {
                        ClassLinkModel innerClassLink = new ClassLinkModel(ClassLinkModel.ClassLinkTypes.INNERCLASS, fullyQualifiedInnerClassName);

                        innerClasses.add( innerClassLink );

                        currentNestedClassBeingParsed = fullyQualifiedInnerClassName;

                        if ( ! this.nestedClassLineMap.containsKey(file.id) )
                        {
                            this.nestedClassLineMap.put( file.id, new map<string, list<String>>());
                        }

                        if ( ! this.nestedClassLineMap.get(file.id).containsKey(currentNestedClassBeingParsed) )
                        {
                            this.nestedClassLineMap.get(file.id).put(currentNestedClassBeingParsed, new list<String>() );
                        }

                        // add the class comments first
                        this.nestedClassLineMap.get(file.id).get(currentNestedClassBeingParsed).addAll(lstComments);
                        //system.debug('inner class lstComments === \n\n\n'+lstComments+'\n\n\n');

                        string classNameWithoutOuterClassPrefix = fullyQualifiedInnerClassName.substringAfter('.');

                        string augmentedStrLine = strLine.replace(' '+classNameWithoutOuterClassPrefix, ' '+fullyQualifiedInnerClassName);

                        system.debug('augmentedStrLine = '+augmentedStrLine );

                        // add the current strLine
                        this.nestedClassLineMap.get(file.id).get(currentNestedClassBeingParsed).add( augmentedStrLine );

                        // if the nested class name had the code block delimeter then add it back to the nestedClassLineMap because it was stripped out just above here.
                        if ( isNestClassStrLineContainingCodeBlockDelimeter )
                        {
                            this.nestedClassLineMap.get(file.id).get(currentNestedClassBeingParsed).add( CODE_BLOCK_DELIMETER_BEGIN );

                            // if there is code on the same line as the nest class line full name, then add all of that as a new line
                            if (strLine.substringAfter( CODE_BLOCK_DELIMETER_BEGIN ).length() > 0)
                            {
                                this.nestedClassLineMap.get(file.id).get(currentNestedClassBeingParsed).add( strLine.substringAfter( CODE_BLOCK_DELIMETER_BEGIN ) );
                            }
                        }

                        lstComments.clear();

                        if ( ! this.outerClassByIdMap.containsKey(file.id) )
                        {
                            this.outerClassByIdMap.put(file.id, file);
                        }
			        }

			        isNestClassStrLineContainingCodeBlockDelimeter = false;

                    continue;
                }

                system.debug('did not find a class structure.  now looking for a method or property');
                system.debug('strLine == '+strLine);
                system.debug('strLine.containsIgnoreCase(\'(\') == '+strLine.containsIgnoreCase('('));
                system.debug('isParsingNestedClass == '+isParsingNestedClass);
                system.debug('fileNameWithoutEnclosingClassName == '+fileNameWithoutEnclosingClassName);
                system.debug('strLine.replace(\' \',\'\').containsIgnoreCase(fileNameWithoutEnclosingClassName+\'(\') == ' + strLine.replace(' ','').containsIgnoreCase(fileNameWithoutEnclosingClassName+'('));

                // look for a method
                if (fileModel instanceOf IMethods
                    && strLine.containsIgnoreCase('(')
                    && ! isParsingNestedClass
                    && ! strLine.replace(' ','').containsIgnoreCase(fileNameWithoutEnclosingClassName+'(')
                    )
                {
                    //system.debug('fileModel is instanceOf IMethods.');
                    MethodModel mModel = new MethodModel();
                    //system.debug('\n\nlstComments = '+lstComments+'\nstrLine = '+strLine+'\n\n');
                    fillModel(mModel, strLine, lstComments);
                    //system.debug('mModel == '+mModel);
                    methods.add(mModel);
                    lstComments.clear();
                    continue;
                }

                if (fileModel instanceOf IConstructors
                    && ! strLine.containsIgnoreCase(' class ')
                    && ! isParsingNestedClass
                    && strLine.replace(' ','').containsIgnoreCase(fileNameWithoutEnclosingClassName+'(') )
                {
                    ConstructorModel constructorModel = new ConstructorModel();
                    fillModel(constructorModel, strLine, lstComments);
                    constructors.add(constructorModel);
                    lstComments.clear();
                    continue;
                }

                if (fileModel instanceOf IProperties
                    && string.isNotBlank(strLine.trim())
                    && ! isParsingNestedClass
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

    private void persistFileModels(final list<IFile> fileModels)
    {
        set<string> apexFileNames = new set<string>();

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(SERVICE_SOBJECTS);

        CodeInfo__c codeInfoRecord = null;

        list<CodeInfo__c> codeInfoRecordList = new list<CodeInfo__c>();

        map<string, IFile> fileModelsByClassNameMap = new map<string, IFile>();

        // Need to collect all fileModels that already exist
        for (IFile fileModel : fileModels)
        {
            if ( fileModel != null && ! string.isBlank( fileModel.getName() ) )
            {
                fileModelsByClassNameMap.put( fileModel.getName(), fileModel );
            }
        }

        map<string, CodeInfo__c> existingCodeInfoRecordsMap = new map<string, CodeInfo__c>();

        // get the existing CodeInfo__c records and organize them by name
        list<CodeInfo__c> existingCodeInfoRecords = CodeInfosSelector.newInstance().selectByApexClassNameWithClassLinks(fileModelsByClassNameMap.keySet());

        for (CodeInfo__c existingCodeInfoRecord : existingCodeInfoRecords)
        {
            existingCodeInfoRecordsMap.put( existingCodeInfoRecord.FileName__c, existingCodeInfoRecord);

            // update the existingClassLinkRecordsMap with all of these existing class links
            for (ClassLink__c classLink : existingCodeInfoRecord.ClassLinks__r)
            {
                if ( ! existingClassLinkRecordsMap.containsKey(classLink.LinksToName__c))
                {
                    existingClassLinkRecordsMap.put(classLink.LinksToName__c, new map<string, ClassLink__c>());
                }

                existingClassLinkRecordsMap.get(classLink.LinksToName__c).put(classLink.RelatedConstruct__c, classLink);
            }
        }

        // process each of the fileModels
        for (IFile fileModel : fileModels)
        {
            system.debug(fileModel);

            if (fileModel != null)
            {
                // convert the rudimentary information of the model to a CodeInfo__c record.
                codeInfoRecord = ApexDocModelCompositeTransformer.convertDomainModelToSObject(fileModel);

                codeInfoRecordList.add( codeInfoRecord );

                //system.debug('existingCodeInfoRecordsMap.containsKey(\''+codeInfoRecord.FileName__c+'\') = ' + existingCodeInfoRecordsMap.containsKey(codeInfoRecord.FileName__c));

                // Does this codeInfoRecord already exist?
                if ( existingCodeInfoRecordsMap.containsKey(codeInfoRecord.FileName__c) )
                {
                    // This record already exists
                    codeInfoRecord.id = existingCodeInfoRecordsMap.get(codeInfoRecord.FileName__c).id;
                    uow.registerDirty( codeInfoRecord );

                    // Remove any previous json representations of the fileModel
                    uow.registerDeleted( existingCodeInfoRecordsMap.get(codeInfoRecord.FileName__c).Attachments );
                }
                else
                {
                    // This record does not yet exist.
                    uow.registerNew( codeInfoRecord );
                }

                if (fileModel instanceOf FileModel)
                {
                    // If this is the case, then the model is simply a "placeholder" of sorts to store in the database.
                    // It is most likely the case that the model is being processed but under a different execution context.
                    continue;
                }

                // convert the entire model into an Attachment record and register it to the parent CodeInfo__c record.
                uow.registerNew( ApexDocModelCompositeTransformer.convertDomainModelToAttachment(fileModel)
                                , Attachment.ParentId
                                , codeInfoRecord
                                );


                // Start finding any related ClassLinks
                // Is there a ClassLink for an extensible?
                if (fileModel instanceOf IExtensible && ((IExtensible)fileModel).getExtends() != null)
                {
                    registerClassLinkWithUOW( ApexDocModelCompositeTransformer.createClassLinkRecord( ((IExtensible)fileModel).getExtends()  )
                                            , codeInfoRecord
                                            , uow);
                }

                // Is there a ClassLink for an outer class?
                if (fileModel instanceOf IOuterClassible && ((IOuterClassible)fileModel).getOuterClass() != null)
                {
                    registerClassLinkWithUOW( ApexDocModelCompositeTransformer.createClassLinkRecord( ((IOuterClassible)fileModel).getOuterClass()  )
                                            , codeInfoRecord
                                            , uow);
                }

                // Are there any ClassLinks for implementables?
                if (fileModel instanceOf IImplementable
                    && ((IImplementable)fileModel).getInterfacesImplemented() != null
                    && ! ((IImplementable)fileModel).getInterfacesImplemented().isEmpty())
                {
                    list<ClassLink__c> classLinkRecords = ApexDocModelCompositeTransformer.createClassLinkRecords( ((IImplementable)fileModel).getInterfacesImplemented() );

                    for (ClassLink__c classLinkRecord : classLinkRecords)
                    {
                        registerClassLinkWithUOW( classLinkRecord
                                                , codeInfoRecord
                                                , uow);
                    }
                }

                // Are there any ClassLinks for inner classes?
                if (fileModel instanceOf IInnerClasses
                    && ((IInnerClasses)fileModel).getInnerClasses() != null
                    && ! ((IInnerClasses)fileModel).getInnerClasses().isEmpty())
                {
                    list<ClassLink__c> classLinkRecords = ApexDocModelCompositeTransformer.createClassLinkRecords( ((IInnerClasses)fileModel).getInnerClasses() );

                    for (ClassLink__c classLinkRecord : classLinkRecords)
                    {
                        registerClassLinkWithUOW( classLinkRecord
                                                , codeInfoRecord
                                                , uow);
                    }
                }

                // Are there any ClassLinks for seeables??
                if (fileModel instanceOf ISees
                    && ((ISees)fileModel).getSees() != null
                    && ! ((ISees)fileModel).getSees().isEmpty())
                {
                    list<ClassLink__c> classLinkRecords = ApexDocModelCompositeTransformer.createClassLinkRecords( ((ISees)fileModel).getSees() );

                    for (ClassLink__c classLinkRecord : classLinkRecords)
                    {
                        registerClassLinkWithUOW( classLinkRecord
                                                , codeInfoRecord
                                                , uow);
                    }
                }

                // Are there any ClassLinks for links in descriptions??
                if (fileModel instanceOf IDescriptionLinks
                    && ((IDescriptionLinks)fileModel).getDescriptionLinks() != null
                    && ! ((IDescriptionLinks)fileModel).getDescriptionLinks().isEmpty())
                {
                    list<ClassLink__c> classLinkRecords = ApexDocModelCompositeTransformer.createClassLinkRecords( ((IDescriptionLinks)fileModel).getDescriptionLinks() );

                    for (ClassLink__c classLinkRecord : classLinkRecords)
                    {
                        registerClassLinkWithUOW( classLinkRecord
                                                , codeInfoRecord
                                                , uow);
                    }
                }

                // Need to check all of the methods for any related ClassLinks
                if (fileModel instanceOf IMethods
                    && ((IMethods)fileModel).getMethods() != null
                    && ! ((IMethods)fileModel).getMethods().isEmpty())
                {
                    list<ClassLink__c> classLinkRecords = null;

                    for (MethodModel method : ((IMethods)fileModel).getMethods())
                    {
                        // Are there any ClassLinks for throwables??
                        if ( ! method.getThrows().isEmpty() )
                        {
                            classLinkRecords = ApexDocModelCompositeTransformer.createClassLinkRecords( method.getThrows(), method.getNameLine() );

                            for (ClassLink__c classLinkRecord : classLinkRecords)
                            {
                                registerClassLinkWithUOW( classLinkRecord
                                                        , codeInfoRecord
                                                        , uow);
                            }
                        }

                        // Are there any ClassLinks for seeables in methods??
                        if ( ! method.getSees().isEmpty() )
                        {
                            classLinkRecords = ApexDocModelCompositeTransformer.createClassLinkRecords( method.getSees(), method.getNameLine() );

                            for (ClassLink__c classLinkRecord : classLinkRecords)
                            {
                                registerClassLinkWithUOW( classLinkRecord
                                                        , codeInfoRecord
                                                        , uow);
                            }
                        }

                        // Are there any ClassLinks for links in method descriptions??
                        if ( ! method.getDescriptionLinks().isEmpty() )
                        {
                            classLinkRecords = ApexDocModelCompositeTransformer.createClassLinkRecords( method.getDescriptionLinks(), method.getNameLine() );

                            for (ClassLink__c classLinkRecord : classLinkRecords)
                            {
                                registerClassLinkWithUOW( classLinkRecord
                                                        , codeInfoRecord
                                                        , uow);
                            }
                        }
                    }
                }
            }
        }

        uow.commitWork();

        // Now that all records have been saved, we need to update the IFile.id links to reflect the new CodeInfo__c id values.
        for (CodeInfo__c codeInfoRecordPostDML : codeInfoRecordList)
        {
            if ( fileModelsByClassNameMap.containsKey( codeInfoRecordPostDML.FileName__c ) )
            {
                fileModelsByClassNameMap.get( codeInfoRecordPostDML.FileName__c ).setId( codeInfoRecordPostDML.id );
            }
        }


    }

    private void registerClassLinkWithUOW(ClassLink__c classLinkRecord, CodeInfo__c codeInfoRecord, fflib_SObjectUnitOfWork uow)
    {
        //system.debug(existingClassLinkRecordsMap.keyset());
        //system.debug(classLinkRecord);
        //system.debug('this.existingClassLinkRecordsMap.containsKey(classLinkRecord.LinksToName__c) = ' + this.existingClassLinkRecordsMap.containsKey(classLinkRecord.LinksToName__c));

        //if (this.existingClassLinkRecordsMap.containsKey(classLinkRecord.LinksToName__c))
        //{
        //    system.debug('this.existingClassLinkRecordsMap.get(classLinkRecord.LinksToName__c).containsKey(classLinkRecord.RelatedConstruct__c) = ' + this.existingClassLinkRecordsMap.get(classLinkRecord.LinksToName__c).containsKey(classLinkRecord.RelatedConstruct__c));
        //}

        if (this.existingClassLinkRecordsMap.containsKey(classLinkRecord.LinksToName__c)
            && this.existingClassLinkRecordsMap.get(classLinkRecord.LinksToName__c).containsKey(classLinkRecord.RelatedConstruct__c)
            )
        {
            // this link already exists
            classLinkRecord.id = this.existingClassLinkRecordsMap.get(classLinkRecord.LinksToName__c).get(classLinkRecord.RelatedConstruct__c).id;
            uow.registerDirty( classLinkRecord );
        }
        else
        {
            // this link is new
            uow.registerNew( classLinkRecord
                            , ClassLink__c.CodeInfo__c
                            , codeInfoRecord
                            );
        }
    }

    private void resolveTheClassLinks()
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

    private String retrieveAccessModifierFromString(final string str)
    {
        string accessModifierFound = null;

        for (string aAccessModifier : rgstrAccessModifier )
        {
            // does the string (str) contain aAccessModifier plus the single space?
            //      Including the space eliminates words like "getGlobalDescribe"
            //      Including the new line and evaluation of does the line end with the access modifier word finds
            //          scenarios like when the nameline starts with a access modifier but then puts the class keyword on the next line.
            //system.debug('evaluating if '+str+ ' is a access modifier compared to '+aAccessModifier);
            if (str.containsIgnoreCase(aAccessModifier + ' ')
                || str.containsIgnoreCase(aAccessModifier + '\n')
                || (str.trim().endsWithIgnoreCase(aAccessModifier) && str.trim().startsWithIgnoreCase(aAccessModifier))
                )
            {
                accessModifierFound = aAccessModifier;
                break;
            }
        }

        //system.debug('accessModifierFound == '+accessModifierFound);
        return accessModifierFound;
    }

    private boolean strContainsAccessModifier(final string str)
    {
        return ! String.isBlank(retrieveAccessModifierFromString(str));
    }

    private CodeDocumenter()
    {

    }

    private CodeDocumenter(final list<ApexClass> classList, final boolean isQueueableMode)
    {
        this.classListForProcessing.addAll(classList);
        this.isQueueableMode = isQueueableMode;
    }

    public static IFile documentApexFile(final ApexClass file)
    {
        list<IFile> IFiles = documentApexFiles(new list<ApexClass>{ file });

        IFile model = null;

        if (IFiles != null && ! IFiles.isEmpty())
        {
            model = IFiles[0];
        }

        return model;
    }

    public static list<IFile> documentApexFiles(final list<ApexClass> apexClasses)
    {
    	if (apexClasses == null)
        {
            throw new CodeDoumenterException('The files parameter for the documentApexFiles(list<ApexClass>) method cannot be null.');
        }

        return ( new CodeDocumenter( apexClasses, false ) ).execute();
    }

    public static id documentApexFilesInQueueableMode(final list<ApexClass> apexClasses)
    {
        // Collect the class names and delete any JSON representations of the classes' Object Model.  This will ensure that
        // the current thread does not use the old version while the new version is being created in the Queue.
        set<string> clazzNameSet = new set<string>();

        for (ApexClass clazz : apexClasses)
        {
            clazzNameSet.add(clazz.name);
        }

        delete AttachmentsSelector.newInstance().selectByApexClassNameParent(clazzNameSet);

        // now go a start to create new JSON representations of the classes' Object Model
        return System.enqueueJob(new CodeDocumenter( apexClasses, true ));
    }

    public void execute(QueueableContext context)
    {
        execute();
    }

//    global Database.QueryLocator start(Database.BatchableContext BC)
//    {
//        classIdSetForBatchProcessing
//
//        return Database.getQueryLocator( ApexClassesSelector.newInstance().selectAllQuery() );
//    }
//
//    global void execute(Database.BatchableContext BC, List<sObject> scope)
//    {
//        list<IFile> models = new list<IFile>();
//
//        for (ApexClass file : (list<ApexClass>)scope)
//        {
//            models.add(parseApexClass(file));
//        }
//        system.debug('models.size = '+models.size());
//
//        persistFileModels(models);
//    }
//
//    global void finish(Database.BatchableContext BC)
//    {
//        resolveTheClassLinks();
//    }
//
//    public static void documentApexFilesInBatchMode(final set<id> apexClassIds)
//    {
//        Database.executeBatch(new CodeDocumenter(apexClassIds), 20);
//    }
//
    /**
     *  @description This is the standard exception that will be thrown by the
     *      CodeDoumenter class
     *  @since 1.0
     */
    public class CodeDoumenterException extends Exception {}


}