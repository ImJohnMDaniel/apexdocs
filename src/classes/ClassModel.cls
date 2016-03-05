/**
 *  ClassModel
 *  @author John M. Daniel
 *  @date 4 MARCH 2015
 *  @Description This is the ClassModel.  It holds the references to
 *      the class
 *
 */
public class ClassModel extends ApexConstructBaseModel
    implements IApexModel, IFile, IMethods, IProperties,
        IConstructors, IAuthorable, IInnerClasses, IExtensible,
        IImplementable, IApexFileInfo
{
	private id apexFileId;
    private id codeInfoId;
    private id codeInfoAttachmentId;

    private string apexFileLastModifiedByName;
    private id apexFileLastModifiedById;
    private DateTime apexFileLastModifiedDate;
    private string apexFileCreatedByName;
    private id apexFileCreatedById;
    private DateTime apexFileCreatedDate;
    private boolean isModelCurrent = false;

    private ClassLinkModel extendsClass = null;
    private list<MethodModel> methods = new list<MethodModel>();
    private list<PropertyModel> properties = new list<PropertyModel>();
    private list<ConstructorModel> constructors = new list<ConstructorModel>();
    private list<ClassLinkModel> innerClasses = new list<ClassLinkModel>();
    private list<string> authors = new list<string>();
    private list<ClassLinkModel> interfacesImplemented = new list<ClassLinkModel>();


    /**
     *  @return the Createddate of the associated ApexClass CreatedDate field
     */
    public DateTime getApexFileCreatedDate()
    {
        return this.apexFileCreatedDate;
    }

    /**
     *  @return the CreatedById of the associated ApexClass record
     */
    public id getApexFileCreatedById()
    {
        return this.apexFileCreatedById;
    }

    /**
     *  @return the CreatedBy.name of the associated ApexClass record
     */
    public string getApexFileCreatedByName()
    {
        return this.apexFileCreatedByName;
    }

    public id getApexFileId()
    {
        return this.apexFileId;
    }

    /**
     *  @return the LastModifieddate of the associated ApexClass record
     */
    public DateTime getApexFileLastModifiedDate()
    {
        return this.apexFileLastModifiedDate;
    }

    /**
     *  @return the LastModifiedById of the associated ApexClass record
     */
    public id getApexFileLastModifiedById()
    {
        return this.apexFileLastModifiedById;
    }

    /**
     *  @return the LastModifiedBy.name of the associated ApexClass record
     */
    public string getApexFileLastModifiedByName()
    {
        return this.apexFileLastModifiedByName;
    }

    public list<string> getAuthors()
    {
        return this.authors;
    }

    public override type getClassType()
    {
        return ClassModel.class;
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

    /**
     * @return a list of ClassLinkModels
     */
    public list<ClassLinkModel> getInnerClasses()
    {
    	return this.innerClasses;
    }


    public list<ClassLinkModel> getInterfacesImplemented()
    {
        return this.interfacesImplemented;
    }

    public boolean getIsException()
    {
        return getName().endsWithIgnoreCase('Exception');
    }

    public boolean getIsInterface()
    {
        return false;
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

    /**
     *  @return string value representing the class name
     *
     */
    public string getName()
    {
        string nameLine = getNameLine();

        if (nameLine != null) nameLine = nameLine.trim();
        //system.debug('@@ File Name = ' + nameLine);

        if(nameLine != null && nameLine.trim().length() > 0 )
        {
            string classKeywordToFind = ' class ';
            //system.debug('## File Name = ' + nameLine.trim().lastIndexOf(' '));
            integer fFound = nameLine.indexOf(classKeywordToFind);
            integer lFound = nameLine.indexOf(' ', fFound + classKeywordToFind.length());

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

    /**
     *  This is the setter for the associated ApexClass CreatedDate field.
     * @param apexFileCreatedDate
     */
    public void setApexFileCreatedDate(final DateTime apexFileCreatedDate)
    {
        this.apexFileCreatedDate = apexFileCreatedDate;
    }

    /**
     *  This is the setter for the associated ApexClass CreatedById field.
     * @param apexFileCreatedById
     */
    public void setApexFileCreatedById(final id apexFileCreatedById)
    {
        this.apexFileCreatedById = apexFileCreatedById;
    }

    /**
     *  This is the setter for the associated ApexClass CreatedBy.Name field.
     * @param apexFileCreatedByName
     */
    public void setApexFileCreatedByName(final string apexFileCreatedByName)
    {
        this.apexFileCreatedByName = apexFileCreatedByName;
    }

    public void setApexFileId(final id id)
    {
        this.apexFileId = id;
    }

    /**
     * This is the setter for the associated ApexClass LastModifiedDate field.
     * @return the LastModifiedDate of the associated ApexClass record
     */
    public void setApexFileLastModifiedDate(final DateTime apexFileLastModifiedDate)
    {
        this.apexFileLastModifiedDate = apexFileLastModifiedDate;
    }

    /**
     *  This is the setter for the associated ApexClass LastModifiedById field.
     * @param apexFileLastModifiedById
     */
    public void setApexFileLastModifiedById(final id apexFileLastModifiedById)
    {
        this.apexFileLastModifiedById = apexFileLastModifiedById;
    }

    /**
     *  This is the setter for the associated ApexClass LastModifiedBy.Name field.
     * @param apexFileLastModifiedByName
     */
    public void setApexFileLastModifiedByName(final string apexFileLastModifiedByName)
    {
        this.apexFileLastModifiedByName = apexFileLastModifiedByName;
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

    /**
     * @param list of ClassLinkModels.  One for each inner class.
     */
    public void setInnerClasses( final list<ClassLinkModel> innerClasses )
    {
        this.innerClasses = innerClasses;
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

    public void setProperties(final list<PropertyModel> properties)
    {
        this.properties = properties;
    }

}