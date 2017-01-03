/**
 * Model that represents an Apex inner (or nested) class.
 * @author John M. Daniel
 */
public class NestedClassModel
    extends ApexConstructBaseModel
    implements  IApexModel, IFile, IMethods, IProperties, IOuterClassible,
        IConstructors, IAuthorable, IExtensible, IImplementable
{
	private id apexFileId;
    private id codeInfoId;
    private id codeInfoAttachmentId;

    private boolean isModelCurrent = false;
    private ClassLinkModel extendsClass = null;
    private ClassLinkModel outerClass = null;
    private list<MethodModel> methods = new list<MethodModel>();
    private list<PropertyModel> properties = new list<PropertyModel>();
    private list<ConstructorModel> constructors = new list<ConstructorModel>();
    private list<ClassModel> innerClasses = new list<ClassModel>();
    private list<string> authors = new list<string>();
    private list<ClassLinkModel> interfacesImplemented = new list<ClassLinkModel>();


    public override type getClassType()
    {
        return NestedClassModel.class;
    }

    public list<string> getAuthors()
    {
        return this.authors;
    }

    public id getApexFileId()
    {
        return this.apexFileId;
    }

    /**
     *  @return string value representing the class name
     *
     */
    public string getName()
    {
        string nameLine = getNameLine();

        if (nameLine != null) nameLine = nameLine.trim();
        //system.debug(logginglevel.error, '@@ File Name = ' + nameLine);

        if(nameLine != null && nameLine.trim().length() > 0 )
        {
            string classKeywordToFind = ' class ';
            //system.debug('## File Name = ' + nameLine.trim().lastIndexOf(' '));
            integer fFound = nameLine.toLowerCase().indexOf(classKeywordToFind);
            integer lFound = nameLine.toLowerCase().indexOf(' ', fFound + classKeywordToFind.length());

            if (lFound == -1)
                return nameLine.substring(fFound + classKeywordToFind.length());

            try
            {
                String name = nameLine.substring(fFound + classKeywordToFind.length(), lFound);
                return name;
            }
            catch (Exception ex)
            {
                return nameLine.substring(nameLine.lastIndexOf(' ') + 1);
            }
        }
        else
        {
            return '';
        }
    }

    public id getCodeInfoAttachmentId()
    {
        return this.codeInfoAttachmentId;
    }

    public list<ConstructorModel> getConstructors()
    {
        return this.constructors;
    }

    /**
     *  @return the {@link ClassLinkModel} that represents the class that this one is extending.
     */
    public ClassLinkModel getExtends()
    {
        return this.extendsClass;
    }

    public id getId()
    {
        return this.codeInfoId;
    }

    public list<ClassLinkModel> getInterfacesImplemented()
    {
        return this.interfacesImplemented;
    }

    public boolean getIsInterface()
    {
        return false;
    }

    public boolean getIsException()
    {
        return getName().endsWithIgnoreCase('Exception');
    }

    /**
     *  Method is used to determine if the model information currently stored is up to date or
     *  has there been an update to the Apex Class since the last documentation event.
     *  @return boolean - true if the Apex Class and documented model information are in sync.
     */
    public boolean getIsModelCurrent()
    {
        return this.isModelCurrent;
    }

    public list<MethodModel> getMethods()
    {
        return this.methods;
    }

    public ClassLinkModel getOuterClass()
    {
        return this.outerClass;
    }

    public list<PropertyModel> getProperties()
    {
        return this.properties;
    }

    /**
     *  convenience method to return same information as the getIsModelCurrent() method.
     */
    public boolean isModelCurrent()
    {
        return this.isModelCurrent;
    }

    // TODO: Change these tags a ENUM or some sort of central constant.
    public void set(final string tag, final string value)
    {
        if (tag == 'description')
        {
            //this.setDescription( ( this.getDescription() == null ? '' : this.getDescription() + ' ' ) + value );
            this.addDesciptionLine( value );
        }
        else if (tag == 'author')
        {
            this.getAuthors().add(value);
        }
        else if (tag == 'see')
        {
            this.addSee(value);
        }
        else if (tag == 'since')
        {
            this.setSince(value);
        }
        else if (tag == 'date')
        {
            this.setDate(value);
        }
        else if (tag == 'deprecated')
        {
            this.setDeprecated(true);
        }
    }

    public void setApexFileId(final id id)
    {
        this.apexFileId = id;
    }

    public void setAuthor(final string author)
    {
        this.authors.add(author);
    }

    public void setAuthor(final list<string> authors)
    {
        this.authors = authors;
    }

    public void setCodeInfoAttachmentId(final id codeInfoAttachmentId)
    {
        this.codeInfoAttachmentId = codeInfoAttachmentId;
    }

    public void setConstructors(final list<ConstructorModel> constructors)
    {
        this.constructors = constructors;
    }

    public void setExtends(final ClassLinkModel extendsClass)
    {
        this.extendsClass = extendsClass;
    }

    public void setId(final id codeInfoId)
    {
        this.codeInfoId = codeInfoId;
    }

    public void setInterfacesImplemented(final list<ClassLinkModel> interfacesImplemented)
    {
        this.interfacesImplemented = interfacesImplemented;
    }

    /**
     *  Setter method for the isModelCurrent value
     */
    public void setIsModelCurrent(final boolean isModelCurrent)
    {
        this.isModelCurrent = isModelCurrent;
    }

    public void setMethods(final list<MethodModel> methods)
    {
        this.methods = methods;
    }

    public void setOuterClass( final ClassLinkModel outerClass )
    {
        this.outerClass = outerClass;
    }

    public void setProperties(final list<PropertyModel> properties)
    {
        this.properties = properties;
    }

}