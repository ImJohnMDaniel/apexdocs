/**
 *  Utility to parse ApexClass objects to a IFile based model
 *  @see IFile
 */
public
 class ReferenceClass0002
{
    private static list<string> accessModifierList { get; set; }
    private static string EXTENDS_KEYWORD_STRING = ' extends ';
    private static string IMPLEMENTS_KEYWORD_STRING = ' implements ';

    static
    {
        accessModifierList = new list<string>();

        // These next strings are added to the list in this manner to ensure that
        // they are not accidently picked up as "methods" because they are
        // "access modifier scope" words
        accessModifierList.add('glo'+'bal');
        accessModifierList.add('pub'+'lic');
        accessModifierList.add('prot'+'ected');
        accessModifierList.add('priv'+'ate');
        accessModifierList.add('webse'+'rvice');
    }

    private list<ApexClass> m_apexClasses = new list<ApexClass>();
    private boolean m_isPrivateConstructsIncludedInModel = false;
    private list<IFile> m_models = new list<IFile>();

    /*
     *  Private constructor.
     */
    private ReferenceClass0002()
    {

    }

    /**
     *  Main Constructor
     *  @param Apex classes to be parsed
     */
    public ReferenceClass0002(list<ApexClass> apexClasses)
    {
        this.m_apexClasses = apexClasses;
    }

    private static boolean isStringContainingAccessModifier(final string str)
    {
        if ( ! string.isBlank(str))
        {
            for (string aScope : accessModifierList )
            {
                // does the string (str) contain aScope plus the single space?
                //      Including the space eliminates words like "getGlobalDescribe"
                if (str.containsIgnoreCase(aScope + ' ')
                    || str.toLowerCase().endsWith(aScope)
                    )
                {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     *
     */
    public ReferenceClass0002 isPrivateConstructsIncludedInModel()
    {
        this.m_isPrivateConstructsIncludedInModel = true;

        return this;
    }

    /**
     *  Main parsing routine.  Method will organize and parse
     *  all ApexClass records into resulting list of IFile models
     *  @return list of {@link IFile} records
     */
    public list<IFile> parse()
    {
        for (ApexClass clazz : m_apexClasses)
        {
            m_models.add( (new ReferenceClass0002.ParsingUtil(clazz, this)).parse() );
        }

        return m_models;
    }

    /**
     *  Nested class responsible for parsing single ApexClass
     */
    private class ParsingUtil
    {
        private ApexClass m_clazz;
        private ReferenceClass0002 m_apexClassesParserInstance;
        private list<string> m_currentClassLines = new list<string>();
        private integer m_currentLine = 0;
        private integer m_numberOfClassLines = 0;
        private string m_strLineRaw = null;
        private string m_constructDeclaration = null;
        private list<string> m_comments = new list<string>();

        private IFile m_model = null;

        private list<MethodModel> m_methods = new list<MethodModel>();
        private list<PropertyModel> m_properties = new list<PropertyModel>();
        private list<ConstructorModel> m_constructors = new list<ConstructorModel>();
        private list<ClassLinkModel> m_innerClasses = new list<ClassLinkModel>();

        private ParsingUtil()
        {

        }

        public ParsingUtil(final ApexClass clazz, ReferenceClass0002 apexClassesParserInstance)
        {
            this.m_clazz = clazz;
            this.m_currentClassLines.addAll( clazz.Body.split('\n') );
            this.m_numberOfClassLines = this.m_currentClassLines.size();
            system.debug(logginglevel.error,  'this.m_numberOfClassLines = '+this.m_numberOfClassLines);
            this.m_apexClassesParserInstance = apexClassesParserInstance;
        }

        private integer getCurrentApexClassLineNumber()
        {
            return this.m_currentLine + 1;
        }

        private void fillModel()
        {
            fillModel((IApexModel)this.m_model);
        }

        private void fillModel(IApexModel model)
        {
            //if (this.m_constructDeclaration.containsIgnoreCase('scratchinterface'))
            //{
            // system.debug('this.m_constructDeclaration == '+this.m_constructDeclaration);
            //}
            model.setNameLine(this.m_constructDeclaration);

            boolean inDescription = false;
            boolean isLinkTagInCommentFound = false;

            string tagIdentified = null;
            // system.debug(model);
            // system.debug( lstComments );

            for (string comment : this.m_comments)
            {
                comment = comment.trim();

                // system.debug( comment );
                if (comment.trim().startsWith('/**'))
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

                //system.debug('\n\ntagIdentified = '+tagIdentified + '\n'
                //            + 'inDescription = '+inDescription + '\n'
                //            + 'comment == '+comment + '\n'
                //            + '\n\n');

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

            //system.debug('\n\n\n' + model + '\n\n\n');
        }

        private string findInnerClassFullyQualifiedName()
        {
            string innerClassName = this.m_strLineRaw.substringBetween('class ', ' ');
            //system.debug('innerClassName = '+innerClassName);

            if (innerClassName == null)
            {
                // then there was no space after the innerClassName.  It was the EOL.
                // try again considering that use case
                innerClassName = this.m_strLineRaw.substringAfter('class ');
            }

            if (innerClassName == null)
            {
                // then there was no space after the innerClassName.  It was the EOL.
                // try again considering that use case
                innerClassName = this.m_strLineRaw.substringBetween('interface ', ' ');
            }

            if (innerClassName == null)
            {
                // then there was no space after the innerClassName.  It was the EOL.
                // try again considering that use case
                innerClassName = this.m_strLineRaw.substringAfter('interface ');
            }

            //system.debug('innerClassName = '+innerClassName);

            return this.m_clazz.name + '.' + innerClassName;
        }

        private void nextLine()
        {
            ++ this.m_currentLine;

            if (this.m_currentLine < this.m_numberOfClassLines)
            {
                this.m_strLineRaw = this.m_currentClassLines[this.m_currentLine].trim();

                system.debug('                                                                   Line '+ getCurrentApexClassLineNumber() +': ' + this.m_strLineRaw);

                if (string.isBlank(this.m_strLineRaw)
                    || this.m_strLineRaw.trim().startsWith('//')
                    )
                {
                    nextLine();
                }
            }
            else
            {
                this.m_strLineRaw = null;
            }
        }

//        private void parseApexFileInfo()
//        {
//            if ( this.m_model instanceOf IApexFileInfo )
//            {
//                ((IApexFileInfo)this.m_model).setApexFileCreatedDate( this.m_clazz.CreatedDate );
//                ((IApexFileInfo)this.m_model).setApexFileCreatedById( this.m_clazz.CreatedById );
//                ((IApexFileInfo)this.m_model).setApexFileLastModifiedDate( this.m_clazz.LastModifiedDate );
//                ((IApexFileInfo)this.m_model).setApexFileLastModifiedById( this.m_clazz.LastModifiedById );
//                try
//                {
//                    ((IApexFileInfo)this.m_model).setApexFileCreatedByName( this.m_clazz.CreatedBy.Name );
//                    ((IApexFileInfo)this.m_model).setApexFileLastModifiedByName( this.m_clazz.LastModifiedBy.Name );
//                }
//                catch (System.SObjectException oe)
//                {
//                    // the name of the file creater was not queried.  move on
//                }
//            }
//
//        }

        /*
         *  The class syntax pattern is
         *
         *  private | public | global
         *  [virtual | abstract | with sharing | without sharing]
         *  class ClassName [implements InterfaceNameList] [extends ClassName]
         *  {
         *  // The body of the class
         *  }
         */
        private boolean parseClass()
        {
            boolean isClassFound = false;
            system.debug('parseClass called');
            if ( isStringContainingAccessModifier(this.m_constructDeclaration)
                && this.m_constructDeclaration.containsIgnoreCase('class ') // the space at the end of the string is on purpose
                && ! this.m_constructDeclaration.containsIgnoreCase('exception')
                )
            {
                system.debug('Found a class starting on line '+getCurrentApexClassLineNumber());

//                this.m_model = new ClassModel();
//
//                fillModel();
//
//                this.m_model.setApexFileId(this.m_clazz.id);
//
//                system.debug('processing continues on class');
//
//                parseExtension(this.m_model);
//
//                parseImplementedInterfaces(this.m_model);
//
//                parseApexFileInfo();
//
//                nextLine();

                // now loop through the next few lines in order to find all comment lines
                while ( ! this.m_strLineRaw.endsWith('}')
                    || this.m_strLineRaw.substringBetween('{','}') != null  // this is the seen with "Automatic Properties"
                    )
                {
//                    system.debug('                                                   in the loop');
//                    parseComments();
//                    resolveApexConstruct();
//                    parseConstructor(this.m_model.getName());
//                    parseMethod(this.m_model.getName());
//                    parseNestedClass();
//                    parseNestedException();
//                    parseNestedInterface();
//                    parseProperty(this.m_model.getName());
//                    parseInitializer();
//
//                    nextLine();
                }
                isClassFound = true;
            }
            system.debug('parseClass completed');
            return isClassFound;
        }

//        private void parseComments()
//        {
//            if ( this.m_strLineRaw.trim().startsWith('/**') )
//            {
//                system.debug('found new comment starting on line '+getCurrentApexClassLineNumber());
//                this.m_comments.clear();
//
//                // now loop through the next few lines in order to find all comment lines
//                while ( ! this.m_strLineRaw.endsWith('*/') )
//                {
//                    this.m_comments.add(this.m_strLineRaw);
//                    nextLine();
//                }
//
//                this.m_comments.add(this.m_strLineRaw);
//            }
//            if ( this.m_strLineRaw.trim().startsWith('/*') )
//            {
//                // now loop through the next few lines in order to find all comment lines
//                while ( ! this.m_strLineRaw.endsWith('*/') )
//                {
//                    nextLine();
//                }
//            }
//        }
//
//        /*
//         *  The constructor syntax pattern is
//         *
//         *  private | public | global ClassName([param1 [, param2...]])
//         *  {
//         *  // The body of the constructor
//         *  }
//         */
//        private boolean parseConstructor(final string clazzName)
//        {
//            boolean isConstructorFound = false;
//            system.debug('parseConstructor called');
//            if ( this.m_model instanceOf IConstructors
//                && isStringContainingAccessModifier(this.m_constructDeclaration)
//                && ! this.m_constructDeclaration.containsIgnoreCase(' class ') // the space at the end of the string is on purpose
//                && this.m_constructDeclaration.replace(' ','').containsIgnoreCase(clazzName+'(')
//                )
//            {
//                system.debug('Found a constructor starting on line '+getCurrentApexClassLineNumber());
//
//                if ( ! this.m_constructDeclaration.toLowerCase().trim().startsWith('priv'+'ate ')
//                    || (this.m_apexClassesParserInstance.m_isPrivateConstructsIncludedInModel
//                        && this.m_constructDeclaration.toLowerCase().trim().startsWith('priv'+'ate '))
//                    )
//                {
//                    ConstructorModel constructorModel = new ConstructorModel();
//                    fillModel(constructorModel);
//                    this.m_constructors.add(constructorModel);
//                }
//
//                // now loop through the next few lines in order to find all lines of the constructor
//                while ( ! this.m_strLineRaw.endsWith('}') )
//                {
//                    nextLine();
//                }
//                isConstructorFound = true;
//            }
//            return isConstructorFound;
//        }
//
//        /*
//         *  The interface syntax pattern is
//         *
//         *  private | public | global
//         *  class ExceptionName extends Exception
//         *  {
//         *  // The body of the exception
//         *  }
//         */
//        private boolean parseException()
//        {
//            boolean isExceptionFound = false;
//
//            if ( isStringContainingAccessModifier(this.m_constructDeclaration)
//                && this.m_constructDeclaration.containsIgnoreCase('class ') // the space at the end of the string is on purpose
//                && this.m_constructDeclaration.containsIgnoreCase('exception')
//                )
//            {
//                system.debug('Found an exception starting on line '+getCurrentApexClassLineNumber());
//
//                this.m_model = new ClassModel();
//
//                fillModel();
//
//                this.m_model.setApexFileId(this.m_clazz.id);
//
//                parseExtension(this.m_model);
//
//                parseApexFileInfo();
//
//                // now loop through the next few lines in order to find all comment lines
//                while ( ! this.m_strLineRaw.endsWith('}') )
//                {
//                    parseComments();
//                    resolveApexConstruct();
//                    parseConstructor(this.m_model.getName());
//                    parseProperty(this.m_model.getName());
//
//                    nextLine();
//                }
//
//                isExceptionFound = true;
//            }
//
//            return isExceptionFound;
//        }
//
//        private void parseExtension(IFile model)
//        {
//            system.debug('parseExtension called');
//            // Check to see if the class extends another class
//            if (this.m_constructDeclaration.containsIgnoreCase(EXTENDS_KEYWORD_STRING.trim())
//                && model instanceOf IExtensible)
//            {
//                // the name of the parent class should between the EXTENDS_KEYWORD_STRING and the
//                //     next space
//                string parentClassName = this.m_constructDeclaration.substringBetween(EXTENDS_KEYWORD_STRING, ' ');
//                system.debug('parentClassName = '+parentClassName);
//                if (string.isBlank(parentClassName))
//                {
//                    // then there was no space after the parentClassName.  It was the EOL.
//                    // try again considering that use case
//                    parentClassName = this.m_constructDeclaration.substringAfter(EXTENDS_KEYWORD_STRING);
//                }
//                system.debug('parentClassName = '+parentClassName);
//                if ( ! string.isBlank(parentClassName) )
//                {
//                    ((IExtensible)model).setExtends( new ClassLinkModel(ClassLinkModel.ClassLinkTypes.EXTENDING, parentClassName) );
//                }
//            }
//
//        }
//
//        private void parseImplementedInterfaces(IFile model)
//        {
//            system.debug('parseImplementedInterfaces called');
//            // Check to see if the class implements an interface
//            if (this.m_constructDeclaration.containsIgnoreCase(IMPLEMENTS_KEYWORD_STRING.trim())
//                && model instanceOf IImplementable)
//            {
//                system.debug('interfaces are implemented');
//                // the name(s) of the implement interface(s) should between the IMPLEMENTS_KEYWORD_STRING and the
//                //     end of the string
//                list<string> implementedInterfaces = this.m_constructDeclaration.substringAfter(IMPLEMENTS_KEYWORD_STRING.trim()).split(',');
//
//                system.debug('implementedInterfaces = '+implementedInterfaces);
//
//                if (implementedInterfaces != null)
//                {
//                    for (string implementedInterface : implementedInterfaces)
//                    {
//                        if (string.isNotBlank(implementedInterface))
//                        {
//                            ((IImplementable)model).getInterfacesImplemented().add(new ClassLinkModel(ClassLinkModel.ClassLinkTypes.IMPLEMENTING, implementedInterface.trim()));
//                        }
//                    }
//                }
//            }
//        }
//
//        /*
//         *  The initializer syntax pattern is
//         *
//         *  [static]
//         *  {
//         *  // The body of the initializer
//         *  }
//         */
//        private void parseInitializer()
//        {
//            system.debug('parseInitializer called');
//            if ( this.m_strLineRaw.contains('{')
//                && ! isStringContainingAccessModifier(this.m_strLineRaw)
//                )
//            {
//                system.debug('class initializer has been found');
//                while ( ! this.m_strLineRaw.endsWith('}') )
//                {
//                    nextLine();
//                }
//            }
//        }
//
//        /*
//         *  The interface syntax pattern is
//         *
//         *  private | public | global
//         *  interface InterfaceName [extends InterfaceName]
//         *  {
//         *  // The body of the interface
//         *  }
//         */
//        private boolean parseInterface()
//        {
//            boolean isInterfaceFound = false;
//            if ( isStringContainingAccessModifier(this.m_constructDeclaration)
//                && this.m_constructDeclaration.containsIgnoreCase('interface ')) // the space at the end of the string is on purpose
//            {
//                system.debug('Found an interface starting on line '+getCurrentApexClassLineNumber());
//                this.m_model = new InterfaceModel();
//
//                fillModel();
//
//                this.m_model.setApexFileId(this.m_clazz.id);
//
//                parseExtension(this.m_model);
//
//                parseApexFileInfo();
//
//                // now loop through the next few lines in order to find all lines of the interface
//                while ( ! this.m_strLineRaw.endsWith('}') )
//                {
//                    parseComments();
//                    resolveApexConstruct();
//                    parseMethod(this.m_model.getName());
//
//                    nextLine();
//                }
//                 isInterfaceFound = true;
//            }
//            return isInterfaceFound;
//        }
//
//        /*
//         *  The method syntax pattern is
//         *
//         *  [public | private | protected | global] [override] [static] data_type method_name (input parameters)
//         *  {
//         *  // The body of the method
//         *  }
//         */
//        private void parseMethod(final string clazzName)
//        {
//            system.debug('parseMethod called');
//            if ( this.m_model instanceOf IMethods
//                && isStringContainingAccessModifier(this.m_constructDeclaration)
//                && this.m_constructDeclaration.containsIgnoreCase('(')
//                && ! this.m_constructDeclaration.replace(' ','').containsIgnoreCase(clazzName+'(')
//                )
//            {
//                system.debug('Found a method starting on line '+getCurrentApexClassLineNumber());
//
//                if ( ! this.m_constructDeclaration.toLowerCase().trim().startsWith('priv'+'ate ')
//                    || (this.m_apexClassesParserInstance.m_isPrivateConstructsIncludedInModel
//                        && this.m_constructDeclaration.toLowerCase().trim().startsWith('priv'+'ate '))
//                    )
//                {
//                    MethodModel methodModel = new MethodModel();
//                    fillModel(methodModel);
//                    this.m_methods.add(methodModel);
//                }
//
//                integer levelsDeep = 1;
//
//                // now loop through the next few lines in order to find all lines of the method
//                while ( ! this.m_strLineRaw.endsWith('}')
//                    || ( this.m_strLineRaw.endsWith('}') && levelsDeep > 0 )
//                    )
//                {
//                    nextLine();
//                    if (this.m_strLineRaw.contains('{'))
//                    {
//                        ++levelsDeep;
//                    }
//                    if (this.m_strLineRaw.contains('}'))
//                    {
//                        --levelsDeep;
//                    }
//                    //system.debug('                  levelsDeep = '+levelsDeep);
//                }
//
//                this.m_constructDeclaration = null;
//            }
//        }
//
//        private void parseNestedClass()
//        {
//            if ( isStringContainingAccessModifier(this.m_constructDeclaration)
//                && this.m_constructDeclaration.containsIgnoreCase('class ') // the space at the end of the string is on purpose
//                && ! this.m_constructDeclaration.containsIgnoreCase('exception')
//                )
//            {
//                system.debug('Found a nested class starting on line '+getCurrentApexClassLineNumber());
//
//                NestedClassModel model = new NestedClassModel();
//
//                fillModel(model);
//
//                parseApexFileInfo();
//
//                prepareNestedClassLink();
//
//                //this.m_model.setApexFileId(this.m_clazz.id);
//
//                system.debug('processing continues on class');
//
//                parseExtension(model);
//
//                parseImplementedInterfaces(model);
//
//                nextLine();
//
//                // now loop through the next few lines in order to find all comment lines
//                while ( ! this.m_strLineRaw.endsWith('}')
//                    || this.m_strLineRaw.substringBetween('{','}') != null  // this is the seen with "Automatic Properties"
//                    )
//                {
//                    system.debug('                                                   in the loop');
//                    parseComments();
//                    resolveApexConstruct();
//                    parseConstructor(model.getName());
//                    parseMethod(model.getName());
//                    parseProperty(model.getName());
//                    parseInitializer();
//
//                    nextLine();
//                }
//
//                this.m_apexClassesParserInstance.m_models.add(model);
//            }
//        }
//
//        private void parseNestedException()
//        {
//            if ( isStringContainingAccessModifier(this.m_constructDeclaration)
//                && this.m_constructDeclaration.containsIgnoreCase('class ') // the space at the end of the string is on purpose
//                && this.m_constructDeclaration.containsIgnoreCase('exception')
//                )
//            {
//                system.debug('Found an exception starting on line '+getCurrentApexClassLineNumber());
//
//                ClassModel model = new ClassModel();
//
//                fillModel(model);
//
//                parseApexFileInfo();
//
//                prepareNestedClassLink();
//
//                //this.m_model.setApexFileId(this.m_clazz.id);
//
//                parseExtension(model);
//
//                // now loop through the next few lines in order to find all comment lines
//                while ( ! this.m_strLineRaw.endsWith('}') )
//                {
//                    parseComments();
//                    resolveApexConstruct();
//                    parseConstructor(model.getName());
//                    parseProperty(model.getName());
//
//                    nextLine();
//                }
//
//                this.m_apexClassesParserInstance.m_models.add(model);
//            }
//        }
//
//        private void parseNestedInterface()
//        {
//            if ( isStringContainingAccessModifier(this.m_constructDeclaration)
//                && this.m_constructDeclaration.containsIgnoreCase('interface ')) // the space at the end of the string is on purpose
//            {
//                system.debug('Found an interface starting on line '+getCurrentApexClassLineNumber());
//                InterfaceModel model = new InterfaceModel();
//
//                fillModel(model);
//
//                //this.m_model.setApexFileId(this.m_clazz.id);
//
//                parseApexFileInfo();
//
//                prepareNestedClassLink();
//
//                parseExtension(model);
//
//                // now loop through the next few lines in order to find all lines of the interface
//                while ( ! this.m_strLineRaw.endsWith('}') )
//                {
//                    parseComments();
//                    resolveApexConstruct();
//                    parseMethod(model.getName());
//
//                    nextLine();
//                }
//
//                this.m_apexClassesParserInstance.m_models.add(model);
//            }
//        }
//
//        /*
//         *  The property syntax pattern is
//         *
//         *  |-------------------access_modifier------------------------|
//         *  [public | private | global | protected] [static | transient] return_type property_name
//         *  { [access_modifier] get[;|{}] [access_modifier] set[;|{}] }
//         */
//        private void parseProperty(final string clazzName)
//        {
//            system.debug('parseProperty called');
//            if ( this.m_model instanceOf IProperties
//                && isStringContainingAccessModifier(this.m_constructDeclaration)
//                && ! this.m_constructDeclaration.containsIgnoreCase(' ' + clazzName) // this would be true with a constructor
//                //&& ! this.m_constructDeclaration.contains('=')
//                )
//            {
//                system.debug('property m_constructDeclaration = '+m_constructDeclaration);
//                system.debug('Found a property starting on line '+getCurrentApexClassLineNumber());
//
//                if ( ! this.m_constructDeclaration.toLowerCase().trim().startsWith('priv'+'ate ')
//                    || (this.m_apexClassesParserInstance.m_isPrivateConstructsIncludedInModel
//                        && this.m_constructDeclaration.toLowerCase().trim().startsWith('priv'+'ate '))
//                    )
//                {
//                    PropertyModel propertyModel = new PropertyModel();
//                    fillModel(propertyModel);
//                    this.m_properties.add(propertyModel);
//                }
//                // now loop through the next few lines in order to find all lines of the property
//// TODO: Need to refine this better
//                while ( ! this.m_strLineRaw.endsWith('}') )
//                {
//                    nextLine();
//                }
//
//            }
//        }
//
//        private void prepareNestedClassLink()
//        {
////            string fullyQualifiedInnerClassName = findInnerClassFullyQualifiedName();
//            system.debug('prepareNestedClassLink : this.m_strLineRaw === '+this.m_strLineRaw);
//            system.debug('prepareNestedClassLink : this.m_constructDeclaration === '+this.m_constructDeclaration);
//
//            // Determine fully qualified nested class name
//            string innerClassName = this.m_constructDeclaration.substringBetween('class ', ' ');
//            //system.debug('innerClassName = '+innerClassName);
//
//            if (innerClassName == null)
//            {
//                // then there was no space after the innerClassName.  It was the EOL.
//                // try again considering that use case
//                innerClassName = this.m_constructDeclaration.substringAfter('class ');
//            }
//
//            if (innerClassName == null)
//            {
//                // then there was no space after the innerClassName.  It was the EOL.
//                // try again considering that use case
//                innerClassName = this.m_constructDeclaration.substringBetween('interface ', ' ');
//            }
//
//            if (innerClassName == null)
//            {
//                // then there was no space after the innerClassName.  It was the EOL.
//                // try again considering that use case
//                innerClassName = this.m_constructDeclaration.substringAfter('interface ');
//            }
//
//            //system.debug('innerClassName = '+innerClassName);
//
//            if (innerClassName != null)
//            {
//                string fullyQualifiedInnerClassName = this.m_clazz.name + '.' + innerClassName;
//
//                system.debug('fullyQualifiedInnerClassName = '+fullyQualifiedInnerClassName);
//
//                //ClassLinkModel innerClassLink = new ClassLinkModel(ClassLinkModel.ClassLinkTypes.INNERCLASS, fullyQualifiedInnerClassName);
//
//                //innerClasses.add( innerClassLink );
//                if (this.m_model instanceOf IInnerClasses)
//                {
//                    //((IInnerClasses)this.m_model).getInnerClasses().add(innerClassLink);
//                    ((IInnerClasses)this.m_model).getInnerClasses().add( new ClassLinkModel(ClassLinkModel.ClassLinkTypes.INNERCLASS, fullyQualifiedInnerClassName) );
//                }
//
//                //currentNestedClassBeingParsed = fullyQualifiedInnerClassName;
//
//                //if ( ! this.nestedClassLineMap.containsKey(file.id) )
//                //{
//                //    this.nestedClassLineMap.put( file.id, new map<string, list<String>>());
//                //}
//                //
//                //if ( ! this.nestedClassLineMap.get(file.id).containsKey(currentNestedClassBeingParsed) )
//                //{
//                //    this.nestedClassLineMap.get(file.id).put(currentNestedClassBeingParsed, new list<String>() );
//                //}
//
//                // add the class comments first
//                //this.nestedClassLineMap.get(file.id).get(currentNestedClassBeingParsed).addAll(lstComments);
//                //system.debug('inner class lstComments === \n\n\n'+lstComments+'\n\n\n');
//
//                //string classNameWithoutOuterClassPrefix = fullyQualifiedInnerClassName.substringAfter('.');
//                //
//                //string augmentedStrLine = strLine.replace(' '+classNameWithoutOuterClassPrefix, ' '+fullyQualifiedInnerClassName);
//                //
//                //system.debug('augmentedStrLine = '+augmentedStrLine );
//                //
//                //// add the current strLine
//                //this.nestedClassLineMap.get(file.id).get(currentNestedClassBeingParsed).add( augmentedStrLine );
//                //
//                //lstComments.clear();
//
//                //if ( ! this.outerClassByIdMap.containsKey(file.id) )
//                //{
//                //    this.outerClassByIdMap.put(file.id, file);
//                //}
//            }
//        }
//
//        /*
//         *  This method detects the beginning of various construct type declarations
//         *  (i.e. class, interfaces, constructors, methods, properites, etc.) and then
//         *  normalizes the entire declaration onto a single line (i.e. m_constructDeclaration)
//         *  which can then be evaluated by the other resolving methods like
//         *  parseClass() and parseMethod().
//         *
//         *  A construct declaration consists of all text between scope keyword and the open curly brace
//         */
//        private void resolveApexConstruct()
//        {
//            //system.debug('resolveApexConstruct called.  m_strLineRaw : '+this.m_strLineRaw);
//
//            this.m_constructDeclaration = null;
//
//// TODO: Need to refine this some more.  Not every construct of relevance will have an access modified... or will they?
//            if ( isStringContainingAccessModifier(this.m_strLineRaw) )
//            {
//                system.debug('found new construct starting on line '+(this.m_currentLine + 1));
//
//                this.m_constructDeclaration = '';
//
//                // now loop through the next few lines in order to find the entire construct definition
//                if ( ! ( this.m_strLineRaw.split(' ').size() == 3 && this.m_strLineRaw.trim().endsWith(';')))
//                {
//                    while ( ! this.m_strLineRaw.containsIgnoreCase('{')
//                        && ! this.m_strLineRaw.containsIgnoreCase('=')
//                        )
//                    {
//                        this.m_constructDeclaration += ' ' + this.m_strLineRaw.substringBefore('{');
//                        nextLine();
//                    }
//                    if ( ! this.m_strLineRaw.containsIgnoreCase('=') )
//                    {
//                        this.m_constructDeclaration += ' ' + this.m_strLineRaw.substringBefore('{');
//                        this.m_constructDeclaration.normalizeSpace();
//
//                        this.m_constructDeclaration = this.m_constructDeclaration.replace('{','').trim();
//                    }
//                    else
//                    {
//                        // a construct will not have an equal sign.
//                        this.m_constructDeclaration = null;
//                    }
//                }
//                else
//                {
//                    // this is a apex variable with no initial assignment.
//                    //  Example is  'access_modifier return_type variable_name;'
//                    this.m_constructDeclaration = null;
//
//                }
//            }
//        }

        /**
         *  Method will begin parsing tasks on the class.
         *  @return {@link IFile} model representation of the ApexClass
         */
        public IFile parse()
        {
            this.m_currentLine = 0;

//            // extract the first line of the ApexClass
//            this.m_strLineRaw = this.m_currentClassLines[this.m_currentLine];
//            system.debug('                                                                   Line '+ (this.m_currentLine + 1) +': ' + this.m_strLineRaw);
//
//            while ( this.m_currentLine < this.m_numberOfClassLines )
//            {
//                parseComments();
//
//                resolveApexConstruct();
//
//                if (parseClass())
//                {
//                }
//                else if (parseInterface())
//                {
//                }
//                else if (parseException())
//                {
//                }
//                nextLine();
//            }

            return this.m_model;
        }
    }

    public class ApexClassesParserException extends Exception { }

    public
    interface ScratchInterface
    {
    }

}